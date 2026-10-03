import 'package:flutter/material.dart';
import 'app_draggable_sheet.dart';

class JourneyOptionsSheet extends StatelessWidget {
  final VoidCallback onRouteDetail;
  final VoidCallback? onJourneyDetail;

  const JourneyOptionsSheet({
    super.key,
    required this.onRouteDetail,
    this.onJourneyDetail,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return AppDraggableSheet(
      title: 'Tùy chọn',
      initialChildSize: 0.35,
      minChildSize: 0.25,
      maxChildSize: 0.5,
      contentBuilder: (context, scrollController) {
        return ListView(
          controller: scrollController,
          padding: const EdgeInsets.symmetric(vertical: 8),
          children: [
            ListTile(
              title: Text(
                'Chi tiết tuyến đường',
                style: TextStyle(
                  color: colorScheme.onSurfaceVariant,
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                ),
              ),
              onTap: () {
                Navigator.pop(context);
                onRouteDetail();
              },
            ),
            ListTile(
              title: Text(
                'Chi tiết Hành trình',
                style: TextStyle(
                  color: colorScheme.onSurfaceVariant,
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                ),
              ),
              onTap: () {
                Navigator.pop(context);
                onJourneyDetail?.call();
              },
            ),
          ],
        );
      },
    );
  }
}
