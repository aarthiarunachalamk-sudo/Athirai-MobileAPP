import 'package:flutter/material.dart';
import '../domain/shop_store.dart';
import 'screens/athirai_flow_container.dart';

/// Legacy entry point redirected to the new exact Athirai Flagship UI
class ShopScreen extends StatelessWidget {
  const ShopScreen({
    super.key,
    this.store,
    this.onStylist,
    this.onSignOut,
    this.initialScreenIndex = 1,
  });

  final ShopStore? store;
  final VoidCallback? onStylist;
  final VoidCallback? onSignOut;
  final int initialScreenIndex;

  @override
  Widget build(BuildContext context) {
    return AthiraiFlowContainer(
      initialScreenIndex: initialScreenIndex,
      store: store,
      onStylist: onStylist,
      onSignOut: onSignOut,
    );
  }
}
