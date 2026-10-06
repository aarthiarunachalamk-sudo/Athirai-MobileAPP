import 'package:flutter/material.dart';

import '../../../shop/presentation/shop_screen.dart';
import '../../domain/models/showroom.dart';

/// Legacy showroom routes now open the catalog without a 3D scene or joystick.
class ShowroomExperienceScreen extends StatelessWidget {
  const ShowroomExperienceScreen({super.key, required this.showroom});
  final Showroom showroom;

  @override
  Widget build(BuildContext context) => const ShopScreen();
}
