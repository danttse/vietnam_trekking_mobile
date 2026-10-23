import 'package:flutter/material.dart';

/// Hàng hiển thị 3–4 stat boxes (quãng đường / thời gian / tỉnh / độ cao).
/// Dùng trong Journey Detail và Journey List summary.
class JourneyStatsRow extends StatelessWidget {
  final List<JourneyStat> stats;

  const JourneyStatsRow({super.key, required this.stats});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: stats
          .map((s) => Expanded(child: _StatBox(stat: s)))
          .toList(),
    );
  }
}

class JourneyStat {
  final String value;
  final String label;
  const JourneyStat({required this.value, required this.label});
}

class _StatBox extends StatelessWidget {
  final JourneyStat stat;
  const _StatBox({required this.stat});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 4),
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 6),
      decoration: BoxDecoration(
        color: cs.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        children: [
          Text(
            stat.value,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: cs.onSurface,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            stat.label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 10,
              color: cs.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}
