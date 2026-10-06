import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/constants/app_colors.dart';
import 'features/auth/presentation/controllers/auth_controller.dart';
import 'features/auth/presentation/screens/athirai_entry_screen.dart';
import 'features/auth/presentation/screens/complete_profile_screen.dart';
import 'features/auth/presentation/screens/sign_in_screen.dart';
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
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFFFAF6F0),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF7A1B2E),
          primary: const Color(0xFF7A1B2E),
          surface: const Color(0xFFFAF6F0),
        ),
      ),
      home: const AthiraiFlowContainer(initialScreenIndex: 0),
    );
  }
}

class AuthStartupScreen extends ConsumerStatefulWidget {
  const AuthStartupScreen({super.key});

  @override
  ConsumerState<AuthStartupScreen> createState() => _AuthStartupScreenState();
}

class _AuthStartupScreenState extends ConsumerState<AuthStartupScreen> {
  bool _checkingSession = true;

  @override
  void initState() {
    super.initState();
    _restoreSession();
  }

  Future<void> _restoreSession() async {
    await ref.read(authControllerProvider.notifier).restoreSession();
    if (mounted) setState(() => _checkingSession = false);
  }

  @override
  Widget build(BuildContext context) {
    if (_checkingSession) {
      return const Scaffold(
        backgroundColor: AppColors.backgroundBlack,
        body: Center(
          child: CircularProgressIndicator(color: AppColors.goldPrimary),
        ),
      );
    }

    final authState = ref.watch(authControllerProvider);
    if (!authState.isAuthenticated) return const SignInScreen();
    if (authState.requiresProfileCompletion) return const CompleteProfileScreen();
    return const AthiraiEntryScreen();
  }
}
