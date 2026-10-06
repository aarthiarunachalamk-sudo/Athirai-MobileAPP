import 'package:flutter/material.dart';

import '../../../shop/presentation/shop_screen.dart';

/// Compatibility entry for links created before the shopping redesign.
class ChooseShowroomScreen extends StatelessWidget {
  const ChooseShowroomScreen({super.key});

  @override
  Widget build(BuildContext context) => const ShopScreen();
}
