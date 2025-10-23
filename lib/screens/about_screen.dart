import 'package:flutter/material.dart';
import '../utils/app_localizations.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(title: Text(localizations.about)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20.0),
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  Icon(
                    Icons.info_outline,
                    size: 64,
                    color: Theme.of(context).primaryColor,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    localizations.aboutTitle,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Text(
              localizations.aboutContent,
              style: const TextStyle(fontSize: 16, height: 1.6),
            ),
            const SizedBox(height: 24),
            _buildFeatureCard(
              context,
              localizations.language == 'Language'
                  ? 'Secure Payments'
                  : 'Paiements Sécurisés',
              localizations.language == 'Language'
                  ? 'All transactions are protected with bank-level security'
                  : 'Toutes les transactions sont protégées avec une sécurité bancaire',
              Icons.security,
            ),
            const SizedBox(height: 16),
            _buildFeatureCard(
              context,
              localizations.language == 'Language'
                  ? 'Instant Delivery'
                  : 'Livraison Instantanée',
              localizations.language == 'Language'
                  ? 'Get your tickets immediately after purchase'
                  : 'Obtenez vos billets immédiatement après l\'achat',
              Icons.flash_on,
            ),
            const SizedBox(height: 16),
            _buildFeatureCard(
              context,
              localizations.language == 'Language'
                  ? '24/7 Support'
                  : 'Support 24/7',
              localizations.language == 'Language'
                  ? 'Our customer service team is always ready to help'
                  : 'Notre équipe de service client est toujours prête à vous aider',
              Icons.support_agent,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureCard(
    BuildContext context,
    String title,
    String description,
    IconData icon,
  ) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                icon,
                color: Theme.of(context).primaryColor,
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
