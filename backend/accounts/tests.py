from django.test import TestCase
from django.contrib.auth import get_user_model
from rest_framework.test import APIClient
from rest_framework import status
from accounts.models import Organization, SSOState

User = get_user_model()

class AthiraiAuthTests(TestCase):
    def setUp(self):
        self.client = APIClient()
        self.org = Organization.objects.create(
            name="Acme Luxury Group",
            domain="company.com",
            provider="microsoft",
            authorization_url="/api/auth/mock-idp/authorize/",
            is_active=True
        )

    def test_login_with_email(self):
        response = self.client.post('/api/auth/login/', {'identifier': 'customer@athirai.com'})
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        self.assertTrue(response.data['success'])
        self.assertIn('tokens', response.data)
        self.assertIn('access', response.data['tokens'])

    def test_login_with_phone(self):
        response = self.client.post('/api/auth/login/', {'identifier': '+919876543210'})
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        self.assertTrue(response.data['success'])
        self.assertIn('access', response.data['tokens'])

    def test_sso_discover_success(self):
        response = self.client.post('/api/auth/sso/discover/', {'email': 'designer@company.com'})
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        self.assertTrue(response.data['success'])
        self.assertEqual(response.data['organization']['name'], 'Acme Luxury Group')
        self.assertIn('authorization_url', response.data)
        self.assertIn('state', response.data)

    def test_sso_discover_public_email_rejected(self):
        response = self.client.post('/api/auth/sso/discover/', {'email': 'user@gmail.com'})
        self.assertEqual(response.status_code, status.HTTP_400_BAD_REQUEST)
        self.assertFalse(response.data['success'])

    def test_sso_callback_flow(self):
        # 1. Discover
        disc_res = self.client.post('/api/auth/sso/discover/', {'email': 'lead@company.com'})
        state = disc_res.data['state']

        # 2. Callback
        callback_res = self.client.post('/api/auth/sso/callback/', {
            'code': 'mock_code_12345',
            'state': state
        })
        self.assertEqual(callback_res.status_code, status.HTTP_200_OK)
        self.assertTrue(callback_res.data['success'])
        self.assertIn('tokens', callback_res.data)
        self.assertTrue(callback_res.data['requires_profile_completion'])

    def test_update_profile(self):
        user = User.objects.create_user(email='test@athirai.com')
        from rest_framework_simplejwt.tokens import RefreshToken
        token = str(RefreshToken.for_user(user).access_token)
        self.client.credentials(HTTP_AUTHORIZATION=f'Bearer {token}')

        res = self.client.put('/api/auth/profile/', {
            'full_name': 'Athirai Queen',
            'mobile_number': '+91 99999 88888',
        })
        self.assertEqual(res.status_code, status.HTTP_200_OK)
        self.assertTrue(res.data['success'])
        self.assertEqual(res.data['user']['full_name'], 'Athirai Queen')
        self.assertTrue(res.data['user']['is_profile_completed'])
