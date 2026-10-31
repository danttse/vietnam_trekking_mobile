import 'package:flutter/material.dart';
import '../../../core/widgets/app_bar/app_top_bar_with_back.dart';
import '../../../core/widgets/buttons/btn_login_style.dart';
import '../../../core/widgets/inputs/login_input_field.dart';
import '../../../l10n/app_localizations.dart';
import '../view_models/support_feedback_viewmodel.dart';

class SupportFeedbackScreen extends StatefulWidget {
  const SupportFeedbackScreen({super.key});

  @override
  State<SupportFeedbackScreen> createState() => _SupportFeedbackScreenState();
}

class _SupportFeedbackScreenState extends State<SupportFeedbackScreen> {
  late final SupportFeedbackViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    _viewModel = SupportFeedbackViewModel();
  }

  @override
  void dispose() {
    _viewModel.dispose();
    super.dispose();
  }

  Widget _buildSectionHeader({
    required BuildContext context,
    required String title,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.2,
          color: colorScheme.onSurfaceVariant.withValues(alpha: 0.8),
        ),
      ),
    );
  }
  Widget _buildFaqItem({
    required BuildContext context,
    required int index,
    required String question,
    required String answer,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    final isExpanded = _viewModel.expandedFaqIndex == index;

    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: colorScheme.onSurfaceVariant.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          InkWell(
            onTap: () => _viewModel.toggleFaq(index),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      question,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: colorScheme.onSurface,
                      ),
                    ),
                  ),
                  Icon(
                    isExpanded
                        ? Icons.keyboard_arrow_up_rounded
                        : Icons.keyboard_arrow_down_rounded,
                    color: colorScheme.onSurfaceVariant,
                    size: 22,
                  ),
                ],
              ),
            ),
          ),
          if (isExpanded)
            Padding(
              padding: const EdgeInsets.only(
                left: 16,
                right: 16,
                bottom: 14,
              ),
              child: Text(
                answer,
                textAlign: TextAlign.justify,
                style: TextStyle(
                  fontSize: 13,
                  height: 1.45,
                  color: colorScheme.onSurfaceVariant.withValues(alpha: 0.85),
                ),
              ),
            ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              AppTopBarWithBack(title: l10n.settingsSupportFeedback),
              const SizedBox(height: 22),
              _buildSectionHeader(
                context: context,
                title: l10n.supportFaqHeader,
              ),
              ListenableBuilder(
                listenable: _viewModel,
                builder: (context, _) {
                  final faqs = SupportFeedbackViewModel.getFaqs(l10n);
                  return Column(
                    children: [
                      for (int i = 0; i < faqs.length; i++) ...[
                        if (i > 0) const SizedBox(height: 10),
                        _buildFaqItem(
                          context: context,
                          index: i,
                          question: faqs[i].question,
                          answer: faqs[i].answer,
                        ),
                      ],
                    ],
                  );
                },
              ),
              const SizedBox(height: 22),
              _buildSectionHeader(
                context: context,
                title: l10n.supportFeedbackHeader,
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                decoration: BoxDecoration(
                  color: colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: colorScheme.onSurfaceVariant.withValues(alpha: 0.15),
                    width: 1,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.supportIssueTypeLabel,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: colorScheme.onSurfaceVariant.withValues(alpha: 0.8),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: colorScheme.surface,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: colorScheme.onSurfaceVariant
                              .withValues(alpha: 0.15),
                          width: 1,
                        ),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: ListenableBuilder(
                          listenable: _viewModel,
                          builder: (context, _) {
                            final issueTypes =
                                SupportFeedbackViewModel.getIssueTypes(l10n);
                            return DropdownButton<int>(
                              value: _viewModel.selectedIssueTypeIndex,
                              isExpanded: true,
                              icon: Icon(
                                Icons.keyboard_arrow_down_rounded,
                                color: colorScheme.onSurfaceVariant,
                              ),
                              dropdownColor: colorScheme.surfaceContainerHighest,
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: colorScheme.onSurface,
                              ),
                              onChanged: (int? newIndex) {
                                if (newIndex != null) {
                                  _viewModel.setIssueTypeIndex(newIndex);
                                }
                              },
                              items: List.generate(
                                issueTypes.length,
                                (index) => DropdownMenuItem<int>(
                                  value: index,
                                  child: Text(issueTypes[index]),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    EditTextAuthCustom(
                      label: l10n.supportDescriptionLabel,
                      hintText: l10n.supportDescriptionHint,
                      controller: _viewModel.descriptionController,
                      maxLines: 5,
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      child:ListenableBuilder(
                        listenable: _viewModel,
                        builder: (context, _) {
                          return BtnLoginPrimary(
                            text: l10n.supportSubmitButton,
                            isLoading: _viewModel.isLoading,
                            onPressed: () => _viewModel.submitFeedback(context),
                          );
                        },
                      ),
                    )
                  ],
                ),
              ),
              const SizedBox(height: 24),
              Center(
                child: Column(
                  children: [
                    Text(
                      l10n.supportDirectEmail,
                      style: TextStyle(
                        fontSize: 12,
                        color: colorScheme.onSurfaceVariant
                            .withValues(alpha: 0.8),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'support@trekvietnam.vn',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: colorScheme.primary,
                        decoration: TextDecoration.underline,
                        decorationColor: colorScheme.primary,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}
