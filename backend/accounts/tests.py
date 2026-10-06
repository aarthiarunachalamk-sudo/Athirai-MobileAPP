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

    def test_password_login_rejects_invalid_credentials(self):
        User.objects.create_user(
            email='member@athirai.com',
            password='CorrectHorse9',
            mobile_number='+919111122222',
        )

        wrong_password = self.client.post('/api/auth/login/', {
            'identifier': 'member@athirai.com',
            'password': 'incorrect',
        })
        unknown_user = self.client.post('/api/auth/login/', {
            'identifier': 'unknown@athirai.com',
            'password': 'CorrectHorse9',
        })

        self.assertEqual(wrong_password.status_code, status.HTTP_401_UNAUTHORIZED)
        self.assertEqual(unknown_user.status_code, status.HTTP_401_UNAUTHORIZED)
        self.assertFalse(User.objects.filter(email='unknown@athirai.com').exists())

    def test_register_persists_profile_and_address_details(self):
        response = self.client.post('/api/auth/register/', {
            'first_name': 'Ananya',
            'last_name': 'Raman',
            'full_name': 'Ananya Raman',
            'gender': 'Female',
            'mobile_number': '+919222233333',
            'date_of_birth': '1998-04-12',
            'door_no': '12B',
            'street_name': 'Temple Road',
            'pincode': '636003',
            'town': 'Ammapet',
            'city': 'Salem',
            'district': 'Salem',
            'state': 'Tamil Nadu',
            'email': 'ananya@athirai.com',
            'password': 'Jewels123',
            'confirm_password': 'Jewels123',
        })

        self.assertEqual(response.status_code, status.HTTP_201_CREATED)
        user = User.objects.get(email='ananya@athirai.com')
        self.assertEqual(user.full_name, 'Ananya Raman')
        self.assertEqual(user.gender, 'Female')
        self.assertEqual(user.date_of_birth.isoformat(), '1998-04-12')
        self.assertEqual(user.pincode, '636003')
        self.assertEqual(user.city, 'Salem')
        self.assertTrue(user.check_password('Jewels123'))
        self.assertEqual(response.data['user']['street_name'], 'Temple Road')

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

    def test_selfie_upload_and_avatar_creation(self):
        import io
        from PIL import Image
        from django.core.files.uploadedfile import SimpleUploadedFile

        # Create sample selfie
        img = Image.new('RGB', (240, 240), color=(200, 160, 130))
        buf = io.BytesIO()
        img.save(buf, format='JPEG')
        uploaded = SimpleUploadedFile('my_selfie.jpg', buf.getvalue(), content_type='image/jpeg')

        user = User.objects.create_user(email='patron@athirai.com')
        from rest_framework_simplejwt.tokens import RefreshToken
        token = str(RefreshToken.for_user(user).access_token)
        self.client.credentials(HTTP_AUTHORIZATION=f'Bearer {token}')

        # 1. Upload first selfie
        res = self.client.post('/api/auth/selfie/upload/', {'selfie': uploaded})
        self.assertEqual(res.status_code, status.HTTP_201_CREATED)
        self.assertTrue(res.data['success'])
        self.assertTrue(res.data['is_latest'])
        self.assertIn('selfie_url', res.data)
        self.assertIn('avatar_url', res.data)
        first_avatar_url = res.data['avatar_url']

        # 2. Upload second selfie (should become new latest)
        buf2 = io.BytesIO()
        img.save(buf2, format='JPEG')
        uploaded2 = SimpleUploadedFile('second_selfie.jpg', buf2.getvalue(), content_type='image/jpeg')
        res2 = self.client.post('/api/auth/selfie/upload/', {'selfie': uploaded2})
        self.assertEqual(res2.status_code, status.HTTP_201_CREATED)
        self.assertTrue(res2.data['is_latest'])

        # 3. Verify latest selfie endpoint returns newest
        latest_res = self.client.get('/api/auth/selfie/latest/')
        self.assertEqual(latest_res.status_code, status.HTTP_200_OK)
        self.assertTrue(latest_res.data['selfie']['is_latest'])

        # 4. Verify all selfie records are stored ("selfie images ellam")
        list_res = self.client.get('/api/auth/selfie/list/')
        self.assertEqual(list_res.status_code, status.HTTP_200_OK)
        self.assertEqual(list_res.data['count'], 2)
