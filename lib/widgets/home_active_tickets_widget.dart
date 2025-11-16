import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/di/app_providers.dart';
import '../models/queue_models.dart';
import '../services/queue_service.dart';
import '../utils/app_localizations.dart';
import '../screens/active_tickets_screen.dart';

class HomeActiveTicketsWidget extends ConsumerStatefulWidget {
  const HomeActiveTicketsWidget({super.key});

  @override
  ConsumerState<HomeActiveTicketsWidget> createState() =>
      _HomeActiveTicketsWidgetState();
}

class _HomeActiveTicketsWidgetState
    extends ConsumerState<HomeActiveTicketsWidget> {
  late QueueService _queueService;
  late Stream<Map<String, QueueStatus>> _queueStatusStream;

  @override
  void initState() {
    super.initState();
    _queueService = ref.read(queueServiceProvider);
    _queueStatusStream = _queueService.queueStatusStream;
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    final isEnglish = localizations.language == 'Language';

    return StreamBuilder<Map<String, QueueStatus>>(
      stream: _queueStatusStream,
      builder: (context, snapshot) {
        final queueStatuses = snapshot.data ?? {};
        final activeTickets = _queueService.getActiveTickets();

        if (activeTickets.isEmpty) {
          return _EmptyTicketsCard(localizations: localizations);
        }

        return Card(
          elevation: 6,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.trending_up,
                        color: Theme.of(context).primaryColor),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        isEnglish
                            ? 'Your Queue Tickets'
                            : 'Vos Billets de File',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    _TicketCountBadge(count: activeTickets.length),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  isEnglish
                      ? 'Track each ticket without leaving the home screen.'
                      : "Suivez chaque billet sans quitter l'écran d'accueil.",
                  style: TextStyle(color: Colors.grey[600]),
                ),
                const SizedBox(height: 16),
                ...activeTickets.map((ticket) {
                  final queueStatus = queueStatuses[ticket.establishmentId];
                  return _TicketSummaryTile(
                    ticket: ticket,
                    queueStatus: queueStatus,
                    localizations: localizations,
                  );
                }),
                const SizedBox(height: 16),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton.icon(
                    icon: const Icon(Icons.open_in_new),
                    label: Text(localizations.activeTickets),
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const ActiveTicketsScreen(),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _TicketSummaryTile extends StatelessWidget {
  const _TicketSummaryTile({
    required this.ticket,
    required this.queueStatus,
    required this.localizations,
  });

  final QueueTicket ticket;
  final QueueStatus? queueStatus;
  final AppLocalizations localizations;

  @override
  Widget build(BuildContext context) {
    final isEnglish = localizations.language == 'Language';
    final currentlyServing = queueStatus?.currentlyServing ?? 0;
    final peopleAhead = ticket.queueNumber - currentlyServing - 1;
    final isBeingServed = ticket.queueNumber == currentlyServing;
    final isNextUp = peopleAhead == 0 && !isBeingServed;

    Color borderColor;
    if (isBeingServed) {
      borderColor = Colors.green;
    } else if (isNextUp) {
      borderColor = Colors.orange;
    } else {
      borderColor = Colors.grey.shade400;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: borderColor, width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Text(
                    '#${ticket.queueNumber}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      ticket.establishmentName,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      ticket.establishmentAddress,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              const Icon(Icons.people_alt, size: 16, color: Colors.grey),
              const SizedBox(width: 6),
              Text(
                peopleAhead <= 0
                    ? (isEnglish
                        ? "It's your turn!"
                        : "C'est votre tour !")
                    : (isEnglish
                        ? '$peopleAhead ahead of you'
                        : '$peopleAhead devant vous'),
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: peopleAhead <= 0 ? Colors.green : Colors.grey[700],
                ),
              ),
              const Spacer(),
              const Icon(Icons.play_circle_filled,
                  size: 16, color: Colors.blue),
              const SizedBox(width: 6),
              Text(
                '${isEnglish ? 'Serving' : 'Service en cours'} #$currentlyServing',
                style:
                    const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _TicketCountBadge extends StatelessWidget {
  const _TicketCountBadge({required this.count});

  final int count;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: Theme.of(context).primaryColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        '$count',
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

class _EmptyTicketsCard extends StatelessWidget {
  const _EmptyTicketsCard({required this.localizations});

  final AppLocalizations localizations;

  @override
  Widget build(BuildContext context) {
    final isEnglish = localizations.language == 'Language';
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Theme.of(context)
                  .primaryColor
                  .withAlpha((255 * 0.15).round()),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                Icons.confirmation_number_outlined,
                color: Theme.of(context).primaryColor,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    isEnglish
                        ? 'No tickets purchased yet'
                        : "Aucun billet acheté pour l'instant",
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    isEnglish
                        ? 'Buy a ticket to see it here instantly.'
                        : 'Achetez un billet pour le voir apparaître ici immédiatement.',
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
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
