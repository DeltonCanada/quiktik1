import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/queue_service.dart';
import '../models/queue_models.dart';
import '../utils/app_localizations.dart';

class ConfirmationScreen extends StatelessWidget {
  final int purchasedNumber;

  const ConfirmationScreen({super.key, required this.purchasedNumber});

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    final queueService = Provider.of<QueueService>(context, listen: false);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          localizations.language == 'Language'
              ? 'Payment Confirmation'
              : 'Confirmation de Paiement',
        ),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
        automaticallyImplyLeading: false,
      ),
      body: StreamBuilder<Map<String, QueueStatus>>(
        stream: queueService.queueStatusStream,
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          // Get the first queue status (assuming single establishment context)
          final queueStatus = snapshot.data!.values.isNotEmpty
              ? snapshot.data!.values.first
              : null;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildYourNumberCard(context, localizations),
                const SizedBox(height: 24),
                if (queueStatus != null) ...[
                  _buildQueueStatusSection(context, queueStatus, localizations),
                  const SizedBox(height: 24),
                  _buildAvailableNumbersSection(
                      context, queueStatus, localizations),
                ],
                const SizedBox(height: 32),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).primaryColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    textStyle: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  onPressed: () {
                    Navigator.of(context).popUntil((route) => route.isFirst);
                  },
                  child: Text(
                    localizations.language == 'Language' ? 'Done' : 'Terminé',
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildYourNumberCard(
      BuildContext context, AppLocalizations localizations) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color: Theme.of(context).primaryColor,
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            const Icon(
              Icons.check_circle_outline,
              color: Colors.white,
              size: 48,
            ),
            const SizedBox(height: 12),
            Text(
              localizations.language == 'Language'
                  ? 'Payment Successful!'
                  : 'Paiement Réussi!',
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              localizations.language == 'Language'
                  ? 'Your Queue Number'
                  : 'Votre Numéro de File',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              '#$purchasedNumber',
              style: const TextStyle(
                fontSize: 56,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQueueStatusSection(BuildContext context, QueueStatus queueStatus,
      AppLocalizations localizations) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          localizations.language == 'Language'
              ? 'Live Queue Status'
              : 'Statut de File en Direct',
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildQueueStat(
              context,
              label: localizations.language == 'Language'
                  ? 'Currently Serving'
                  : 'Actuellement Servi',
              value: '#${queueStatus.currentlyServing}',
            ),
            _buildQueueStat(
              context,
              label: localizations.language == 'Language'
                  ? 'People Waiting'
                  : 'Personnes en Attente',
              value: queueStatus.totalWaiting.toString(),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildQueueStat(BuildContext context,
      {required String label, required String value}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        children: [
          Text(
            label,
            style: TextStyle(fontSize: 14, color: Colors.grey[600]),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).primaryColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAvailableNumbersSection(BuildContext context,
      QueueStatus queueStatus, AppLocalizations localizations) {
    final availableNumbers = queueStatus.availableNumbers
        .where((n) => n != purchasedNumber)
        .take(5)
        .toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          localizations.language == 'Language'
              ? 'Other Available Numbers'
              : 'Autres Numéros Disponibles',
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        if (availableNumbers.isEmpty)
          Text(
            localizations.language == 'Language'
                ? 'No other numbers available at the moment.'
                : 'Aucun autre numéro disponible pour le moment.',
            style: TextStyle(color: Colors.grey[600]),
          )
        else
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: availableNumbers
                .map((number) => Chip(
                      label: Text(
                        '#$number',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      backgroundColor: Colors.grey[200],
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 8),
                    ))
                .toList(),
          ),
      ],
    );
  }
}
