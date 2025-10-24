import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'confirmation_screen.dart';
import '../utils/app_localizations.dart';
import '../models/location_models.dart';
import '../models/queue_models.dart';
import '../services/queue_service.dart';

class PaymentScreen extends StatefulWidget {
  final Establishment establishment;

  const PaymentScreen({super.key, required this.establishment});

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  PaymentMethod _selectedMethod = PaymentMethod.creditCard;
  bool _isProcessing = false;
  final _cardNumberController = TextEditingController();
  final _expiryController = TextEditingController();
  final _cvvController = TextEditingController();
  final _nameController = TextEditingController();

  @override
  void dispose() {
    _cardNumberController.dispose();
    _expiryController.dispose();
    _cvvController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    final queueService = Provider.of<QueueService>(context, listen: false);
    final userTicketCount = queueService.getUserTicketCountForEstablishment(widget.establishment.id);
    
    return Scaffold(
      appBar: AppBar(
        title: Text(
          localizations.language == 'Language' 
            ? 'Payment Required' 
            : 'Paiement Requis'
        ),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Establishment info card
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.business,
                          color: Theme.of(context).primaryColor,
                          size: 24,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            widget.establishment.name,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      widget.establishment.address,
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.orange.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.info_outline,
                            color: Colors.orange[700],
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              localizations.language == 'Language'
                                ? 'You have $userTicketCount/4 queue tickets for this establishment'
                                : 'Vous avez $userTicketCount/4 billets de file pour cet établissement',
                              style: TextStyle(
                                color: Colors.orange[700],
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Payment amount
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Theme.of(context).primaryColor,
                    Theme.of(context).primaryColor.withValues(alpha: 0.8),
                  ],
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  Text(
                    localizations.language == 'Language'
                      ? 'Queue Access Fee'
                      : 'Frais d\'Accès à la File',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '\$${QueueService.queueAccessFee.toStringAsFixed(2)}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    localizations.language == 'Language'
                      ? 'per queue number'
                      : 'par numéro de file',
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Payment method selection
            Text(
              localizations.language == 'Language'
                ? 'Select Payment Method'
                : 'Sélectionnez le Mode de Paiement',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            
            RadioGroup<PaymentMethod>(
              onChanged: (PaymentMethod? value) {
                if (value != null) {
                  setState(() {
                    _selectedMethod = value;
                  });
                }
              },
              child: Column(
                children: PaymentMethod.values.map((method) => 
                  _buildPaymentMethodTile(method, localizations)
                ).toList(),
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Payment form based on selected method
            if (_selectedMethod == PaymentMethod.creditCard || _selectedMethod == PaymentMethod.debitCard)
              _buildCardPaymentForm(localizations),
            
            const SizedBox(height: 32),
            
            // Action buttons
            Row(
              children: [
                // Cancel button
                Expanded(
                  child: OutlinedButton(
                    onPressed: _isProcessing ? null : () => Navigator.of(context).pop(),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.grey[600],
                      side: BorderSide(color: Colors.grey[400]!),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.arrow_back, size: 20),
                        const SizedBox(width: 8),
                        Text(
                          localizations.language == 'Language'
                            ? 'Cancel'
                            : 'Annuler',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                // Pay button
                Expanded(
                  flex: 2,
                  child: ElevatedButton(
                    onPressed: _isProcessing ? null : _processPayment,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).primaryColor,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: _isProcessing
                      ? Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Text(
                              localizations.language == 'Language'
                                ? 'Processing...'
                                : 'Traitement...',
                            ),
                          ],
                        )
                      : Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.payment, size: 20),
                            const SizedBox(width: 8),
                            Text(
                              localizations.language == 'Language'
                                ? 'Pay \$${QueueService.queueAccessFee.toStringAsFixed(2)}'
                                : 'Payer \$${QueueService.queueAccessFee.toStringAsFixed(2)}',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentMethodTile(PaymentMethod method, AppLocalizations localizations) {
    final isSelected = _selectedMethod == method;
    
    return Card(
      elevation: isSelected ? 4 : 1,
      margin: const EdgeInsets.only(bottom: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(
          color: isSelected ? Theme.of(context).primaryColor : Colors.transparent,
          width: 2,
        ),
      ),
      child: ListTile(
        leading: Icon(
          method.icon,
          color: isSelected ? Theme.of(context).primaryColor : Colors.grey[600],
        ),
        title: Text(
          method.getDisplayText(Localizations.localeOf(context).languageCode),
          style: TextStyle(
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            color: isSelected ? Theme.of(context).primaryColor : Colors.black,
          ),
        ),
        trailing: Radio<PaymentMethod>(
          value: method,
        ),
        onTap: () {
          setState(() {
            _selectedMethod = method;
          });
        },
      ),
    );
  }

  Widget _buildCardPaymentForm(AppLocalizations localizations) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          localizations.language == 'Language'
            ? 'Card Information'
            : 'Informations de la Carte',
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        
        TextFormField(
          controller: _cardNumberController,
          decoration: InputDecoration(
            labelText: localizations.language == 'Language'
              ? 'Card Number'
              : 'Numéro de Carte',
            prefixIcon: const Icon(Icons.credit_card),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            hintText: '1234 5678 9012 3456',
          ),
          keyboardType: TextInputType.number,
        ),
        const SizedBox(height: 16),
        
        Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: _expiryController,
                decoration: InputDecoration(
                  labelText: localizations.language == 'Language'
                    ? 'MM/YY'
                    : 'MM/AA',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                  hintText: '12/25',
                ),
                keyboardType: TextInputType.number,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: TextFormField(
                controller: _cvvController,
                decoration: InputDecoration(
                  labelText: 'CVV',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                  hintText: '123',
                ),
                keyboardType: TextInputType.number,
                obscureText: true,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        
        TextFormField(
          controller: _nameController,
          decoration: InputDecoration(
            labelText: localizations.language == 'Language'
              ? 'Cardholder Name'
              : 'Nom du Titulaire',
            prefixIcon: const Icon(Icons.person_outline),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          ),
        ),
      ],
    );
  }

  Future<void> _processPayment() async {
    final queueService = Provider.of<QueueService>(context, listen: false);
    if (!queueService.canPurchaseMoreTickets(widget.establishment.id)) {
      final localizations = AppLocalizations.of(context)!;
      _showErrorDialog(
        localizations.maxTicketsReachedTitle,
        localizations.maxTicketsReachedBody,
      );
      return;
    }

    setState(() {
      _isProcessing = true;
    });

    final localizations = AppLocalizations.of(context)!;

    try {
      final payment = await queueService.processPayment(
        establishmentId: widget.establishment.id,
        method: _selectedMethod,
        amount: QueueService.queueAccessFee,
        description: 'Queue access fee for ${widget.establishment.name}',
      );

      final queueStatus = queueService.getQueueStatus(widget.establishment.id);
      if (queueStatus != null && queueStatus.availableNumbers.isNotEmpty) {
        final purchasedNumber = queueStatus.availableNumbers.first;
        
        final ticket = await queueService.purchaseQueueNumber(
          establishmentId: widget.establishment.id,
          establishmentName: widget.establishment.name,
          establishmentAddress: widget.establishment.address,
          queueNumber: purchasedNumber,
          paymentId: payment.id,
        );

        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => ConfirmationScreen(
                purchasedNumber: ticket.queueNumber,
              ),
            ),
          );
        }
      } else {
        if (mounted) {
          _showErrorDialog(
            localizations.queueFullTitle,
            localizations.queueFullBody,
          );
        }
      }
    } catch (e) {
      if (mounted) {
        _showErrorDialog(
          localizations.paymentFailedTitle,
          localizations.paymentFailedBody,
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isProcessing = false;
        });
      }
    }
  }

  void _showErrorDialog(String title, String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              AppLocalizations.of(context)!.ok,
            ),
          ),
        ],
      ),
    );
  }
}