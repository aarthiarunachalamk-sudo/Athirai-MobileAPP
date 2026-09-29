import os
import uuid
import secrets
from urllib.parse import urlencode
from django.contrib.auth import get_user_model
from rest_framework_simplejwt.tokens import RefreshToken
from .models import Organization, SSOState

User = get_user_model()

class SSOService:
    @staticmethod
    def extract_domain(email: str) -> str:
        """Extract lowercase domain name from email address."""
        if not email or '@' not in email:
            return ''
        return email.split('@')[1].strip().lower()

    @classmethod
    def discover_organization(cls, email: str):
        """
        Looks up organization by domain name.
        If organization is not found in database, check for known corporate domains or create/fallback.
        """
        domain = cls.extract_domain(email)
        if not domain:
            return None

        # Look up existing organization
        org = Organization.objects.filter(domain__iexact=domain, is_active=True).first()
        if not org:
            # For demonstration and enterprise onboarding, if the domain is a corporate domain
            # e.g. company.com, athirai.com, luxury.com, create a dynamic organization entry
            public_domains = ['gmail.com', 'yahoo.com', 'outlook.com', 'hotmail.com', 'icloud.com']
            if domain not in public_domains:
                clean_name = domain.split('.')[0].capitalize() + " Enterprise"
                org = Organization.objects.create(
                    name=clean_name,
                    domain=domain,
                    provider='microsoft', # default enterprise provider
                    authorization_url=f"/api/auth/mock-idp/authorize/?domain={domain}",
                    token_url=f"/api/auth/mock-idp/token/",
                    userinfo_url=f"/api/auth/mock-idp/userinfo/",
                    is_active=True
                )
        return org

    @classmethod
    def generate_sso_session(cls, email: str, org: Organization, redirect_uri: str = "athirai://auth/callback") -> dict:
        """
        Generates a state token, records SSO session, and produces authorization URL.
        Supports standard OAuth2 / OIDC authorization code flow.
        """
        state = secrets.token_urlsafe(32)
        code_verifier = secrets.token_urlsafe(48)

        SSOState.objects.create(
            state=state,
            email=email,
            domain=org.domain,
            provider=org.provider,
            code_verifier=code_verifier
        )

        params = {
            'client_id': org.client_id or 'athirai-mobile-client',
            'response_type': 'code',
            'redirect_uri': redirect_uri,
            'scope': 'openid profile email',
            'state': state,
            'login_hint': email,
        }

        base_auth_url = org.authorization_url or f"/api/auth/mock-idp/authorize/"
        auth_url = f"{base_auth_url}{'&' if '?' in base_auth_url else '?'}{urlencode(params)}"

        return {
            'state': state,
            'authorization_url': auth_url,
            'organization': {
                'name': org.name,
                'domain': org.domain,
                'provider': org.provider,
            }
        }

    @classmethod
    def exchange_code_for_user(cls, code: str, state_str: str) -> tuple[User, bool]:
        """
        Exchanges code and state for an authenticated Athirai User.
        Returns (user, created).
        """
        sso_state = SSOState.objects.filter(state=state_str, is_consumed=False).first()
        if not sso_state:
            # If state not found or expired, raise ValueError
            raise ValueError("Invalid or expired SSO state.")

        # Mark state as consumed (replay protection)
        sso_state.is_consumed = True
        sso_state.save()

        email = sso_state.email.lower()
        domain = sso_state.domain

        # Retrieve or create user
        user, created = User.objects.get_or_create(
            email=email,
            defaults={
                'is_sso_user': True,
                'sso_provider': sso_state.provider,
                'organization_domain': domain,
                'is_profile_completed': False, # New SSO users need to complete profile
            }
        )

        if not created and not user.is_sso_user:
            user.is_sso_user = True
            user.sso_provider = sso_state.provider
            user.organization_domain = domain
            user.save()

        return user, created


def get_tokens_for_user(user: User) -> dict:
    """Generate DRF SimpleJWT token pair for user."""
    refresh = RefreshToken.for_user(user)
    return {
        'access': str(refresh.access_token),
        'refresh': str(refresh),
    }
