import 'package:flutter/material.dart';
import '../utils/app_localizations.dart';

class TestimonialsScreen extends StatelessWidget {
  const TestimonialsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(title: Text(localizations.testimonials)),
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
                    Icons.star_outline,
                    size: 64,
                    color: Theme.of(context).primaryColor,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    localizations.testimonialsTitle,
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
            _buildTestimonial(
              context,
              localizations.language == 'Language'
                  ? 'Sarah Johnson'
                  : 'Sarah Johnson',
              localizations.language == 'Language'
                  ? 'QuikTik made buying concert tickets so easy! The process was smooth and my tickets arrived instantly.'
                  : 'QuikTik a rendu l\'achat de billets de concert si facile ! Le processus était fluide et mes billets sont arrivés instantanément.',
              5,
            ),
            const SizedBox(height: 16),
            _buildTestimonial(
              context,
              localizations.language == 'Language'
                  ? 'Michael Chen'
                  : 'Michael Chen',
              localizations.language == 'Language'
                  ? 'Great platform with excellent customer service. I had an issue and they resolved it within minutes!'
                  : 'Excellente plateforme avec un service client excellent. J\'ai eu un problème et ils l\'ont résolu en quelques minutes !',
              5,
            ),
            const SizedBox(height: 16),
            _buildTestimonial(
              context,
              localizations.language == 'Language'
                  ? 'Emma Rodriguez'
                  : 'Emma Rodriguez',
              localizations.language == 'Language'
                  ? 'I love how secure the payment system is. I feel confident buying tickets through QuikTik.'
                  : 'J\'adore la sécurité du système de paiement. Je me sens en confiance en achetant des billets via QuikTik.',
              4,
            ),
            const SizedBox(height: 16),
            _buildTestimonial(
              context,
              localizations.language == 'Language'
                  ? 'David Thompson'
                  : 'David Thompson',
              localizations.language == 'Language'
                  ? 'The variety of events available is amazing. I always find what I\'m looking for!'
                  : 'La variété d\'événements disponibles est incroyable. Je trouve toujours ce que je cherche !',
              5,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTestimonial(
    BuildContext context,
    String name,
    String testimonial,
    int rating,
  ) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: Theme.of(
                    context,
                  ).primaryColor.withValues(alpha: 0.1),
                  child: Text(
                    name[0],
                    style: TextStyle(
                      color: Theme.of(context).primaryColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Row(
                        children: List.generate(5, (index) {
                          return Icon(
                            index < rating ? Icons.star : Icons.star_border,
                            color: Colors.amber,
                            size: 16,
                          );
                        }),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              '"$testimonial"',
              style: const TextStyle(
                fontSize: 14,
                fontStyle: FontStyle.italic,
                height: 1.4,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
