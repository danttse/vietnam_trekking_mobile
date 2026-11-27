import 'package:flutter/material.dart';

import '../../../../core/widgets/app_bar/app_top_bar_with_back.dart';
import '../../../../l10n/app_localizations.dart';
import '../view_models/my_contributions_viewmodel.dart';
import '../widgets/contribution_item_card.dart';

class MyContributionsScreen extends StatefulWidget {
  final MyContributionsViewModel? viewModel;

  const MyContributionsScreen({super.key, this.viewModel});

  @override
  State<MyContributionsScreen> createState() => _MyContributionsScreenState();
}

class _MyContributionsScreenState extends State<MyContributionsScreen> {
  late final MyContributionsViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    _viewModel = widget.viewModel ?? MyContributionsViewModel();
    _viewModel.loadContributions();
  }

  @override
  void dispose() {
    if (widget.viewModel == null) {
      _viewModel.dispose();
    }
    super.dispose();
  }

  Widget _buildTabBar(ColorScheme colorScheme) {
    final l10n = AppLocalizations.of(context)!;
    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minWidth: constraints.maxWidth > 32 ? constraints.maxWidth - 32 : 0,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildTabItem(0, l10n.tabContributionSubmitted, _viewModel.submittedCount),
                _buildTabItem(1, l10n.tabContributionApproved, _viewModel.approvedCount),
                _buildTabItem(2, l10n.tabContributionRejected, _viewModel.rejectedCount),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildTabItem(int index, String title, int count) {
    final isSelected = _viewModel.selectedTabIndex == index;
    final colorScheme = Theme.of(context).colorScheme;

    return GestureDetector(
      onTap: () => _viewModel.setTab(index),
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 4.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  title,
                  maxLines: 1,
                  softWrap: false,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                    color: isSelected
                        ? colorScheme.onSurface
                        : colorScheme.onSurfaceVariant.withValues(alpha: 0.8),
                  ),
                ),
                if (count > 0) ...[
                  const SizedBox(width: 5),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? colorScheme.primary
                          : colorScheme.outlineVariant.withValues(alpha: 0.35),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      '$count',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: isSelected ? Colors.white : colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                ],
              ],
            ),
            const SizedBox(height: 6),
            AnimatedContainer(
              height: 2.5,
              width: isSelected ? 40 : 0,
              duration: const Duration(milliseconds: 200),
              decoration: BoxDecoration(
                color: isSelected ? colorScheme.onSurface : null,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(ColorScheme colorScheme, AppLocalizations l10n) {
    String emptyMessage;
    IconData emptyIcon;

    switch (_viewModel.selectedTabIndex) {
      case 1:
        emptyMessage = l10n.noContributionsApproved;
        emptyIcon = Icons.task_alt_rounded;
        break;
      case 2:
        emptyMessage = l10n.noContributionsRejected;
        emptyIcon = Icons.thumb_up_alt_outlined;
        break;
      case 0:
      default:
        emptyMessage = l10n.noContributionsSubmitted;
        emptyIcon = Icons.inbox_outlined;
        break;
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: constraints.maxHeight),
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(32.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      emptyIcon,
                      size: 56,
                      color: colorScheme.onSurfaceVariant.withValues(alpha: 0.4),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      emptyMessage,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 14,
                        color: colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: SafeArea(
        child: Column(
          children: [
            AppTopBarWithBack(title: l10n.yourContributions),
            const SizedBox(height: 4),
            ListenableBuilder(
              listenable: _viewModel,
              builder: (context, _) => _buildTabBar(colorScheme),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: ListenableBuilder(
                listenable: _viewModel,
                builder: (context, _) {
                  if (_viewModel.isLoading && _viewModel.currentList.isEmpty) {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  }

                  if (_viewModel.error != null && _viewModel.currentList.isEmpty) {
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.all(24.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.error_outline_rounded,
                              size: 48,
                              color: colorScheme.error,
                            ),
                            const SizedBox(height: 12),
                            Text(
                              _viewModel.error!,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 13,
                                color: colorScheme.error,
                              ),
                            ),
                            const SizedBox(height: 16),
                            FilledButton.tonal(
                              onPressed: _viewModel.loadContributions,
                              child: Text(l10n.commonRetry),
                            ),
                          ],
                        ),
                      ),
                    );
                  }

                  final list = _viewModel.currentList;
                  if (list.isEmpty) {
                    return RefreshIndicator(
                      onRefresh: _viewModel.loadContributions,
                      child: _buildEmptyState(colorScheme, l10n),
                    );
                  }

                  return RefreshIndicator(
                    onRefresh: _viewModel.loadContributions,
                    child: ListView.builder(
                      physics: const AlwaysScrollableScrollPhysics(
                        parent: BouncingScrollPhysics(),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                      itemCount: list.length,
                      itemBuilder: (context, index) {
                        final item = list[index];
                        return ContributionItemCard(
                          contribution: item,
                          isRejectedTab: _viewModel.selectedTabIndex == 2,
                        );
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
