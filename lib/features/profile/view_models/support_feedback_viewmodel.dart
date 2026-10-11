import 'package:flutter/material.dart';
import 'package:vietnam_trekking_mobile/l10n/app_localizations.dart';

class SupportFaqItem {
  final String question;
  final String answer;

  const SupportFaqItem({required this.question, required this.answer});
}

class SupportFeedbackViewModel extends ChangeNotifier {
  final TextEditingController descriptionController = TextEditingController();

  int? _expandedFaqIndex = 0;
  int _selectedIssueTypeIndex = 0;
  bool _isLoading = false;

  int? get expandedFaqIndex => _expandedFaqIndex;
  int get selectedIssueTypeIndex => _selectedIssueTypeIndex;
  bool get isLoading => _isLoading;

  static List<String> getIssueTypes(AppLocalizations l10n) {
    return [
      l10n.supportIssueGpsMap,
      l10n.supportIssueAccount,
      l10n.supportIssueContent,
      l10n.supportIssueAppExperience,
      l10n.supportIssueOther,
    ];
  }

  static List<SupportFaqItem> getFaqs(AppLocalizations l10n) {
    return [
      SupportFaqItem(
        question: l10n.supportFaq1Q,
        answer: l10n.supportFaq1A,
      ),
      SupportFaqItem(
        question: l10n.supportFaq2Q,
        answer: l10n.supportFaq2A,
      ),
      SupportFaqItem(
        question: l10n.supportFaq3Q,
        answer: l10n.supportFaq3A,
      ),
    ];
  }

  void toggleFaq(int index) {
    if (_expandedFaqIndex == index) {
      _expandedFaqIndex = null;
    } else {
      _expandedFaqIndex = index;
    }
    notifyListeners();
  }

  void setIssueTypeIndex(int index) {
    if (_selectedIssueTypeIndex != index) {
      _selectedIssueTypeIndex = index;
      notifyListeners();
    }
  }

  Future<bool> submitFeedback(BuildContext context) async {
    final l10n = AppLocalizations.of(context)!;
    final text = descriptionController.text.trim();
    if (text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.supportEmptyError),
          duration: const Duration(seconds: 2),
        ),
      );
      return false;
    }
    _isLoading = true;
    notifyListeners();
    await Future.delayed(const Duration(milliseconds: 600));
    _isLoading = false;
    descriptionController.clear();
    notifyListeners();
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.supportSuccessMessage),
          duration: const Duration(seconds: 2),
        ),
      );
    }
    return true;
  }

  @override
  void dispose() {
    descriptionController.dispose();
    super.dispose();
  }
}
