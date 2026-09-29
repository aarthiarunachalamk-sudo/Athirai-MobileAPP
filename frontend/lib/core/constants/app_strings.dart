/// UI text strings for Athirai Timeless Jewels
class AppStrings {
  AppStrings._();

  static const String appName = 'ATHIRAI';
  static const String appTagline = 'TIMELESS JEWELS';

  // Screen 1: Sign In
  static const String signInTitle = 'Sign in';
  static const String signInSubtitle = 'Enter your email or mobile number to continue';
  static const String emailOrMobileLabel = 'Email or mobile number';
  static const String emailOrMobileHint = 'Enter your email or mobile number';
  static const String continueBtn = 'Continue';
  static const String termsNotice = 'By continuing, you agree to Athirai’s\nConditions of Use and Privacy Notice.';
  static const String termsConditions = 'Conditions of Use';
  static const String privacyNotice = 'Privacy Notice.';
  static const String orDivider = 'OR';
  static const String signInSSO = 'Sign in with SSO';
  static const String useOrgAccount = 'Use your organization account';
  static const String createAccount = 'Create your Athirai account';
  static const String needHelp = 'Need help?';

  // Screen 2: SSO Email
  static const String ssoEmailTitle = 'Sign in with SSO';
  static const String ssoEmailSubtitle = 'Use your organization account to access Athirai.';
  static const String workEmailLabel = 'Work email';
  static const String workEmailHint = 'name@company.com';
  static const String ssoRedirectHelper = 'We’ll securely redirect you to your organization’s sign-in page.';
  static const String backToSignIn = 'Back to Sign In';

  // Screen 3: Finding Organization
  static const String findingOrgTitle = 'Finding your organization...';
  static const String findingOrgSubtitle = 'Please wait while we securely connect you.';

  // Screen 4: Organization Found
  static const String orgFoundTitle = 'Organization Found';
  static const String orgFoundSubtitle = 'Continue using your organization account to sign in to Athirai.';
  static const String continueWithSSO = 'Continue with SSO';
  static const String useAnotherEmail = 'Use another email';

  // Screen 5: Organization Sign-In (External IdP)
  static const String idpSignInTitle = 'Sign in';
  static const String idpSignInSubtitle = 'Use your organization account';
  static const String idpEmailLabel = 'Email';
  static const String idpPasswordLabel = 'Password';
  static const String idpPasswordHint = 'Enter password';
  static const String idpSignInBtn = 'Sign in';
  static const String forgotPassword = 'Forgot password?';
  static const String idpAnotherMethod = 'Sign in with another method';

  // Screen 6: Verification (MFA)
  static const String mfaTitle = 'Verify your identity';
  static const String mfaSubtitle = 'Enter the 6-digit code sent to your registered device.';
  static const String verifyBtn = 'Verify';
  static const String resendCode = 'Didn’t receive the code? Resend code';

  // Screen 7: Processing / Returning
  static const String signingInSecurely = 'Signing you in securely...';
  static const String signingInSubtitle = 'Verifying your organization account. Please don’t close this screen.';

  // Screen 8: SSO Success
  static const String welcomeTitle = 'Welcome to Athirai';
  static const String authSuccessful = 'Authentication Successful';
  static const String authSuccessBody = 'You have securely signed in with your organization account.';
  static const String settingThingsUp = 'Setting things up...';

  // Screen 9: Complete Profile
  static const String completeProfileTitle = 'Complete Your Profile';
  static const String completeProfileSubtitle = 'A few details before you begin your journey.';
  static const String fullNameLabel = 'Full Name';
  static const String fullNameHint = 'Athirai User';
  static const String mobileLabel = 'Mobile Number (Optional)';
  static const String mobileHint = '+91 98765 43210';
  static const String continueToAthirai = 'Continue to Athirai';

  // Screen 10: Journey Entry
  static const String journeyHeading = 'Where Gold Meets You,\nAI, 3D & Imagination';
  static const String beginJourneyBtn = 'BEGIN JOURNEY';

  // Validation Messages
  static const String errorEmptyIdentifier = 'Please enter your email or mobile number.';
  static const String errorInvalidEmail = 'Enter a valid email address.';
  static const String errorOrgNotFound = 'We couldn’t find an organization for this email.';
  static const String errorGenericAuth = 'We couldn’t sign you in. Please try again.';
  static const String errorSessionExpired = 'Your session has expired. Please sign in again.';
}
