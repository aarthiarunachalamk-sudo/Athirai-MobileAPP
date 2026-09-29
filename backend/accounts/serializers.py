import re
from rest_framework import serializers
from django.contrib.auth import get_user_model
from .models import Organization

User = get_user_model()

class UserSerializer(serializers.ModelSerializer):
    class Meta:
        model = User
        fields = [
            'id',
            'email',
            'mobile_number',
            'full_name',
            'avatar_url',
            'is_sso_user',
            'sso_provider',
            'organization_domain',
            'is_profile_completed',
            'created_at',
        ]
        read_only_fields = ['id', 'is_sso_user', 'sso_provider', 'organization_domain', 'created_at']


class LoginRequestSerializer(serializers.Serializer):
    """
    Accepts email or mobile number from the Athirai main login screen.
    """
    identifier = serializers.CharField(max_length=255, required=True)
    password = serializers.CharField(max_length=128, required=False, allow_blank=True, default='')

    def validate_identifier(self, value):
        value = value.strip()
        if not value:
            raise serializers.ValidationError("Please enter your email or mobile number.")

        email_pattern = r'^[a-zA-Z0-9_.+-]+@[a-zA-Z0-9-]+\.[a-zA-Z0-9-.]+$'
        phone_pattern = r'^\+?[0-9\s\-()]{7,20}$'

        is_email = bool(re.match(email_pattern, value))
        is_phone = bool(re.match(phone_pattern, value))

        if not is_email and not is_phone:
            raise serializers.ValidationError("Please enter a valid email address or mobile number.")

        return value


class RegisterRequestSerializer(serializers.Serializer):
    email = serializers.EmailField(required=True)
    password = serializers.CharField(max_length=128, required=True, min_length=6)
    full_name = serializers.CharField(max_length=150, required=False, default='')
    mobile_number = serializers.CharField(max_length=25, required=False, allow_blank=True, default='')

    def validate_email(self, value):
        if User.objects.filter(email__iexact=value).exists():
            raise serializers.ValidationError("An account with this email already exists.")
        return value.lower()


class SSODiscoverRequestSerializer(serializers.Serializer):
    """
    Endpoint: POST /api/auth/sso/discover/
    Input: {"email": "name@company.com"}
    """
    email = serializers.EmailField(required=True)

    def validate_email(self, value):
        val = value.strip().lower()
        if '@' not in val:
            raise serializers.ValidationError("Enter a valid email address.")
        return val


class SSOCallbackRequestSerializer(serializers.Serializer):
    """
    Endpoint: POST /api/auth/sso/callback/
    Receives authorization code & state after IdP redirect.
    """
    code = serializers.CharField(required=True)
    state = serializers.CharField(required=True)


class ProfileUpdateRequestSerializer(serializers.ModelSerializer):
    class Meta:
        model = User
        fields = ['full_name', 'mobile_number', 'avatar_url', 'is_profile_completed']

    def validate_full_name(self, value):
        if not value.strip():
            raise serializers.ValidationError("Full name is required.")
        return value.strip()
