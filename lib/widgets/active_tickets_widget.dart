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
            child: Row(
              children: [
                Icon(
                  Icons.confirmation_number,
                  color: Theme.of(context).primaryColor,
                  size: 24,
                ),
                const SizedBox(width: 8),
                Text(
                  localizations.language == 'Language'
                    ? 'Mis Boletos'
                    : 'Mes Billets',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                Text(
                  '${activeTickets.length}',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[600],
                  ),
                ),
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
                        final queueStatus = queueStatuses[ticket.establishmentId];
                        return _buildTicketCard(ticket, queueStatus, localizations);
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

  Widget _buildTicketCard(QueueTicket ticket, QueueStatus? queueStatus, AppLocalizations localizations) {
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
                colors: [Colors.green.withValues(alpha: 0.1), Colors.green.withValues(alpha: 0.05)],
              )
            : (isNext
                ? LinearGradient(
                    colors: [Colors.orange.withValues(alpha: 0.1), Colors.orange.withValues(alpha: 0.05)],
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
                        : (isNext ? Colors.orange : Theme.of(context).primaryColor),
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
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: ticket.status.color.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      ticket.status.getDisplayText(Localizations.localeOf(context).languageCode),
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
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            localizations.language == 'Language'
                              ? 'Currently Serving'
                              : 'Actuellement Servi',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                          Text(
                            '#${queueStatus.currentlyServing}',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
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
                              ? 'Your Position'
                              : 'Votre Position',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                          Text(
                            queuePosition <= 0 
                              ? (localizations.language == 'Language' ? 'Your turn!' : 'Votre tour!')
                              : '$queuePosition ${localizations.language == 'Language' ? 'ahead' : 'devant'}',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: queuePosition <= 0 ? Colors.green : Colors.grey[700],
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
                      const Icon(Icons.notifications_active, color: Colors.green, size: 16),
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
                      const Icon(Icons.hourglass_top, color: Colors.orange, size: 16),
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
              
              // Purchase time
              const SizedBox(height: 8),
              Text(
                '${localizations.language == 'Language' ? 'Purchased' : 'Acheté'}: ${_formatDateTime(ticket.purchaseTime)}',
                style: TextStyle(
                  fontSize: 10,
                  color: Colors.grey[500],
                ),
              ),
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