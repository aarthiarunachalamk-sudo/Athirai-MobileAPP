from unittest.mock import patch

from django.contrib.auth import get_user_model
from django.test import TestCase
from rest_framework.test import APIClient

User = get_user_model()


class RegistrationOTPTests(TestCase):
    def setUp(self):
        self.client = APIClient()
        self.payload = {
            'email': 'new.member@example.com',
            'mobile_number': '9876543210',
            'password': 'Jewels123',
            'confirm_password': 'Jewels123',
            'first_name': 'New',
            'last_name': 'Member',
        }
        self.sent_codes = {}

    def capture_email(self, email, code):
        self.sent_codes['email'] = (email, code)

    def capture_sms(self, mobile, code):
        self.sent_codes['mobile'] = (mobile, code)

    @patch('accounts.registration_otp.send_mobile_code')
    @patch('accounts.registration_otp.send_email_code')
    def test_both_codes_are_required_before_account_is_activated(
        self,
        send_email,
        send_mobile,
    ):
        send_email.side_effect = self.capture_email
        send_mobile.side_effect = self.capture_sms

        registration = self.client.post('/api/auth/register/', self.payload)
        self.assertEqual(registration.status_code, 201)
        self.assertEqual(
            registration.data['delivery'],
            {'email_sent': True, 'mobile_sent': True},
        )
        self.assertNotIn('tokens', registration.data)

        user = User.objects.get(email=self.payload['email'])
        self.assertFalse(user.is_active)
        self.assertEqual(user.mobile_number, '+919876543210')

        rejected = self.client.post(
            '/api/auth/register/verify-otp/',
            {
                'email': self.payload['email'],
                'mobile_number': self.payload['mobile_number'],
                'email_otp': '000000',
                'mobile_otp': '000000',
            },
        )
        self.assertEqual(rejected.status_code, 400)
        user.refresh_from_db()
        self.assertFalse(user.is_active)

        email, email_code = self.sent_codes['email']
        mobile, mobile_code = self.sent_codes['mobile']
        self.assertEqual(email, self.payload['email'])
        self.assertEqual(mobile, '+919876543210')
        verified = self.client.post(
            '/api/auth/register/verify-otp/',
            {
                'email': email,
                'mobile_number': mobile,
                'email_otp': email_code,
                'mobile_otp': mobile_code,
            },
        )
        self.assertEqual(verified.status_code, 200)
        self.assertTrue(verified.data['success'])
        self.assertIn('tokens', verified.data)
        user.refresh_from_db()
        self.assertTrue(user.is_active)

    @patch('accounts.registration_otp.send_mobile_code')
    @patch('accounts.registration_otp.send_email_code')
    def test_pending_registration_cannot_login(self, send_email, send_mobile):
        send_email.side_effect = self.capture_email
        send_mobile.side_effect = self.capture_sms
        self.client.post('/api/auth/register/', self.payload)

        response = self.client.post(
            '/api/auth/login/',
            {
                'identifier': self.payload['email'],
                'password': self.payload['password'],
            },
        )
        self.assertEqual(response.status_code, 403)
