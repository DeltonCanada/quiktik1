import 'dart:async';
import 'dart:math';
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

  Stream<Map<String, QueueStatus>> get queueStatusStream => _queueStatusController.stream;
  List<QueueTicket> get userTickets => _userTickets;
  List<Payment> get userPayments => _userPayments;

  void initializeQueues(List<Establishment> establishments) {
    bool hasNewQueues = false;

    for (var establishment in establishments) {
      if (_queueStatuses.containsKey(establishment.id)) {
        continue;
      }

      _queueStatuses[establishment.id] = QueueStatus(
        establishmentId: establishment.id,
        currentlyServing: _generateRandomNumber(1, 20),
        availableNumbers: _generateAvailableNumbers(),
        totalWaiting: _generateRandomNumber(5, 25),
        lastUpdated: DateTime.now(),
      );

      hasNewQueues = true;
    }

    if (hasNewQueues) {
      _queueStatusController.add(Map<String, QueueStatus>.from(_queueStatuses));
    }

    _startQueueUpdates();
  }

  List<int> _generateAvailableNumbers() {
    final Random random = Random();
    final Set<int> numbers = {};
    final int baseNumber = random.nextInt(50) + 20; // Start from 20-70
    
    // Always generate exactly 5 available queue numbers as per requirement
    while (numbers.length < 5) {
      numbers.add(baseNumber + numbers.length + random.nextInt(3));
    }
    
    return numbers.toList()..sort();
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
      if (random.nextDouble() < 0.3) { // 30% chance to advance
        newCurrentlyServing += 1;
      }
      
      // Update available numbers
      List<int> newAvailableNumbers = [...status.availableNumbers];
      if (random.nextDouble() < 0.4) { // 40% chance to update numbers
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
  }

  QueueStatus? getQueueStatus(String establishmentId) {
    return _queueStatuses[establishmentId];
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
      expirationTime: DateTime.now().add(const Duration(hours: 24)), // Valid for 24 hours
      status: QueueTicketStatus.active,
      paymentId: paymentId,
      amount: queueAccessFee,
    );
    
    _userTickets.add(ticket);
    
    // Remove the purchased number from available numbers
    final status = _queueStatuses[establishmentId];
    if (status != null) {
      final updatedNumbers = status.availableNumbers.where((n) => n != queueNumber).toList();
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
    return _userTickets
        .where((ticket) => ticket.status == QueueTicketStatus.active)
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

  Invoice generateInvoice(Payment payment, QueueTicket ticket) {
    return Invoice.generate(ticket, payment);
  }

  void dispose() {
    _updateTimer?.cancel();
    _updateTimer = null;
    _queueStatusController.close();
  }
}