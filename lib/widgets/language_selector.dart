import 'package:flutter/material.dart';
import '../utils/app_localizations.dart';

class LanguageSelector extends StatelessWidget {
  final Function(Locale) onLocaleChange;

  const LanguageSelector({super.key, required this.onLocaleChange});

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    final currentLocale = Localizations.localeOf(context);

    return PopupMenuButton<Locale>(
      icon: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.language,
            color: Theme.of(context).appBarTheme.foregroundColor,
          ),
          const SizedBox(width: 4),
          Text(
            currentLocale.languageCode.toUpperCase(),
            style: TextStyle(
              color: Theme.of(context).appBarTheme.foregroundColor,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
      onSelected: (Locale locale) {
        onLocaleChange(locale);
      },
      itemBuilder: (BuildContext context) => [
        PopupMenuItem<Locale>(
          value: const Locale('en', 'US'),
          child: Row(
            children: [
              const Text('🇺🇸'),
              const SizedBox(width: 8),
              Text(localizations.english),
              if (currentLocale.languageCode == 'en')
                const Padding(
                  padding: EdgeInsets.only(left: 8),
                  child: Icon(Icons.check, color: Colors.green),
                ),
            ],
          ),
        ),
        PopupMenuItem<Locale>(
          value: const Locale('fr', 'FR'),
          child: Row(
            children: [
              const Text('🇫🇷'),
              const SizedBox(width: 8),
              Text(localizations.french),
              if (currentLocale.languageCode == 'fr')
                const Padding(
                  padding: EdgeInsets.only(left: 8),
                  child: Icon(Icons.check, color: Colors.green),
                ),
            ],
          ),
        ),
      ],
    );
  }
}
