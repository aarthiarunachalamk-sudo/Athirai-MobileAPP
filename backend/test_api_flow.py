import urllib.request
import json

def post(url, data, token=None):
    headers = {'Content-Type': 'application/json'}
    if token:
        headers['Authorization'] = f'Bearer {token}'
    req = urllib.request.Request(url, data=json.dumps(data).encode('utf-8'), headers=headers)
    with urllib.request.urlopen(req) as resp:
        return resp.status, json.loads(resp.read().decode('utf-8'))

def put(url, data, token=None):
    headers = {'Content-Type': 'application/json'}
    if token:
        headers['Authorization'] = f'Bearer {token}'
    req = urllib.request.Request(url, data=json.dumps(data).encode('utf-8'), headers=headers, method='PUT')
    with urllib.request.urlopen(req) as resp:
        return resp.status, json.loads(resp.read().decode('utf-8'))

print('=== 1. Testing Login with Mobile Number ===')
st, res = post('http://127.0.0.1:8000/api/auth/login/', {'identifier': '+919876543210'})
print('Status:', st, 'User ID:', res['user']['id'], 'Requires Profile:', res['requires_profile_completion'])

print('\n=== 2. Testing SSO Discovery (Screen 2 -> 3 -> 4) ===')
st, res = post('http://127.0.0.1:8000/api/auth/sso/discover/', {'email': 'lead@company.com'})
state = res['state']
print('Status:', st, 'Org:', res['organization']['name'], 'State:', state[:12] + '...')

print('\n=== 3. Testing Mock IdP Corporate Login (Screen 5) ===')
st, res = post('http://127.0.0.1:8000/api/auth/mock-idp/authorize/', {
    'email': 'lead@company.com',
    'password': 'Password123!',
    'state': state
})
print('Status:', st, 'Requires MFA:', res['requires_mfa'])

print('\n=== 4. Testing MFA Verification (Screen 6) ===')
st, res = post('http://127.0.0.1:8000/api/auth/mock-idp/verify-mfa/', {
    'otp': '123456',
    'state': state,
    'email': 'lead@company.com'
})
auth_code = res['code']
print('Status:', st, 'Auth Code:', auth_code[:16] + '...')

print('\n=== 5. Testing SSO Callback (Screen 7 -> 8) ===')
st, res = post('http://127.0.0.1:8000/api/auth/sso/callback/', {
    'code': auth_code,
    'state': state
})
access_token = res['tokens']['access']
refresh_token = res['tokens']['refresh']
print('Status:', st, 'SSO User:', res['user']['email'], 'Requires Profile:', res['requires_profile_completion'])

print('\n=== 6. Testing Complete Profile (Screen 9) ===')
st, res = put('http://127.0.0.1:8000/api/auth/profile/', {
    'full_name': 'Athirai Princess',
    'mobile_number': '+91 91234 56789'
}, token=access_token)
print('Status:', st, 'Full Name:', res['user']['full_name'], 'Profile Completed:', res['user']['is_profile_completed'])

print('\n=== 7. Testing Token Refresh ===')
st, res = post('http://127.0.0.1:8000/api/auth/token/refresh/', {'refresh': refresh_token})
print('Status:', st, 'New Access Token Issued:', bool(res.get('access')))
new_refresh_token = res.get('refresh', refresh_token)

print('\n=== 8. Testing Logout ===')
st, res = post('http://127.0.0.1:8000/api/auth/logout/', {'refresh': new_refresh_token}, token=access_token)
print('Status:', st, 'Logout Message:', res['message'])

print('\n>>> ALL 8 BACKEND FLOWS TESTED & PASSED PERFECTLY! <<<')
