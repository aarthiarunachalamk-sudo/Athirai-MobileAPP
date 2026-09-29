# ATHIRAI – TIMELESS JEWELS

> **Production-Ready Mobile Application & SSO Backend**  
> Luxury jewelry aesthetic featuring celestial cosmic ambiance, black & metallic gold palette, glowing borders, smooth particle glitter animations, and an enterprise SSO federation architecture.

---

## 💎 Project Overview

ATHIRAI is an elite mobile jewelry application built with:
- **Frontend**: Flutter & Dart (Mobile-first, Android & iOS supported, responsive across all screen dimensions)
- **Backend**: Python 3, Django 5.x, Django REST Framework, SimpleJWT, and CORS headers
- **Branding**: Exclusively branded as **ATHIRAI – TIMELESS JEWELS**

---

## 📱 Complete 10-Screen Mobile Flow

The application implements the complete user journey:

1. **Sign In (Main Screen)**:
   - Celestial cosmic background with golden galaxy ribbon, crescent moon, Saturn, and glowing Earth sunrise horizon
   - Continuous animated golden glitter/sparkle layer (`GoldenGlitterBackground`)
   - Centered metallic gold Athirai lotus emblem (`AthiraiLogo`)
   - "Email or mobile number" luxury input container with gold border and focus glow
   - Pill-shaped gradient "Continue" CTA (`GoldPrimaryButton`)
   - Interactive Terms of Use & Privacy Notice links
   - Thin gold "OR" divider
   - Outlined "Sign in with SSO" button with building icon
   - "Create your Athirai account" button
   - Underlined gold "Need help?" concierge modal

2. **Sign in with SSO (Enter Work Email)**:
   - Dedicated work email input field (`name@company.com`)
   - Real-time domain validation
   - Secure redirect badge information card
   - "Back to Sign In" quick navigation

3. **Finding your organization... (Loading)**:
   - Athirai logo with celestial cosmic background
   - Center rotating and pulsating luminous gold sweep ring (`LoadingGoldRing`)
   - Smooth asynchronous organization resolution

4. **Organization Found**:
   - Elevated dark luxury card with gold apartment/building icon
   - Dynamic organization name retrieved from backend
   - "Continue with SSO" primary button
   - "Use another email" option

5. **Organization Sign-In (External Identity Provider)**:
   - Enterprise-grade IdP screen (Microsoft Entra ID / Okta style)
   - Read-only work email & secure password fields
   - Corporate "Sign in" action

6. **Verification (MFA)**:
   - Security shield badge
   - 6-digit OTP square input fields with automatic focus advancement
   - "Verify" action & resend code flow

7. **Returning to Athirai (Processing)**:
   - "Signing you in securely..."
   - Luminous gold sweep ring with particle aura
   - Backend OAuth2 code exchange and token issuance

8. **SSO Success**:
   - Animated pulsing gold badge with checkmark (`✓`)
   - "Welcome to Athirai" & "Authentication Successful"
   - Automatic transition to profile completion or home entry

9. **Complete Your Profile (First Time Only)**:
   - Patron portrait avatar with gold frame and edit badge
   - "Full Name" prefilled/editable
   - "Work Email" (locked field with padlock icon)
   - "Mobile Number (Optional)"
   - "Continue to Athirai" CTA

10. **Athirai Entry (Begin Journey)**:
    - Celestial background with grand golden Saturn and orbital rings
    - "Where Gold Meets You, AI, 3D & Imagination"
    - "BEGIN JOURNEY" gold gradient CTA
    - Interactive High Jewelry Atelier modal & sign-out controls

---

## 🏗 Repository Structure

```
c:/ATHIRAI/
├── backend/                       # Python Django REST Backend
│   ├── config/                    # Project settings, URLs, WSGI
│   │   ├── settings.py
│   │   ├── urls.py
│   │   └── wsgi.py
│   ├── accounts/                  # Auth & SSO application
│   │   ├── models.py              # User, Organization, SSOState
│   │   ├── serializers.py         # DRF serializers
│   │   ├── views.py               # Login, Register, SSO Discover, Callback, Profile, Mock IdP
│   │   ├── urls.py                # REST API routes
│   │   ├── services.py            # SSO token & domain resolution services
│   │   ├── tests.py               # Automated test suite
│   │   └── management/commands/   # seed_data command
│   ├── db.sqlite3                 # Local database (pre-seeded)
│   ├── manage.py
│   ├── requirements.txt
│   └── .env
│
└── frontend/                      # Flutter Dart Mobile Application
    ├── lib/
    │   ├── main.dart              # Entrypoint with ProviderScope & luxury theme
    │   ├── core/
    │   │   ├── constants/         # AppColors, AppStrings, AppAssets
    │   │   ├── theme/             # AppTheme (Cinzel, Cormorant Garamond, Inter)
    │   │   └── network/           # ApiClient, ApiEndpoints (with auto-host discovery)
    │   └── features/auth/
    │       ├── data/
    │       │   ├── models/        # UserModel, OrganizationModel, AuthTokensModel
    │       │   ├── repositories/  # AuthRepository
    │       │   └── services/      # SecureStorageService (Keychain & EncryptedSharedPreferences)
    │       └── presentation/
    │           ├── controllers/   # AuthController & AuthState (Riverpod 3 Notifier)
    │           ├── screens/       # All 10 flow screens + RegisterScreen
    │           └── widgets/       # GoldenGlitterBackground, LoadingGoldRing, GoldPrimaryButton, etc.
    ├── assets/images/             # High-resolution cosmic background, logo, and avatar
    ├── test/widget_test.dart      # Flutter smoke tests
    └── pubspec.yaml               # Dependencies & assets configuration
```

---

## 🛠 Running the Application

### Step 1: Start the Django Backend
```bash
cd c:\ATHIRAI\backend
python manage.py runserver 127.0.0.1:8000
```
*The backend is pre-seeded with test organizations (`company.com`, `athirai.com`, `contoso.com`) and test accounts.*

### Step 2: Run Flutter Frontend

#### On Windows Desktop:
```bash
cd c:\ATHIRAI\frontend
flutter run -d windows
```

#### On Web (Chrome):
```bash
cd c:\ATHIRAI\frontend
flutter run -d chrome
```

#### On Android (Emulator or Device):
```bash
cd c:\ATHIRAI\frontend
flutter run -d android
```

#### On iOS (Simulator or Device):
```bash
cd c:\ATHIRAI\frontend
flutter run -d ios
```

---

## 🔐 Security Features

1. **Zero Plaintext Credentials**: JWT access tokens and refresh tokens are stored exclusively in platform-native secure storage (`flutter_secure_storage`).
2. **Replay-Protected SSO**: SSO authorization codes and state parameters are single-use (`is_consumed = True`).
3. **Automatic 401 Interception**: The HTTP client automatically attempts a silent token refresh upon encountering HTTP 401 Unauthorized before falling back to re-authentication.
4. **Isolated Particle Layer**: Glitter animations utilize `RepaintBoundary` and precomputed math coordinates to guarantee smooth 60 FPS performance without rebuilding UI widgets.
