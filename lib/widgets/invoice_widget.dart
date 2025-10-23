import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../utils/app_localizations.dart';
import '../models/queue_models.dart';

class InvoiceWidget extends StatefulWidget {
  final ScrollController scrollController;
  final QueueTicket ticket;
  final Payment payment;

  const InvoiceWidget({
    super.key,
    required this.scrollController,
    required this.ticket,
    required this.payment,
  });

  @override
  State<InvoiceWidget> createState() => _InvoiceWidgetState();
}

class _InvoiceWidgetState extends State<InvoiceWidget> {
  bool _isEmailSent = false;
  bool _isProcessing = false;

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    final invoice = Invoice.generate(widget.ticket, widget.payment);
    
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
                  Icons.receipt_long,
                  color: Theme.of(context).primaryColor,
                  size: 24,
                ),
                const SizedBox(width: 8),
                Text(
                  localizations.language == 'Language'
                    ? 'Factura'
                    : 'Facture',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
          ),
          
          const Divider(height: 1),
          
          // Invoice content
          Expanded(
            child: SingleChildScrollView(
              controller: widget.scrollController,
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Invoice header
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
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
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'QuikTik',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          localizations.language == 'Language'
                            ? 'Queue Management System'
                            : 'Système de Gestion de Files',
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  localizations.language == 'Language'
                                    ? 'Invoice #'
                                    : 'Facture #',
                                  style: const TextStyle(
                                    color: Colors.white70,
                                    fontSize: 12,
                                  ),
                                ),
                                Text(
                                  invoice.invoiceNumber,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  localizations.language == 'Language'
                                    ? 'Date'
                                    : 'Date',
                                  style: const TextStyle(
                                    color: Colors.white70,
                                    fontSize: 12,
                                  ),
                                ),
                                Text(
                                  _formatDate(invoice.issueDate),
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Establishment info
                  _buildSection(
                    localizations.language == 'Language'
                      ? 'Service Provider'
                      : 'Fournisseur de Service',
                    [
                      widget.ticket.establishmentName,
                      widget.ticket.establishmentAddress,
                    ],
                  ),
                  
                  const SizedBox(height: 20),
                  
                  // Ticket details
                  _buildSection(
                    localizations.language == 'Language'
                      ? 'Ticket Details'
                      : 'Détails du Billet',
                    [
                      '${localizations.language == 'Language' ? 'Queue Number' : 'Numéro de File'}: #${widget.ticket.queueNumber}',
                      '${localizations.language == 'Language' ? 'Ticket ID' : 'ID du Billet'}: ${widget.ticket.id.substring(0, 8).toUpperCase()}',
                      '${localizations.language == 'Language' ? 'Purchase Time' : 'Heure d\'Achat'}: ${_formatDateTime(widget.ticket.purchaseTime)}',
                      '${localizations.language == 'Language' ? 'Valid Until' : 'Valide Jusqu\'à'}: ${_formatDateTime(widget.ticket.expirationTime)}',
                    ],
                  ),
                  
                  const SizedBox(height: 20),
                  
                  // Payment details
                  _buildSection(
                    localizations.language == 'Language'
                      ? 'Payment Details'
                      : 'Détails de Paiement',
                    [
                      '${localizations.language == 'Language' ? 'Amount' : 'Montant'}: \$${widget.payment.amount.toStringAsFixed(2)} CAD',
                      '${localizations.language == 'Language' ? 'Payment Method' : 'Méthode de Paiement'}: ${widget.payment.method.getDisplayText(Localizations.localeOf(context).languageCode)}',
                      '${localizations.language == 'Language' ? 'Transaction ID' : 'ID de Transaction'}: ${widget.payment.transactionId}',
                      '${localizations.language == 'Language' ? 'Status' : 'Statut'}: ${widget.payment.status.getDisplayText(Localizations.localeOf(context).languageCode)}',
                    ],
                  ),
                  
                  const SizedBox(height: 20),
                  
                  // Total section
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.grey[50],
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey[200]!),
                    ),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              localizations.language == 'Language'
                                ? 'Queue Number Fee'
                                : 'Frais de Numéro de File',
                              style: const TextStyle(fontSize: 14),
                            ),
                            Text(
                              '\$${widget.payment.amount.toStringAsFixed(2)}',
                              style: const TextStyle(fontSize: 14),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              localizations.language == 'Language'
                                ? 'Taxes (HST)'
                                : 'Taxes (TVH)',
                              style: const TextStyle(fontSize: 14),
                            ),
                            const Text(
                              '\$0.00',
                              style: TextStyle(fontSize: 14),
                            ),
                          ],
                        ),
                        const Divider(height: 24),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              localizations.language == 'Language'
                                ? 'Total Amount'
                                : 'Montant Total',
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              '\$${widget.payment.amount.toStringAsFixed(2)} CAD',
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.green,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Terms and conditions
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.yellow[50],
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.yellow[200]!),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          localizations.language == 'Language'
                            ? 'Terms & Conditions'
                            : 'Termes et Conditions',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          localizations.language == 'Language'
                            ? '• Tickets are non-refundable\n• Valid only for the specified establishment\n• Must be used within the validity period\n• Queue position may change based on availability'
                            : '• Les billets ne sont pas remboursables\n• Valide seulement pour l\'établissement spécifié\n• Doit être utilisé dans la période de validité\n• La position dans la file peut changer selon la disponibilité',
                          style: TextStyle(
                            fontSize: 10,
                            color: Colors.yellow[800],
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
          
          // Action buttons
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, -5),
                ),
              ],
            ),
            child: Column(
              children: [
                // Print and Email buttons
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: _isProcessing ? null : _handlePrint,
                        icon: const Icon(Icons.print),
                        label: Text(
                          localizations.language == 'Language'
                            ? 'Print'
                            : 'Imprimer',
                        ),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: _isProcessing ? null : _handleEmail,
                        icon: _isProcessing
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : Icon(_isEmailSent ? Icons.check : Icons.email),
                        label: Text(
                          _isEmailSent
                            ? (localizations.language == 'Language' ? 'Sent!' : 'Envoyé!')
                            : (localizations.language == 'Language' ? 'Email' : 'E-mail'),
                        ),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          backgroundColor: _isEmailSent ? Colors.green : null,
                        ),
                      ),
                    ),
                  ],
                ),
                
                if (_isEmailSent) ...[
                  const SizedBox(height: 8),
                  Text(
                    localizations.language == 'Language'
                      ? 'Invoice sent to your email'
                      : 'Facture envoyée à votre e-mail',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.green[600],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSection(String title, List<String> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.grey[50],
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey[200]!),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: items.map((item) => Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Text(
                item,
                style: const TextStyle(fontSize: 14),
              ),
            )).toList(),
          ),
        ),
      ],
    );
  }

  void _handlePrint() {
    HapticFeedback.lightImpact();
    
    // Show print dialog
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Icon(Icons.print, color: Theme.of(context).primaryColor),
            const SizedBox(width: 8),
            const Text('Print Invoice'),
          ],
        ),
        content: const Text(
          'This will open your device\'s print dialog. Make sure you have a printer connected.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              _simulatePrint();
            },
            child: const Text('Print'),
          ),
        ],
      ),
    );
  }

  void _simulatePrint() {
    // In a real app, this would integrate with the platform's print service
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.white),
            const SizedBox(width: 8),
            Text(
              AppLocalizations.of(context)!.language == 'Language'
                ? 'Print job sent to printer'
                : 'Travail d\'impression envoyé à l\'imprimante',
            ),
          ],
        ),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  void _handleEmail() async {
    if (_isProcessing || _isEmailSent) return;
    
    setState(() {
      _isProcessing = true;
    });

    HapticFeedback.lightImpact();
    
    // Simulate email sending delay
    await Future.delayed(const Duration(seconds: 2));
    
    if (mounted) {
      setState(() {
        _isProcessing = false;
        _isEmailSent = true;
      });
      
      HapticFeedback.selectionClick();
    }
  }

  String _formatDate(DateTime dateTime) {
    return '${dateTime.day.toString().padLeft(2, '0')}/${dateTime.month.toString().padLeft(2, '0')}/${dateTime.year}';
  }

  String _formatDateTime(DateTime dateTime) {
    return '${_formatDate(dateTime)} ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }
}