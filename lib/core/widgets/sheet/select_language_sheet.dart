import 'package:flutter/material.dart';
import '../../../l10n/app_localizations.dart';
import 'app_draggable_sheet.dart';

class LanguageOption {
  final String code;
  final String label;
  final String flagEmoji;

  const LanguageOption(this.code, this.label, this.flagEmoji);
}

class SelectLanguageSheet extends StatefulWidget {
  final String currentLocale;
  final ValueChanged<String> onLanguageSelected;

  const SelectLanguageSheet({
    super.key,
    required this.currentLocale,
    required this.onLanguageSelected,
  });

  @override
  State<SelectLanguageSheet> createState() => _SelectLanguageSheetState();
}

class _SelectLanguageSheetState extends State<SelectLanguageSheet> {
  static const _languages = [
    LanguageOption('vi', 'Tiếng Việt', '🇻🇳'),
    LanguageOption('en', 'English', '🇬🇧'),
  ];

  late String _selected;

  @override
  void initState() {
    super.initState();
    _selected = widget.currentLocale;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return AppDraggableSheet(
      title: l10n.settingsChangeLanguage,
      initialChildSize: 0.35,
      minChildSize: 0.25,
      maxChildSize: 0.5,
      contentBuilder: (context, scrollController) {
        return ListView(
          controller: scrollController,
          padding: const EdgeInsets.symmetric(vertical: 8),
          children: _languages.map((lang) {
            return RadioListTile<String>(
              value: lang.code,
              groupValue: _selected,
              activeColor: Theme.of(context).colorScheme.primary,
              title: Text('${lang.flagEmoji}  ${lang.label}'),
              onChanged: (value) {
                if (value == null) return;
                setState(() => _selected = value);
                widget.onLanguageSelected(value);
                Navigator.pop(context);
              },
            );
          }).toList(),
        );
      },
    );
  }
}
