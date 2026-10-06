import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/constants/app_assets.dart';
import 'core/constants/app_colors.dart';
import 'core/theme/app_theme.dart';
import 'features/auth/data/services/secure_storage_service.dart';
import 'features/auth/presentation/controllers/auth_controller.dart';
import 'features/shop/presentation/screens/athirai_flow_container.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  // Set immersive status bar overlay for edge-to-edge luxury experience
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      statusBarBrightness: Brightness.dark,
      systemNavigationBarColor: Color(0xFF030303),
      systemNavigationBarIconBrightness: Brightness.light,
    ),
  );

  runApp(
    const ProviderScope(
      child: AthiraiJewelsApp(),
    ),
  );
}

class AthiraiJewelsApp extends StatelessWidget {
  const AthiraiJewelsApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ATHIRAI – TIMELESS JEWELS',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.luxuryDarkTheme,
      home: const AthiraiGatekeeper(),
    );
  }
}

/// Amazon-style Persistent Session Gatekeeper:
/// - Checks if the user has an active authenticated session or access token.
/// - If authenticated: Navigates straight to the Dashboard (Screen index 1).
///   Even if the app is killed and restarted, the dashboard opens automatically.
/// - If not authenticated (or after explicit logout): Navigates to the Welcome & Login flow (Screen index 0).
class AthiraiGatekeeper extends ConsumerStatefulWidget {
  const AthiraiGatekeeper({super.key});

  @override
  ConsumerState<AthiraiGatekeeper> createState() => _AthiraiGatekeeperState();
}

class _AthiraiGatekeeperState extends ConsumerState<AthiraiGatekeeper> {
  bool _isChecking = true;
  bool _isAuthenticated = false;

  @override
  void initState() {
    super.initState();
    _checkActiveSession();
  }

  Future<void> _checkActiveSession() async {
    final storage = SecureStorageService();
    final isSessionActive = await storage.isSessionActive();
    final token = await storage.getAccessToken();

    // If an active session flag is set OR a valid access token exists, directly enter dashboard
    final hasSession = isSessionActive || (token != null && token.isNotEmpty);

    if (hasSession) {
      // Opportunistically refresh user profile in background
      ref.read(authControllerProvider.notifier).restoreSession();
    }

    if (mounted) {
      setState(() {
        _isAuthenticated = hasSession;
        _isChecking = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isChecking) {
      return Scaffold(
        backgroundColor: const Color(0xFF030D0A),
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Image.asset(
                AppAssets.emeraldCrest,
                height: 72,
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) => const Icon(
                  Icons.diamond_outlined,
                  color: AppColors.goldPrimary,
                  size: 48,
                ),
              ),
              const SizedBox(height: 20),
              const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: AppColors.goldPrimary,
                ),
              ),
            ],
          ),
        ),
      );
    }

    // Amazon-style persistent login:
    // If authenticated -> directly open Dashboard (initialScreenIndex: 1)
    // If unauthenticated -> open Welcome & Login onboarding (initialScreenIndex: 0)
    return AthiraiFlowContainer(
      initialScreenIndex: _isAuthenticated ? 1 : 0,
    );
  }
}
