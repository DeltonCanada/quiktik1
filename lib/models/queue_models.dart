import 'package:flutter/material.dart';

class QueueTicket {
  final String id;
  final String establishmentId;
  final String establishmentName;
  final String establishmentAddress;
  final int queueNumber;
  final DateTime purchaseTime;
  final DateTime expirationTime;
  final QueueTicketStatus status;
  final String paymentId;
  final double amount;
  final DateTime? turnStartTime; // When customer's turn started (for countdown)

  QueueTicket({
    required this.id,
    required this.establishmentId,
    required this.establishmentName,
    required this.establishmentAddress,
    required this.queueNumber,
    required this.purchaseTime,
    required this.expirationTime,
    required this.status,
    required this.paymentId,
    required this.amount,
    this.turnStartTime,
  });

  bool get isActive => status == QueueTicketStatus.active;
  bool get isExpired => DateTime.now().isAfter(expirationTime);
  bool get isUsed => status == QueueTicketStatus.used;
  bool get isYourTurn => status == QueueTicketStatus.yourTurn;
  
  // Countdown functionality for when it's customer's turn
  Duration? get remainingTime {
    if (!isYourTurn || turnStartTime == null) return null;
    
    const fiveMinutes = Duration(minutes: 5);
    final elapsed = DateTime.now().difference(turnStartTime!);
    final remaining = fiveMinutes - elapsed;
    
    return remaining.isNegative ? Duration.zero : remaining;
  }
  
  bool get countdownExpired {
    final remaining = remainingTime;
    return remaining != null && remaining == Duration.zero;
  }
  
  String get countdownText {
    final remaining = remainingTime;
    if (remaining == null) return '';
    
    final minutes = remaining.inMinutes;
    final seconds = remaining.inSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  QueueTicket copyWith({
    String? id,
    String? establishmentId,
    String? establishmentName,
    String? establishmentAddress,
    int? queueNumber,
    DateTime? purchaseTime,
    DateTime? expirationTime,
    QueueTicketStatus? status,
    String? paymentId,
    double? amount,
    DateTime? turnStartTime,
  }) {
    return QueueTicket(
      id: id ?? this.id,
      establishmentId: establishmentId ?? this.establishmentId,
      establishmentName: establishmentName ?? this.establishmentName,
      establishmentAddress: establishmentAddress ?? this.establishmentAddress,
      queueNumber: queueNumber ?? this.queueNumber,
      purchaseTime: purchaseTime ?? this.purchaseTime,
      expirationTime: expirationTime ?? this.expirationTime,
      status: status ?? this.status,
      paymentId: paymentId ?? this.paymentId,
      amount: amount ?? this.amount,
      turnStartTime: turnStartTime ?? this.turnStartTime,
    );
  }
}

enum QueueTicketStatus {
  active,
  yourTurn, // Customer's turn with 5-minute countdown
  used,
  expired,
  cancelled,
}

extension QueueTicketStatusExtension on QueueTicketStatus {
  String getDisplayText(String languageCode) {
    switch (this) {
      case QueueTicketStatus.active:
        return languageCode == 'fr' ? 'Actif' : 'Active';
      case QueueTicketStatus.yourTurn:
        return languageCode == 'fr' ? 'Votre Tour!' : 'Your Turn!';
      case QueueTicketStatus.used:
        return languageCode == 'fr' ? 'Utilisé' : 'Used';
      case QueueTicketStatus.expired:
        return languageCode == 'fr' ? 'Expiré' : 'Expired';
      case QueueTicketStatus.cancelled:
        return languageCode == 'fr' ? 'Annulé' : 'Cancelled';
    }
  }

  Color get color {
    switch (this) {
      case QueueTicketStatus.active:
        return Colors.green;
      case QueueTicketStatus.yourTurn:
        return Colors.orange; // Urgent orange for "Your Turn!"
      case QueueTicketStatus.used:
        return Colors.blue;
      case QueueTicketStatus.expired:
        return Colors.red;
      case QueueTicketStatus.cancelled:
        return Colors.grey;
    }
  }
}

class QueueStatus {
  final String establishmentId;
  final int currentlyServing;
  final List<int> availableNumbers;
  final int totalWaiting;
  final DateTime lastUpdated;

  QueueStatus({
    required this.establishmentId,
    required this.currentlyServing,
    required this.availableNumbers,
    required this.totalWaiting,
    required this.lastUpdated,
  });

  QueueStatus copyWith({
    String? establishmentId,
    int? currentlyServing,
    List<int>? availableNumbers,
    int? totalWaiting,
    DateTime? lastUpdated,
  }) {
    return QueueStatus(
      establishmentId: establishmentId ?? this.establishmentId,
      currentlyServing: currentlyServing ?? this.currentlyServing,
      availableNumbers: availableNumbers ?? this.availableNumbers,
      totalWaiting: totalWaiting ?? this.totalWaiting,
      lastUpdated: lastUpdated ?? this.lastUpdated,
    );
  }
}

class Payment {
  final String id;
  final double amount;
  final PaymentMethod method;
  final PaymentStatus status;
  final DateTime timestamp;
  final String description;
  final String establishmentId;
  final String? transactionId;

  Payment({
    required this.id,
    required this.amount,
    required this.method,
    required this.status,
    required this.timestamp,
    required this.description,
    required this.establishmentId,
    this.transactionId,
  });

  Payment copyWith({
    String? id,
    double? amount,
    PaymentMethod? method,
    PaymentStatus? status,
    DateTime? timestamp,
    String? description,
    String? establishmentId,
    String? transactionId,
  }) {
    return Payment(
      id: id ?? this.id,
      amount: amount ?? this.amount,
      method: method ?? this.method,
      status: status ?? this.status,
      timestamp: timestamp ?? this.timestamp,
      description: description ?? this.description,
      establishmentId: establishmentId ?? this.establishmentId,
      transactionId: transactionId ?? this.transactionId,
    );
  }
}

enum PaymentMethod {
  creditCard,
  debitCard,
  paypal,
  applePay,
  googlePay,
}

enum PaymentStatus {
  pending,
  completed,
  failed,
  refunded,
}

extension PaymentStatusExtension on PaymentStatus {
  String getDisplayText(String languageCode) {
    switch (this) {
      case PaymentStatus.pending:
        return languageCode == 'fr' ? 'En Attente' : 'Pending';
      case PaymentStatus.completed:
        return languageCode == 'fr' ? 'Complété' : 'Completed';
      case PaymentStatus.failed:
        return languageCode == 'fr' ? 'Échec' : 'Failed';
      case PaymentStatus.refunded:
        return languageCode == 'fr' ? 'Remboursé' : 'Refunded';
    }
  }

  Color get color {
    switch (this) {
      case PaymentStatus.pending:
        return Colors.orange;
      case PaymentStatus.completed:
        return Colors.green;
      case PaymentStatus.failed:
        return Colors.red;
      case PaymentStatus.refunded:
        return Colors.blue;
    }
  }
}

extension PaymentMethodExtension on PaymentMethod {
  String getDisplayText(String languageCode) {
    switch (this) {
      case PaymentMethod.creditCard:
        return languageCode == 'fr' ? 'Carte de Crédit' : 'Credit Card';
      case PaymentMethod.debitCard:
        return languageCode == 'fr' ? 'Carte de Débit' : 'Debit Card';
      case PaymentMethod.paypal:
        return 'PayPal';
      case PaymentMethod.applePay:
        return 'Apple Pay';
      case PaymentMethod.googlePay:
        return 'Google Pay';
    }
  }

  IconData get icon {
    switch (this) {
      case PaymentMethod.creditCard:
      case PaymentMethod.debitCard:
        return Icons.credit_card;
      case PaymentMethod.paypal:
        return Icons.account_balance_wallet;
      case PaymentMethod.applePay:
        return Icons.phone_iphone;
      case PaymentMethod.googlePay:
        return Icons.android;
    }
  }
}

class Invoice {
  final String id;
  final String paymentId;
  final String establishmentName;
  final String establishmentAddress;
  final DateTime issueDate;
  final String invoiceNumber;
  final List<InvoiceItem> items;
  final double subtotal;
  final double tax;
  final double total;
  final PaymentMethod paymentMethod;
  final String? customerEmail;

  Invoice({
    required this.id,
    required this.paymentId,
    required this.establishmentName,
    required this.establishmentAddress,
    required this.issueDate,
    required this.invoiceNumber,
    required this.items,
    required this.subtotal,
    required this.tax,
    required this.total,
    required this.paymentMethod,
    this.customerEmail,
  });

  factory Invoice.generate(QueueTicket ticket, Payment payment) {
    final invoiceNumber =
        'QT-${DateTime.now().millisecondsSinceEpoch.toString().substring(8)}';
    final item = InvoiceItem(
      description: 'Queue Number #${ticket.queueNumber}',
      quantity: 1,
      unitPrice: payment.amount,
      total: payment.amount,
    );

    return Invoice(
      id: 'inv_${ticket.id}',
      paymentId: payment.id,
      establishmentName: ticket.establishmentName,
      establishmentAddress: ticket.establishmentAddress,
      issueDate: payment.timestamp,
      invoiceNumber: invoiceNumber,
      items: [item],
      subtotal: payment.amount,
      tax: 0.0, // No tax for queue management
      total: payment.amount,
      paymentMethod: payment.method,
    );
  }
}

class InvoiceItem {
  final String description;
  final int quantity;
  final double unitPrice;
  final double total;

  InvoiceItem({
    required this.description,
    required this.quantity,
    required this.unitPrice,
    required this.total,
  });
}
