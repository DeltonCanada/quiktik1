import 'package:flutter/material.dart';
import '../utils/app_localizations.dart';
import '../models/queue_models.dart';
import '../services/queue_service.dart';

class ActiveTicketsWidget extends StatefulWidget {
  final ScrollController scrollController;

  const ActiveTicketsWidget({
    super.key,
    required this.scrollController,
  });

  @override
  State<ActiveTicketsWidget> createState() => _ActiveTicketsWidgetState();
}

class _ActiveTicketsWidgetState extends State<ActiveTicketsWidget> {
  final QueueService _queueService = QueueService();
  late Stream<Map<String, QueueStatus>> _queueStatusStream;

  @override
  void initState() {
    super.initState();
    _queueStatusStream = _queueService.queueStatusStream;
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    final activeTickets = _queueService.getActiveTickets();

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          // Handle bar
          Container(
            margin: const EdgeInsets.only(top: 8),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Header
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.confirmation_number,
                      color: Theme.of(context).primaryColor,
                      size: 24,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      localizations.language == 'Language'
                          ? 'My Active Tickets'
                          : 'Mes Billets Actifs',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Theme.of(context).primaryColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Text(
                        '${activeTickets.length}',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).primaryColor,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                // Total purchase amount summary
                if (activeTickets.isNotEmpty) ...[
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.green.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.green.withValues(alpha: 0.3)),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.account_balance_wallet, color: Colors.green, size: 20),
                        const SizedBox(width: 8),
                        Text(
                          localizations.language == 'Language'
                              ? 'Total Purchases: '
                              : 'Total des Achats: ',
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Colors.green,
                          ),
                        ),
                        Text(
                          '\$${activeTickets.fold(0.0, (sum, ticket) => sum + ticket.amount).toStringAsFixed(2)}',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.green,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),

          const Divider(height: 1),

          // Tickets list
          Expanded(
            child: activeTickets.isEmpty
                ? _buildEmptyState(localizations)
                : StreamBuilder<Map<String, QueueStatus>>(
                    stream: _queueStatusStream,
                    builder: (context, snapshot) {
                      final queueStatuses = snapshot.data ?? {};

                      return ListView.builder(
                        controller: widget.scrollController,
                        padding: const EdgeInsets.all(16),
                        itemCount: activeTickets.length,
                        itemBuilder: (context, index) {
                          final ticket = activeTickets[index];
                          final queueStatus =
                              queueStatuses[ticket.establishmentId];
                          return _buildTicketCard(
                              ticket, queueStatus, localizations);
                        },
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(AppLocalizations localizations) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.inbox_outlined,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            localizations.language == 'Language'
                ? 'No Active Tickets'
                : 'Aucun Billet Actif',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            localizations.language == 'Language'
                ? 'Purchase queue numbers to see them here'
                : 'Achetez des numéros de file pour les voir ici',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[500],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildTicketCard(QueueTicket ticket, QueueStatus? queueStatus,
      AppLocalizations localizations) {
    final currentlyServing = queueStatus?.currentlyServing ?? 0;
    final queuePosition = ticket.queueNumber - currentlyServing;
    final isNext = queuePosition <= 3 && queuePosition > 0;
    final isBeingServed = ticket.queueNumber == currentlyServing;

    return Card(
      elevation: isBeingServed ? 8 : (isNext ? 4 : 2),
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: isBeingServed
              ? Colors.green
              : (isNext ? Colors.orange : Colors.transparent),
          width: isBeingServed || isNext ? 2 : 0,
        ),
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: isBeingServed
              ? LinearGradient(
                  colors: [
                    Colors.green.withValues(alpha: 0.1),
                    Colors.green.withValues(alpha: 0.05)
                  ],
                )
              : (isNext
                  ? LinearGradient(
                      colors: [
                        Colors.orange.withValues(alpha: 0.1),
                        Colors.orange.withValues(alpha: 0.05)
                      ],
                    )
                  : null),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with number and status
              Row(
                children: [
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      color: isBeingServed
                          ? Colors.green
                          : (isNext
                              ? Colors.orange
                              : Theme.of(context).primaryColor),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Center(
                      child: Text(
                        '#${ticket.queueNumber}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
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
                            fontWeight: FontWeight.bold,
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
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: ticket.status.color.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      ticket.status.getDisplayText(
                          Localizations.localeOf(context).languageCode),
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: ticket.status.color,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // Queue status
              if (queueStatus != null) ...[
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey[50],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey.withValues(alpha: 0.2)),
                  ),
                  child: Column(
                    children: [
                      // Currently serving section
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: isBeingServed ? Colors.green.withValues(alpha: 0.2) : Colors.blue.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              isBeingServed ? Icons.person_pin : Icons.people_outline,
                              color: isBeingServed ? Colors.green : Colors.blue,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              localizations.language == 'Language'
                                  ? 'Now Serving: '
                                  : 'Maintenant Servi: ',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: isBeingServed ? Colors.green : Colors.blue,
                              ),
                            ),
                            Text(
                              '#${queueStatus.currentlyServing}',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: isBeingServed ? Colors.green : Colors.blue,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            localizations.language == 'Language'
                                ? 'Your Position'
                                : 'Votre Position',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                          Text(
                            queuePosition <= 0
                                ? (localizations.language == 'Language'
                                    ? 'Your turn!'
                                    : 'Votre tour!')
                                : '$queuePosition ${localizations.language == 'Language' ? 'ahead' : 'devant'}',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: queuePosition <= 0
                                  ? Colors.green
                                  : Colors.grey[700],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
              ],

              // Status messages
              if (isBeingServed)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.green.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.notifications_active,
                          color: Colors.green, size: 16),
                      const SizedBox(width: 8),
                      Text(
                        localizations.language == 'Language'
                            ? 'You\'re being served now!'
                            : 'Vous êtes servi maintenant!',
                        style: const TextStyle(
                          color: Colors.green,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                )
              else if (isNext)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.orange.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.hourglass_top,
                          color: Colors.orange, size: 16),
                      const SizedBox(width: 8),
                      Text(
                        localizations.language == 'Language'
                            ? 'You\'re up next!'
                            : 'C\'est bientôt votre tour!',
                        style: const TextStyle(
                          color: Colors.orange,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),

              // Purchase information
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.blue.withValues(alpha: 0.2)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.receipt, color: Colors.blue, size: 16),
                        const SizedBox(width: 6),
                        Text(
                          localizations.language == 'Language'
                              ? 'Purchase Details'
                              : 'Détails d\'Achat',
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          localizations.language == 'Language'
                              ? 'Amount Paid:'
                              : 'Montant Payé:',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                        Text(
                          '\$${ticket.amount.toStringAsFixed(2)}',
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Colors.green,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          localizations.language == 'Language'
                              ? 'Purchase Time:'
                              : 'Heure d\'Achat:',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                        Text(
                          _formatDateTime(ticket.purchaseTime),
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: Colors.grey[700],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          localizations.language == 'Language'
                              ? 'Payment ID:'
                              : 'ID de Paiement:',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                        Text(
                          ticket.paymentId.substring(0, 8).toUpperCase(),
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: Colors.grey[700],
                            fontFamily: 'monospace',
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 12),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.day}/${dateTime.month}/${dateTime.year} ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }
}
