# ATHIRAI – TIMELESS JEWELS (Backend API)

Production-ready Django REST Framework backend providing JWT authentication, SSO discovery, OAuth2/OIDC federation, profile management, and mock IdP identity verification.

---

## 🏛 Architecture Overview

- **Framework**: Django 5.x & Django REST Framework (DRF)
- **Token Standard**: JSON Web Tokens (JWT) with PyJWT & `djangorestframework-simplejwt`
- **SSO Architecture**:
  - Domain-based dynamic organization lookup (`/api/auth/sso/discover/`)
  - Multi-provider capability (Microsoft Entra ID / Azure AD, Google Workspace, Okta, generic OIDC)
  - Replay-protected state & PKCE verification tokens (`SSOState`)
  - Mock IdP simulation suite for local offline end-to-end testing
- **Security**:
  - Argon2/PBKDF2 password hashing
  - Blacklist protection on refresh tokens (`token_blacklist`)
  - Strict input sanitization and regex validation for email and international mobile phone formats

---

## 🚀 Quick Start Instructions

### 1. Requirements & Setup
```bash
cd backend
python -m venv venv

# Windows:
venv\Scripts\activate

# macOS / Linux:
source venv/bin/activate

pip install -r requirements.txt
```

### 2. Environment Configuration
Copy `.env.example` to `.env`:
```bash
copy .env.example .env
```

### 3. Migrations & Seed Data
```bash
python manage.py makemigrations accounts
python manage.py migrate
python manage.py seed_data
```

### 4. Run Development Server
```bash
python manage.py runserver 127.0.0.1:8000
```

---

## 📡 REST API Endpoints

### 1. Main Login
- **Endpoint**: `POST /api/auth/login/`
- **Description**: Accepts either email address or mobile number. Auto-creates lightweight user on first sign-in.
- **Request**:
```json
{
  "identifier": "customer@athirai.com",
  "password": "" 
}
```
- **Response**:
```json
{
  "success": true,
  "message": "Signed in successfully",
  "tokens": {
    "access": "eyJhbGciOi...",
    "refresh": "eyJhbGciOi..."
  },
  "user": {
    "id": 1,
    "email": "customer@athirai.com",
    "mobile_number": null,
    "full_name": "",
    "is_sso_user": false,
    "is_profile_completed": false
  },
  "requires_profile_completion": true
}
```

### 2. User Registration
- **Endpoint**: `POST /api/auth/register/`
- **Request**:
```json
{
  "email": "patron@athirai.com",
  "password": "Password123!",
  "full_name": "Athirai VIP Patron",
  "mobile_number": "+91 98765 43210"
}
```

### 3. Enterprise SSO Discovery
- **Endpoint**: `POST /api/auth/sso/discover/`
- **Request**:
```json
{
  "email": "designer@company.com"
}
```
- **Response**:
```json
{
  "success": true,
  "organization": {
    "name": "Acme Luxury Enterprise",
    "domain": "company.com",
    "provider": "microsoft"
  },
  "authorization_url": "/api/auth/mock-idp/authorize/?domain=company.com&...",
  "state": "wHjB8_..."
}
```

### 4. SSO Callback
- **Endpoint**: `POST /api/auth/sso/callback/`
- **Request**:
```json
{
  "code": "athirai_authcode_...",
  "state": "wHjB8_..."
}
```

### 5. Profile Retrieval & Update
- **Endpoint**: `GET /api/auth/me/` & `PUT /api/auth/profile/`
- **Headers**: `Authorization: Bearer <access_token>`
- **Request (PUT)**:
```json
{
  "full_name": "Athirai Queen",
  "mobile_number": "+91 98765 43210",
  "avatar_url": null
}
```

### 6. Mock Enterprise Identity Provider (IdP)
- `POST /api/auth/mock-idp/authorize/`: Simulates corporate credentials verification and triggers MFA.
- `POST /api/auth/mock-idp/verify-mfa/`: Accepts 6-digit OTP and generates authorization code.

---

## 🧪 Running Tests
```bash
python manage.py test accounts
```
