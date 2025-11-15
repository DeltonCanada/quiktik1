import 'dart:async';
import 'dart:math';
import 'dart:developer' as developer;
import '../models/queue_models.dart';
import '../models/location_models.dart';

class QueueService {
  static final QueueService _instance = QueueService._internal();
  factory QueueService() => _instance;
  QueueService._internal();

  final Map<String, QueueStatus> _queueStatuses = {};
  final List<QueueTicket> _userTickets = [];
  final List<Payment> _userPayments = [];
  final StreamController<Map<String, QueueStatus>> _queueStatusController =
      StreamController<Map<String, QueueStatus>>.broadcast();
  Timer? _updateTimer;

  static const double queueAccessFee = 2.50; // $2.50 per queue access

  Stream<Map<String, QueueStatus>> get queueStatusStream =>
      _queueStatusController.stream;
  List<QueueTicket> get userTickets => _userTickets;
  List<Payment> get userPayments => _userPayments;

  void initializeQueues(List<Establishment> establishments) {
    developer.log(
        '🏪 Initializing queues for ${establishments.length} establishments',
        name: 'QueueService');
    bool hasNewQueues = false;

    for (var establishment in establishments) {
      if (_queueStatuses.containsKey(establishment.id)) {
        developer.log(
            '⏭️ Queue already exists for establishment: ${establishment.id}',
            name: 'QueueService');
        continue;
      }

      final availableNumbers = _generateAvailableNumbers();
      final currentlyServing = _generateRandomNumber(1, 20);
      final totalWaiting = _generateRandomNumber(5, 25);

      developer.log('🆕 Creating new queue for ${establishment.id}:',
          name: 'QueueService');
      developer.log('  📋 Available numbers: $availableNumbers',
          name: 'QueueService');
      developer.log('  🎯 Currently serving: $currentlyServing',
          name: 'QueueService');
      developer.log('  👥 Total waiting: $totalWaiting', name: 'QueueService');

      _queueStatuses[establishment.id] = QueueStatus(
        establishmentId: establishment.id,
        currentlyServing: currentlyServing,
        availableNumbers: availableNumbers,
        totalWaiting: totalWaiting,
        lastUpdated: DateTime.now(),
      );

      hasNewQueues = true;
    }

    if (hasNewQueues) {
      developer.log('📤 Broadcasting queue status updates',
          name: 'QueueService');
      _queueStatusController.add(Map<String, QueueStatus>.from(_queueStatuses));
    }

    developer.log(
        '✅ Queue initialization complete. Total queues: ${_queueStatuses.length}',
        name: 'QueueService');

    // Add demo tickets for testing
    _createDemoTickets(establishments);

    _startQueueUpdates();
  }

  void _createDemoTickets(List<Establishment> establishments) {
    if (establishments.isNotEmpty && _userTickets.isEmpty) {
      developer.log('🎫 Creating demo tickets for testing',
          name: 'QueueService');

      // Create 2-3 demo tickets
      for (int i = 0; i < min(3, establishments.length); i++) {
        final establishment = establishments[i];
        final queueStatus = _queueStatuses[establishment.id];
        if (queueStatus != null) {
          final demoNumber =
              queueStatus.currentlyServing + _generateRandomNumber(1, 5);

          final demoTicket = QueueTicket(
            id: 'demo_ticket_${DateTime.now().millisecondsSinceEpoch}_$i',
            establishmentId: establishment.id,
            establishmentName: establishment.name,
            establishmentAddress: establishment.address,
            queueNumber: demoNumber,
            purchaseTime: DateTime.now()
                .subtract(Duration(minutes: _generateRandomNumber(5, 60))),
            expirationTime: DateTime.now().add(const Duration(hours: 24)),
            status: QueueTicketStatus.active,
            paymentId: 'demo_payment_${_generateRandomNumber(100000, 999999)}',
            amount: queueAccessFee,
            turnStartTime: null, // Will be set when it's customer's turn
          );

          _userTickets.add(demoTicket);
          developer.log(
              '🎟️ Created demo ticket #$demoNumber for ${establishment.name}',
              name: 'QueueService');
        }
      }
    }
  }

  List<int> _generateAvailableNumbers() {
    final Random random = Random();
    final Set<int> numbers = {};
    final int baseNumber = random.nextInt(30) + 15; // Start from 15-45

    // Always generate exactly 5 available queue numbers as per requirement
    while (numbers.length < 5) {
      int nextNumber = baseNumber + numbers.length + random.nextInt(5) + 1;
      numbers.add(nextNumber);
    }

    final result = numbers.toList()..sort();
    developer.log('🎲 Generated available numbers: $result',
        name: 'QueueService');
    return result;
  }

  int _generateRandomNumber(int min, int max) {
    return Random().nextInt(max - min + 1) + min;
  }

  void _startQueueUpdates() {
    if (_updateTimer != null) {
      return;
    }

    // Simulate real-time updates every 30 seconds
    _updateTimer = Timer.periodic(const Duration(seconds: 30), (timer) {
      _updateQueueStatuses();
    });
  }

  void _updateQueueStatuses() {
    if (_queueStatuses.isEmpty) {
      return;
    }

    final updatedStatuses = <String, QueueStatus>{};

    for (var entry in _queueStatuses.entries) {
      final status = entry.value;
      final random = Random();

      // Occasionally advance the currently serving number
      int newCurrentlyServing = status.currentlyServing;
      if (random.nextDouble() < 0.3) {
        // 30% chance to advance
        newCurrentlyServing += 1;
      }

      // Update available numbers
      List<int> newAvailableNumbers = [...status.availableNumbers];
      if (random.nextDouble() < 0.4) {
        // 40% chance to update numbers
        newAvailableNumbers = _generateAvailableNumbers();
      }

      updatedStatuses[entry.key] = status.copyWith(
        currentlyServing: newCurrentlyServing,
        availableNumbers: newAvailableNumbers,
        totalWaiting: _generateRandomNumber(3, 30),
        lastUpdated: DateTime.now(),
      );
    }

    _queueStatuses.clear();
    _queueStatuses.addAll(updatedStatuses);
    _queueStatusController.add(Map<String, QueueStatus>.from(_queueStatuses));

    // Check if any customer tickets are now being served (their turn)
    _checkCustomerTurn();
  }

  void _checkCustomerTurn() {
    for (int i = 0; i < _userTickets.length; i++) {
      final ticket = _userTickets[i];

      if (ticket.status == QueueTicketStatus.active) {
        final queueStatus = _queueStatuses[ticket.establishmentId];

        if (queueStatus != null &&
            ticket.queueNumber == queueStatus.currentlyServing) {
          // It's this customer's turn! Start the 5-minute countdown
          _userTickets[i] = ticket.copyWith(
            status: QueueTicketStatus.yourTurn,
            turnStartTime: DateTime.now(),
          );

          developer.log(
              '🎯 Customer turn started! Ticket #${ticket.queueNumber} at ${ticket.establishmentName}',
              name: 'QueueService');
        }
      }

      // Check if countdown has expired
      if (ticket.status == QueueTicketStatus.yourTurn &&
          ticket.countdownExpired) {
        _userTickets[i] = ticket.copyWith(
          status: QueueTicketStatus.expired,
        );

        developer.log('⏰ Countdown expired for ticket #${ticket.queueNumber}',
            name: 'QueueService');
      }
    }
  }

  QueueStatus? getQueueStatus(String establishmentId) {
    developer.log('🔍 Getting queue status for: $establishmentId',
        name: 'QueueService');
    final status = _queueStatuses[establishmentId];
    if (status != null) {
      developer.log(
          '✅ Found queue status: serving ${status.currentlyServing}, available ${status.availableNumbers}',
          name: 'QueueService');
    } else {
      developer.log('❌ No queue status found for: $establishmentId',
          name: 'QueueService');
    }
    return status;
  }

  Future<Payment> processPayment({
    required String establishmentId,
    required PaymentMethod method,
    required double amount,
    required String description,
  }) async {
    // Simulate payment processing delay
    await Future.delayed(const Duration(seconds: 2));

    final payment = Payment(
      id: 'pay_${DateTime.now().millisecondsSinceEpoch}',
      amount: amount,
      method: method,
      status: PaymentStatus.completed, // Simulate successful payment
      timestamp: DateTime.now(),
      description: description,
      establishmentId: establishmentId,
      transactionId: 'txn_${Random().nextInt(999999)}',
    );

    _userPayments.add(payment);
    return payment;
  }

  Future<QueueTicket> purchaseQueueNumber({
    required String establishmentId,
    required String establishmentName,
    required String establishmentAddress,
    required int queueNumber,
    required String paymentId,
  }) async {
    final ticket = QueueTicket(
      id: 'ticket_${DateTime.now().millisecondsSinceEpoch}',
      establishmentId: establishmentId,
      establishmentName: establishmentName,
      establishmentAddress: establishmentAddress,
      queueNumber: queueNumber,
      purchaseTime: DateTime.now(),
      expirationTime:
          DateTime.now().add(const Duration(hours: 24)), // Valid for 24 hours
      status: QueueTicketStatus.active,
      paymentId: paymentId,
      amount: queueAccessFee,
      turnStartTime: null, // Will be set when it's customer's turn
    );

    _userTickets.add(ticket);

    // Remove the purchased number from available numbers
    final status = _queueStatuses[establishmentId];
    if (status != null) {
      final updatedNumbers =
          status.availableNumbers.where((n) => n != queueNumber).toList();
      _queueStatuses[establishmentId] = status.copyWith(
        availableNumbers: updatedNumbers,
        totalWaiting: status.totalWaiting + 1,
      );
      _queueStatusController.add(_queueStatuses);
    }

    return ticket;
  }

  int getUserTicketCountForEstablishment(String establishmentId) {
    return _userTickets
        .where((ticket) =>
            ticket.establishmentId == establishmentId &&
            ticket.status == QueueTicketStatus.active)
        .length;
  }

  bool canPurchaseMoreTickets(String establishmentId) {
    return getUserTicketCountForEstablishment(establishmentId) < 4;
  }

  List<QueueTicket> getActiveTickets() {
    final paidTicketIds = _userPayments
        .where((payment) => payment.status == PaymentStatus.completed)
        .map((payment) => payment.id)
        .toSet();

    return _userTickets
        .where(
          (ticket) =>
              (ticket.status == QueueTicketStatus.active ||
                  ticket.status == QueueTicketStatus.yourTurn) &&
              paidTicketIds.contains(ticket.paymentId),
        )
        .toList();
  }

  List<QueueTicket> getTicketsForEstablishment(String establishmentId) {
    return _userTickets
        .where((ticket) => ticket.establishmentId == establishmentId)
        .toList();
  }

  void cancelTicket(String ticketId) {
    final ticketIndex = _userTickets.indexWhere((t) => t.id == ticketId);
    if (ticketIndex != -1) {
      _userTickets[ticketIndex] = _userTickets[ticketIndex].copyWith(
        status: QueueTicketStatus.cancelled,
      );
    }
  }

  // Method to manually trigger "Your Turn" for testing - simulates when customer's number is called
  void triggerCustomerTurn(String ticketId) {
    final ticketIndex = _userTickets.indexWhere((t) => t.id == ticketId);
    if (ticketIndex != -1) {
      final ticket = _userTickets[ticketIndex];
      if (ticket.status == QueueTicketStatus.active) {
        _userTickets[ticketIndex] = ticket.copyWith(
          status: QueueTicketStatus.yourTurn,
          turnStartTime: DateTime.now(),
        );

        developer.log(
            '🎯 Manually triggered customer turn for ticket #${ticket.queueNumber}',
            name: 'QueueService');
      }
    }
  }

  Invoice generateInvoice(Payment payment, QueueTicket ticket) {
    return Invoice.generate(ticket, payment);
  }

  void dispose() {
    _updateTimer?.cancel();
    _updateTimer = null;
    _queueStatusController.close();
  }
}
