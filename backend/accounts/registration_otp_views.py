from datetime import timedelta

from django.contrib.auth import get_user_model
from django.contrib.auth.hashers import check_password
from django.db import transaction
from django.utils import timezone
from rest_framework import status
from rest_framework.permissions import AllowAny
from rest_framework.response import Response
from rest_framework.views import APIView

from .models import RegistrationOTP
from .registration_otp import deliver_registration_codes, issue_registration_codes, normalize_mobile_number
from .serializers import UserSerializer
from .services import get_tokens_for_user

User = get_user_model()
MAX_OTP_ATTEMPTS = 5


def _registration_contact(request):
    email = str(request.data.get('email', '')).strip().lower()
    mobile = str(request.data.get('mobile_number', '')).strip()
    if not email or not mobile:
        return None, None, Response(
            {
                'success': False,
                'message': 'Email and mobile number are required.',
            },
            status=status.HTTP_400_BAD_REQUEST,
        )
    try:
        mobile = normalize_mobile_number(mobile)
    except ValueError as error:
        return None, None, Response(
            {'success': False, 'message': str(error)},
            status=status.HTTP_400_BAD_REQUEST,
        )
    return email, mobile, None


class RegistrationOTPVerifyView(APIView):
    permission_classes = [AllowAny]

    def post(self, request):
        email, mobile, error_response = _registration_contact(request)
        if error_response:
            return error_response

        email_code = str(request.data.get('email_otp', '')).strip()
        mobile_code = str(request.data.get('mobile_otp', '')).strip()
        if (
            len(email_code) != 6
            or not email_code.isdigit()
            or len(mobile_code) != 6
            or not mobile_code.isdigit()
        ):
            return Response(
                {
                    'success': False,
                    'message': 'Enter both 6-digit verification codes.',
                },
                status=status.HTTP_400_BAD_REQUEST,
            )

        with transaction.atomic():
            record = (
                RegistrationOTP.objects.select_for_update()
                .select_related('user')
                .filter(user__email__iexact=email, user__mobile_number=mobile)
                .first()
            )
            if record is None:
                return Response(
                    {
                        'success': False,
                        'message': 'No pending registration was found for those contacts.',
                    },
                    status=status.HTTP_404_NOT_FOUND,
                )

            if record.user.is_active:
                return Response(
                    {'success': False, 'message': 'This account is already verified.'},
                    status=status.HTTP_409_CONFLICT,
                )

            if record.expires_at <= timezone.now():
                record.delete()
                return Response(
                    {
                        'success': False,
                        'message': 'Verification codes expired. Request new codes.',
                    },
                    status=status.HTTP_400_BAD_REQUEST,
                )

            if record.failed_attempts >= MAX_OTP_ATTEMPTS:
                return Response(
                    {
                        'success': False,
                        'message': 'Too many incorrect attempts. Request new codes.',
                    },
                    status=status.HTTP_429_TOO_MANY_REQUESTS,
                )

            if not (
                check_password(email_code, record.email_code_hash)
                and check_password(mobile_code, record.mobile_code_hash)
            ):
                record.failed_attempts += 1
                record.save(update_fields=['failed_attempts', 'updated_at'])
                return Response(
                    {
                        'success': False,
                        'message': 'One or both verification codes are incorrect.',
                    },
                    status=status.HTTP_400_BAD_REQUEST,
                )

            user = record.user
            user.is_active = True
            user.save(update_fields=['is_active', 'updated_at'])
            record.delete()

        return Response(
            {
                'success': True,
                'message': 'Email and mobile verified. Registration is complete.',
                'tokens': get_tokens_for_user(user),
                'user': UserSerializer(user).data,
            },
            status=status.HTTP_200_OK,
        )


class RegistrationOTPResendView(APIView):
    permission_classes = [AllowAny]

    def post(self, request):
        email, mobile, error_response = _registration_contact(request)
        if error_response:
            return error_response

        user = User.objects.filter(
            email__iexact=email,
            mobile_number=mobile,
            is_active=False,
        ).first()
        if user is None:
            return Response(
                {
                    'success': False,
                    'message': 'No pending registration was found for those contacts.',
                },
                status=status.HTTP_404_NOT_FOUND,
            )

        record = RegistrationOTP.objects.filter(user=user).first()
        if record is None:
            return Response(
                {
                    'success': False,
                    'message': 'Registration verification is unavailable. Please contact support.',
                },
                status=status.HTTP_409_CONFLICT,
            )
        if record.updated_at > timezone.now() - timedelta(seconds=45):
            return Response(
                {
                    'success': False,
                    'message': 'Please wait before requesting new verification codes.',
                },
                status=status.HTTP_429_TOO_MANY_REQUESTS,
            )

        _, email_code, mobile_code = issue_registration_codes(user)
        delivery = deliver_registration_codes(user, email_code, mobile_code)
        delivered = delivery['email_sent'] and delivery['mobile_sent']
        return Response(
            {
                'success': delivered,
                'message': (
                    'New verification codes were sent.'
                    if delivered
                    else 'Could not send both codes. Check the configured email/SMS delivery settings and try again.'
                ),
                'delivery': delivery,
            },
            status=(
                status.HTTP_200_OK
                if delivered
                else status.HTTP_503_SERVICE_UNAVAILABLE
            ),
        )
