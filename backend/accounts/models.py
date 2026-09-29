from django.db import models
from django.contrib.auth.models import AbstractUser, BaseUserManager
from django.utils.translation import gettext_lazy as _

class UserManager(BaseUserManager):
    """Custom manager for Athirai User model where email is the unique identifier."""
    def create_user(self, email=None, mobile_number=None, password=None, **extra_fields):
        if not email and not mobile_number:
            raise ValueError(_('Users must have either an email address or mobile number'))
        
        if email:
            email = self.normalize_email(email)
            
        user = self.model(email=email, mobile_number=mobile_number, **extra_fields)
        if password:
            user.set_password(password)
        else:
            user.set_unusable_password()
        user.save(using=self._db)
        return user

    def create_superuser(self, email, password=None, **extra_fields):
        extra_fields.setdefault('is_staff', True)
        extra_fields.setdefault('is_superuser', True)
        extra_fields.setdefault('is_active', True)
        extra_fields.setdefault('is_profile_completed', True)

        if extra_fields.get('is_staff') is not True:
            raise ValueError(_('Superuser must have is_staff=True.'))
        if extra_fields.get('is_superuser') is not True:
            raise ValueError(_('Superuser must have is_superuser=True.'))

        return self.create_user(email=email, password=password, **extra_fields)


class User(AbstractUser):
    """
    Athirai Custom User Model.
    Supports email or mobile number login, SSO federation, and profile status tracking.
    """
    username = None  # Remove default username
    email = models.EmailField(_('email address'), unique=True, null=True, blank=True)
    mobile_number = models.CharField(_('mobile number'), max_length=25, unique=True, null=True, blank=True)
    full_name = models.CharField(_('full name'), max_length=150, blank=True, default='')
    avatar_url = models.URLField(_('avatar url'), max_length=500, blank=True, null=True)
    
    # SSO tracking
    is_sso_user = models.BooleanField(default=False)
    sso_provider = models.CharField(max_length=50, blank=True, default='')
    organization_domain = models.CharField(max_length=100, blank=True, default='')
    
    # First time login / profile completion flow (Screen 9 in reference)
    is_profile_completed = models.BooleanField(default=False)
    
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)

    USERNAME_FIELD = 'email'
    REQUIRED_FIELDS = []

    objects = UserManager()

    def __str__(self):
        return self.email or self.mobile_number or f'User {self.id}'


class Organization(models.Model):
    """
    Enterprise SSO Organization configuration.
    Maps company domain (e.g. company.com) to identity provider settings.
    """
    PROVIDER_CHOICES = (
        ('microsoft', 'Microsoft Entra ID / Azure AD'),
        ('google', 'Google Workspace'),
        ('okta', 'Okta Identity Cloud'),
        ('oidc', 'Generic OpenID Connect'),
    )

    name = models.CharField(max_length=200)
    domain = models.CharField(max_length=100, unique=True, db_index=True)
    provider = models.CharField(max_length=50, choices=PROVIDER_CHOICES, default='microsoft')
    client_id = models.CharField(max_length=255, blank=True, default='')
    client_secret = models.CharField(max_length=255, blank=True, default='')
    authorization_url = models.URLField(max_length=500, blank=True, default='')
    token_url = models.URLField(max_length=500, blank=True, default='')
    userinfo_url = models.URLField(max_length=500, blank=True, default='')
    is_active = models.BooleanField(default=True)
    created_at = models.DateTimeField(auto_now_add=True)

    def __str__(self):
        return f"{self.name} ({self.domain}) [{self.provider}]"


class SSOState(models.Model):
    """
    Tracks state and PKCE verifier for SSO OAuth2 / OIDC authorization codes.
    """
    state = models.CharField(max_length=128, unique=True, db_index=True)
    email = models.CharField(max_length=255)
    domain = models.CharField(max_length=100)
    provider = models.CharField(max_length=50)
    code_verifier = models.CharField(max_length=128, blank=True, default='')
    is_consumed = models.BooleanField(default=False)
    created_at = models.DateTimeField(auto_now_add=True)

    def __str__(self):
        return f"SSOState({self.state[:8]}... for {self.email})"
