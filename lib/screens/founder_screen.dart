import 'package:flutter/material.dart';
import '../utils/app_localizations.dart';

class FounderScreen extends StatelessWidget {
  const FounderScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(title: Text(localizations.founderInfo)),
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
                  CircleAvatar(
                    radius: 60,
                    backgroundColor: Theme.of(context).primaryColor,
                    child: const Icon(
                      Icons.person,
                      size: 60,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    localizations.language == 'Language'
                        ? 'Alex Martinez'
                        : 'Alex Martinez',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    localizations.language == 'Language'
                        ? 'Founder & CEO'
                        : 'Fondateur et PDG',
                    style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Text(
              localizations.founderContent,
              style: const TextStyle(fontSize: 16, height: 1.6),
            ),
            const SizedBox(height: 24),
            _buildInfoCard(
              context,
              localizations.language == 'Language'
                  ? 'Experience'
                  : 'Expérience',
              localizations.language == 'Language'
                  ? '15+ years in tech and entertainment industry'
                  : '15+ années dans l\'industrie de la technologie et du divertissement',
              Icons.work_outline,
            ),
            const SizedBox(height: 16),
            _buildInfoCard(
              context,
              localizations.language == 'Language' ? 'Education' : 'Éducation',
              localizations.language == 'Language'
                  ? 'MBA in Business Administration, BS in Computer Science'
                  : 'MBA en Administration des Affaires, BS en Informatique',
              Icons.school_outlined,
            ),
            const SizedBox(height: 16),
            _buildInfoCard(
              context,
              localizations.language == 'Language' ? 'Vision' : 'Vision',
              localizations.language == 'Language'
                  ? 'To democratize access to live events and create unforgettable experiences'
                  : 'Démocratiser l\'accès aux événements en direct et créer des expériences inoubliables',
              Icons.visibility_outlined,
            ),
            const SizedBox(height: 24),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey[300]!),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    localizations.language == 'Language'
                        ? 'Message from the Founder'
                        : 'Message du Fondateur',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    localizations.language == 'Language'
                        ? '"I started QuikTik with a simple mission: to make attending live events accessible to everyone. Whether it\'s a concert, sports game, or theater show, everyone deserves to experience the magic of live entertainment without the hassle of complicated ticketing systems."'
                        : '"J\'ai créé QuikTik avec une mission simple : rendre l\'accès aux événements en direct accessible à tous. Qu\'il s\'agisse d\'un concert, d\'un match de sport ou d\'un spectacle de théâtre, tout le monde mérite de vivre la magie du divertissement en direct sans les tracas des systèmes de billetterie compliqués."',
                    style: const TextStyle(
                      fontSize: 14,
                      fontStyle: FontStyle.italic,
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard(
    BuildContext context,
    String title,
    String content,
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
                    content,
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
