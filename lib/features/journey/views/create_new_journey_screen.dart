import 'package:flutter/material.dart';
import '../../../core/widgets/app_bar/app_top_bar_with_back.dart';
import '../../../core/widgets/buttons/btn_login_style.dart';
import '../../../core/widgets/inputs/login_input_field.dart';
import '../../../core/widgets/sheet/select_route_sheet.dart';
import '../../../l10n/app_localizations.dart';
import '../../route/data/models/route_model.dart';
import '../../route/view/route_detail_screen.dart';
import '../viewmodels/create_new_journey_viewmodel.dart';

class CreateNewJourneyScreen extends StatefulWidget {
  const CreateNewJourneyScreen({super.key});

  @override
  State<CreateNewJourneyScreen> createState() => _CreateNewJourneyScreenState();
}

class _CreateNewJourneyScreenState extends State<CreateNewJourneyScreen> {
  final CreateNewJourneyViewModel _viewModel = CreateNewJourneyViewModel();

  @override
  void dispose() {
    _viewModel.dispose();
    super.dispose();
  }

  void _showSelectRouteBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => SelectRouteSheet(
        routes: _viewModel.routes,
        selectedRoute: _viewModel.selectedRoute,
        onRouteSelected: _viewModel.setRoute,
      ),
    );
  }

  Widget _buildRoutePickerField({
    required String label,
    required String hintText,
    RouteModel? selectedRoute,
    required VoidCallback onTap,
    required ColorScheme colorScheme,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: colorScheme.onSurface,
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: colorScheme.onSurfaceVariant.withValues(alpha: 0.15),
                width: 1,
              ),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    selectedRoute?.name ?? hintText,
                    style: TextStyle(
                      color: selectedRoute != null
                          ? colorScheme.onSurface
                          : colorScheme.onSurfaceVariant.withValues(alpha: 0.6),
                      fontSize: 14,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Icon(
                  Icons.keyboard_arrow_down,
                  color: colorScheme.onSurfaceVariant,
                ),
              ],
            ),
          ),
        ),
      ],
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
            AppTopBarWithBack(
              title: l10n.createNewJourneyTitle,
            ),
            Expanded(
              child: ListenableBuilder(
                listenable: _viewModel,
                builder: (context, _) {
                  return SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        EditTextAuthCustom(
                          label: l10n.journeyNameLabel,
                          hintText: l10n.journeyNameHint,
                          controller: _viewModel.journeyNameController,
                        ),
                        const SizedBox(height: 16),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: _builDatePickerField(
                                label: l10n.journeyStartDateLabel,
                                controller: _viewModel.startedAtController,
                                context: context,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _builDatePickerField(
                                label: l10n.journeyEndDateLabel,
                                controller: _viewModel.completedAtController,
                                context: context,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        _buildRoutePickerField(
                          label: l10n.selectRouteLabel,
                          hintText: l10n.selectRouteHint,
                          selectedRoute: _viewModel.selectedRoute,
                          onTap: () => _showSelectRouteBottomSheet(context),
                          colorScheme: colorScheme,
                        ),
                        const SizedBox(height: 16),
                        EditTextAuthCustom(
                          label: l10n.participantCountLabel,
                          hintText: l10n.participantCountHint,
                          controller: _viewModel.participantCountController,
                          keyboardType: TextInputType.number,
                        ),
                        const SizedBox(height: 16),
                        EditTextAuthCustom(
                          label: l10n.journeyNoteLabel,
                          hintText: l10n.journeyNoteHint,
                          controller: _viewModel.descriptionController,
                          maxLines: 4,
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "Bật tính năng check-in",
                                    style: TextStyle(
                                      color: colorScheme.onSurface,
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    "Tự động lưu dấu chân và mở khóa huy hiệu khi đến địa điểm",
                                    style: TextStyle(
                                      color: colorScheme.onSurfaceVariant.withValues(alpha: 0.8),
                                      fontSize: 11,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 12),
                            Switch.adaptive(
                              value: _viewModel.isCheckInFeatureEnabled,
                              activeTrackColor: colorScheme.primary,
                              onChanged: (value) => _viewModel.setCheckInFeatureEnabled(value),
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: SizedBox(
                width: double.infinity,
                child: ListenableBuilder(
                  listenable: _viewModel,
                  builder: (context, _) {
                    return BtnLoginPrimary(
                      text: l10n.createJourneyButton,
                      isLoading: _viewModel.isLoading,
                      onPressed: () async {
                        final createdJourney = await _viewModel.submit();
                        if (createdJourney != null && context.mounted) {
                          final result = await Navigator.push<dynamic>(
                            context,
                            MaterialPageRoute(
                              builder: (context) => RouteDetailScreen(
                                route: createdJourney.route,
                                pendingJourney: createdJourney,
                              ),
                            ),
                          );
                          if (result == true && context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(l10n.createJourneySuccess),
                                backgroundColor: Colors.green,
                              ),
                            );
                            Navigator.pop(context, createdJourney);
                          }
                        }
                      },
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _builDatePickerField({
    required BuildContext context,
    required TextEditingController controller,
    required String label,
    DateTime? initialDate,
    DateTime? firstDate,
    DateTime? lastDate,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: colorScheme.onSurface,
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        InkWell(
          onTap: () async {
            final DateTime? pickedDate = await showDatePicker(
              context: context,
              initialDate: initialDate ?? DateTime.now(),
              firstDate: firstDate ?? DateTime(2020),
              lastDate: lastDate ?? DateTime(2030),
            );
            if (pickedDate != null) {
              controller.text =
                  '${pickedDate.day.toString().padLeft(2, '0')}/${pickedDate.month.toString().padLeft(2, '0')}/${pickedDate.year}';
            }
          },
          borderRadius: BorderRadius.circular(12),
          child: Container(
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: colorScheme.onSurfaceVariant.withValues(alpha: 0.15),
                width: 1,
              ),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
            child: Text(
              controller.text,
              style: TextStyle(
                color: colorScheme.onSurface,
                fontSize: 14,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
