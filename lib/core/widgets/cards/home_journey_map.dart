import 'package:flutter/material.dart';
import '../../../features/auth/data/vietnam_map_paths.dart';

class HomeJourneyMap extends StatelessWidget {
  const HomeJourneyMap({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 300,
      width: double.infinity,
      child: CustomPaint(
        painter: VietNamMapPainter(),
      ),
    );
  }
}