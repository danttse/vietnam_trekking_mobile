import 'package:flutter/material.dart';

import '../../../../l10n/app_localizations.dart';
import '../../journey/data/models/contribution_model.dart';

class ContributionItemCard extends StatelessWidget {
  final ContributionModel contribution;
  final bool isRejectedTab;
  final VoidCallback? onTap;

  const ContributionItemCard({
    super.key,
    required this.contribution,
    this.isRejectedTab = false,
    this.onTap,
  });

  bool get _isRoute =>
      contribution.type == 'ROUTE_SUBMISSION' ||
      (contribution.contributionKind == 'ROUTE' &&
          contribution.type != 'PLACE_SUGGESTION' &&
          contribution.type != 'PLACE');

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context)!;
    final showRejectionReason = isRejectedTab || contribution.status == 'REJECTED';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: showRejectionReason
              ? colorScheme.error.withValues(alpha: 0.25)
              : colorScheme.outlineVariant.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildLeadingIcon(context, colorScheme, l10n),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            contribution.proposedName?.trim().isNotEmpty == true
                                ? contribution.proposedName!
                                : (_isRoute
                                    ? l10n.contributionTypeRoute
                                    : l10n.contributionTypePlace),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: colorScheme.onSurface,
                            ),
                          ),
                          const SizedBox(height: 5),
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 7,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: colorScheme.primary.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  _isRoute
                                      ? l10n.contributionTypeRoute
                                      : l10n.contributionTypePlace,
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w600,
                                    color: colorScheme.primary,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 6),
                              _buildStatusBadge(colorScheme, l10n),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Row(
                            children: [
                              Icon(
                                Icons.access_time_rounded,
                                size: 13,
                                color: colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
                              ),
                              const SizedBox(width: 4),
                              Expanded(
                                child: Text(
                                  _formatDate(contribution.createdAt),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: colorScheme.onSurfaceVariant.withValues(alpha: 0.8),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          if (contribution.description?.trim().isNotEmpty == true) ...[
                            const SizedBox(height: 4),
                            Text(
                              contribution.description!.trim(),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 11,
                                color: colorScheme.onSurfaceVariant.withValues(alpha: 0.65),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
                if (showRejectionReason) ...[
                  const SizedBox(height: 10),
                  Divider(
                    height: 1,
                    thickness: 1,
                    color: colorScheme.outlineVariant.withValues(alpha: 0.25),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        Icons.cancel_outlined,
                        size: 13,
                        color: colorScheme.error,
                      ),
                      const SizedBox(width: 5),
                      Text(
                        l10n.rejectionReason,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: colorScheme.error,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Padding(
                    padding: const EdgeInsets.only(left: 18),
                    child: Text(
                      contribution.adminNote?.trim().isNotEmpty == true
                          ? contribution.adminNote!.trim()
                          : l10n.noRejectionReason,
                      textAlign: TextAlign.justify,
                      style: TextStyle(
                        fontSize: 11,
                        fontStyle: FontStyle.italic,
                        color: colorScheme.onSurfaceVariant.withValues(alpha: 0.85),
                        height: 1.35,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLeadingIcon(
    BuildContext context,
    ColorScheme colorScheme,
    AppLocalizations l10n,
  ) {
    if (contribution.images.isNotEmpty) {
      final firstImage = contribution.images.first;
      return ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Image.network(
          firstImage,
          width: 72,
          height: 72,
          fit: BoxFit.cover,
          errorBuilder: (_, _, _) => _buildIconBox(colorScheme, l10n),
        ),
      );
    }
    return _buildIconBox(colorScheme, l10n);
  }

  Widget _buildIconBox(ColorScheme colorScheme, AppLocalizations l10n) {
    final isRoute = _isRoute;
    return Container(
      width: 72,
      height: 72,
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            isRoute ? Icons.alt_route_rounded : Icons.terrain_rounded,
            size: 26,
            color: colorScheme.primary.withValues(alpha: 0.8),
          ),
          const SizedBox(height: 3),
          Text(
            isRoute ? l10n.contributionTypeRoute : l10n.contributionTypePlace,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 9,
              fontWeight: FontWeight.bold,
              color: colorScheme.primary.withValues(alpha: 0.85),
              letterSpacing: 0.3,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBadge(ColorScheme colorScheme, AppLocalizations l10n) {
    Color badgeColor;
    String badgeText;

    switch (contribution.status) {
      case 'APPROVED':
        badgeColor = const Color(0xFF207335);
        badgeText = l10n.tabContributionApproved;
        break;
      case 'REJECTED':
        badgeColor = colorScheme.error;
        badgeText = l10n.tabContributionRejected;
        break;
      case 'NEEDS_REVISION':
        badgeColor = Colors.orange;
        badgeText = 'Cần chỉnh sửa';
        break;
      case 'DRAFT':
        badgeColor = Colors.blueGrey;
        badgeText = 'Bản nháp';
        break;
      case 'PENDING_REVIEW':
      default:
        badgeColor = const Color(0xFFFF6E40);
        badgeText = l10n.tabContributionSubmitted;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: badgeColor.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        badgeText,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w600,
          color: badgeColor,
        ),
      ),
    );
  }

  String _formatDate(DateTime? dt) {
    if (dt == null) return '--/--/----';
    final d = dt.toLocal();
    final day = d.day.toString().padLeft(2, '0');
    final month = d.month.toString().padLeft(2, '0');
    final year = d.year;
    final hour = d.hour.toString().padLeft(2, '0');
    final minute = d.minute.toString().padLeft(2, '0');
    return '$hour:$minute - $day/$month/$year';
  }
}
