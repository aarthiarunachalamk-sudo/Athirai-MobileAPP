import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../shop/domain/shop_store.dart';
import '../../../shop/presentation/shop_screen.dart';
import '../controllers/auth_controller.dart';
import 'selfie_capture_screen.dart';
import 'sign_in_screen.dart';

/// Shopping dashboard reached after Begin Journey.
class ShoppingDashboardScreen extends ConsumerWidget {
  const ShoppingDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) => ShopScreen(
    onStylist: () => Navigator.of(context).push(
      MaterialPageRoute<void>(builder: (_) => const SelfieCaptureScreen()),
    ),
    onSignOut: () async {
      await ref.read(authControllerProvider.notifier).logout();
      ShopStore.session.clear();
      if (context.mounted) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute<void>(builder: (_) => const SignInScreen()),
          (route) => false,
        );
      }
    },
  );
}
