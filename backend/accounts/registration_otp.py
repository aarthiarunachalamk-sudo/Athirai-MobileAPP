import logging
import re
import secrets
from datetime import timedelta

import requests
from django.conf import settings
from django.contrib.auth.hashers import make_password
from django.core.exceptions import ImproperlyConfigured
from django.core.mail import send_mail
from django.utils import timezone

from .models import RegistrationOTP

logger = logging.getLogger(__name__)
OTP_LIFETIME = timedelta(minutes=10)


def issue_registration_codes(user):
    email_code = f'{secrets.randbelow(1_000_000):06d}'
    mobile_code = f'{secrets.randbelow(1_000_000):06d}'
    defaults = {
        'email_code_hash': make_password(email_code),
        'mobile_code_hash': make_password(mobile_code),
        'expires_at': timezone.now() + OTP_LIFETIME,
        'failed_attempts': 0,
    }
    record, created = RegistrationOTP.objects.get_or_create(
        user=user,
        defaults=defaults,
    )
    if not created:
        for field, value in defaults.items():
            setattr(record, field, value)
        record.save()
    return record, email_code, mobile_code


def normalize_mobile_number(mobile_number):
    digits = re.sub(r'\D', '', mobile_number)
    if len(digits) == 10:
        return f'+91{digits}'
    if len(digits) == 12 and digits.startswith('91'):
        return f'+{digits}'
    if mobile_number.strip().startswith('+') and 8 <= len(digits) <= 15:
        return f'+{digits}'
    raise ValueError('Enter a valid international mobile number.')


def send_email_code(email, code):
    host = getattr(settings, 'EMAIL_HOST', '')
    sender = getattr(settings, 'DEFAULT_FROM_EMAIL', '')
    if not host or not sender:
        raise ImproperlyConfigured('Email delivery is not configured.')
    sent = send_mail(
        subject='Your Athirai registration verification code',
        message=(
            f'Your Athirai email verification code is {code}. '
            'It expires in 10 minutes. If you did not create this account, '
            'you can ignore this message.'
        ),
        from_email=sender,
        recipient_list=[email],
        fail_silently=False,
    )
    if sent != 1:
        raise RuntimeError('The email service did not accept the verification email.')


def send_mobile_code(mobile_number, code):
    account_sid = getattr(settings, 'TWILIO_ACCOUNT_SID', '')
    auth_token = getattr(settings, 'TWILIO_AUTH_TOKEN', '')
    from_number = getattr(settings, 'TWILIO_FROM_NUMBER', '')
    if not account_sid or not auth_token or not from_number:
        raise ImproperlyConfigured('SMS delivery is not configured.')

    response = requests.post(
        f'https://api.twilio.com/2010-04-01/Accounts/{account_sid}/Messages.json',
        auth=(account_sid, auth_token),
        data={
            'From': from_number,
            'To': normalize_mobile_number(mobile_number),
            'Body': (
                f'Your Athirai mobile verification code is {code}. '
                'It expires in 10 minutes.'
            ),
        },
        timeout=(3, 10),
    )
    response.raise_for_status()
    if response.json().get('status') in {'failed', 'undelivered'}:
        raise RuntimeError('Twilio could not deliver the verification SMS.')


def deliver_registration_codes(user, email_code, mobile_code):
    delivery = {'email_sent': False, 'mobile_sent': False}
    try:
        send_email_code(user.email, email_code)
        delivery['email_sent'] = True
    except Exception:
        logger.exception('Could not send registration email OTP for user %s', user.pk)

    try:
        send_mobile_code(user.mobile_number, mobile_code)
        delivery['mobile_sent'] = True
    except Exception:
        logger.exception('Could not send registration SMS OTP for user %s', user.pk)

    return delivery
