import 'package:flutter/material.dart';
import 'package:vietnam_trekking_mobile/core/widgets/cards/image_load_card.dart';
import '../../../core/widgets/app_bar/app_top_bar_with_back.dart';
import '../../../core/widgets/buttons/btn_login_style.dart';
import '../../../core/widgets/inputs/login_input_field.dart';
import '../view_models/suggest_place_viewmodel.dart';
import '../../../l10n/app_localizations.dart';

class SuggestPlaceScreen extends StatefulWidget {
  const SuggestPlaceScreen({super.key});

  @override
  State<SuggestPlaceScreen> createState() => _SuggestPlaceScreenState();
}

class _SuggestPlaceScreenState extends State<SuggestPlaceScreen> {
  final SuggestPlaceViewModel _viewModel = SuggestPlaceViewModel();

  @override
  void dispose() {
    _viewModel.dispose();
    super.dispose();
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
              title: l10n.proposePlace,
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
                          label: l10n.placeName,
                          hintText: l10n.enterPlaceName,
                          controller: _viewModel.placeNameController,
                        ),
                        const SizedBox(height: 16),
                        _buildDropdownField(
                          label: l10n.provinceCity,
                          value: _viewModel.selectedProvince,
                          items: _viewModel.provinces,
                          onChanged: _viewModel.setProvince,
                          colorScheme: colorScheme,
                        ),
                        const SizedBox(height: 16),
                        EditTextAuthCustom(
                          label: l10n.gpsCoordinates,
                          controller: _viewModel.gpsController,
                          labelTrailing: InkWell(
                            onTap: () => _viewModel.getCurrentLocation(),
                            borderRadius: BorderRadius.circular(12),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.location_on,
                                    size: 14,
                                    color: colorScheme.primary,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    l10n.getCurrentLocation,
                                    style: TextStyle(
                                      color: colorScheme.primary,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: EditTextAuthCustom(
                                label: l10n.elevation,
                                controller: _viewModel.altitudeController,
                                keyboardType: TextInputType.number,
                              ),
                            ),
                            const SizedBox(width: 12),
                            //Difficulty
                            Expanded(
                              child: _buildDropdownField(
                                label: l10n.difficulty,
                                value: _viewModel.selectedDifficulty,
                                items: _viewModel.difficulties,
                                onChanged: _viewModel.setDifficulty,
                                colorScheme: colorScheme,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        EditTextAuthCustom(
                          label: l10n.placeDescription,
                          hintText: l10n.enterPlaceDescription,
                          controller: _viewModel.descriptionController,
                          maxLines: 4,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          l10n.addImages,
                          style: TextStyle(
                            color: colorScheme.onSurface,
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        SizedBox(
                          height: 72,
                          child: Row(
                            children: [
                              InkWell(
                                onTap: () => _viewModel.pickMultiImages(),
                                borderRadius: BorderRadius.circular(12),
                                child: Container(
                                  width: 72,
                                  height: 72,
                                  decoration: BoxDecoration(
                                    color: colorScheme.surfaceContainerHighest,
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: colorScheme.onSurfaceVariant.withValues(alpha: 0.25),
                                    ),
                                  ),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.camera_alt_outlined,
                                        size: 24,
                                        color: colorScheme.onSurfaceVariant,
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        l10n.addPhoto,
                                        style: TextStyle(
                                          color: colorScheme.onSurfaceVariant,
                                          fontSize: 10,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: ListView.builder(
                                  scrollDirection: Axis.horizontal,
                                  itemCount: _viewModel.selectedImages.length,
                                  itemBuilder: (context,index) {
                                    return Padding(
                                      padding: const EdgeInsets.only(right:10),
                                      child: ImageLoadCard(
                                        imageUrl: _viewModel.selectedImages[index],
                                        onTapRemove: () => _viewModel.removeImage(index),
                                      ),
                                    );
                                  },
                                )
                              )
                            ],
                          )
                        ),
                        const SizedBox(height: 16),
                        Text(
                          l10n.suggestionNotice,
                          style: TextStyle(
                            color: colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
                            fontSize: 12,
                            height: 1.4,
                          ),
                        ),
                        const SizedBox(height: 16),
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
                      text: l10n.submitPropose,
                      isLoading: _viewModel.isLoading,
                      onPressed: () async {
                        final success = await _viewModel.submit();
                        if (success && context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Đề xuất của bạn đã được gửi thành công!'),
                              backgroundColor: Colors.green,
                            ),
                          );
                          Navigator.pop(context);
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

Widget _buildDropdownField({
    required String label,
    required String value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
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
        Container(
          height: 48,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: colorScheme.onSurfaceVariant.withValues(alpha: 0.25),
            ),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: value,
              isExpanded: true,
              dropdownColor: colorScheme.surfaceContainerHighest,
              icon: Icon(
                Icons.keyboard_arrow_down,
                color: colorScheme.onSurfaceVariant,
              ),
              style: TextStyle(
                color: colorScheme.onSurface,
                fontSize: 14,
              ),
              items: items.map((item) {
                return DropdownMenuItem<String>(
                  value: item,
                  child: Text(item),
                );
              }).toList(),
              onChanged: onChanged,
            ),
          ),
        ),
      ],
    );
  }
}
