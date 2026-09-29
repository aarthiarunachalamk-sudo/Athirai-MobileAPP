import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Moves and illuminates the gold ribbons already present in the bitmap.
class AnimatedRibbonImage extends StatefulWidget {
  final String asset;
  const AnimatedRibbonImage({super.key, required this.asset});

  @override
  State<AnimatedRibbonImage> createState() => _AnimatedRibbonImageState();
}

class _AnimatedRibbonImageState extends State<AnimatedRibbonImage>
    with SingleTickerProviderStateMixin {
  late final AnimationController _motion;
  ui.Image? _image;
  ui.FragmentShader? _shader;

  @override
  void initState() {
    super.initState();
    _motion = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 5),
    )..repeat();
    _load();
  }

  Future<void> _load() async {
    try {
      final program = await ui.FragmentProgram.fromAsset(
        'shaders/gold_ribbons.frag',
      );
      final data = await rootBundle.load(widget.asset);
      final codec = await ui.instantiateImageCodec(
        data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes),
      );
      final frame = await codec.getNextFrame();
      codec.dispose();
      if (!mounted) {
        frame.image.dispose();
        return;
      }
      setState(() {
        _image = frame.image;
        _shader = program.fragmentShader();
      });
    } catch (error) {
      debugPrint('Ribbon animation unavailable: $error');
    }
  }

  @override
  void dispose() {
    _motion.dispose();
    _shader?.dispose();
    _image?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final reduceMotion = MediaQuery.disableAnimationsOf(context);
    if (_shader == null || _image == null || reduceMotion) {
      return Image.asset(widget.asset, fit: BoxFit.cover);
    }
    return RepaintBoundary(
      child: CustomPaint(
        painter: _RibbonImagePainter(_image!, _shader!, _motion),
      ),
    );
  }
}

class _RibbonImagePainter extends CustomPainter {
  final ui.Image image;
  final ui.FragmentShader shader;
  final Animation<double> motion;
  _RibbonImagePainter(this.image, this.shader, this.motion)
    : super(repaint: motion);

  @override
  void paint(Canvas canvas, Size size) {
    shader
      ..setFloat(0, size.width)
      ..setFloat(1, size.height)
      ..setFloat(2, image.width.toDouble())
      ..setFloat(3, image.height.toDouble())
      ..setFloat(4, motion.value * math.pi * 2)
      ..setImageSampler(0, image);
    canvas.drawRect(Offset.zero & size, Paint()..shader = shader);
  }

  @override
  bool shouldRepaint(covariant _RibbonImagePainter oldDelegate) =>
      oldDelegate.image != image ||
      oldDelegate.shader != shader ||
      oldDelegate.motion != motion;
}
