import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import '../utils/app_localizations.dart';
import '../models/location_models.dart';
import '../models/queue_models.dart';
import '../services/queue_service.dart';
import 'ticket_confirmation_screen.dart';

class QueueNumberSelectionScreen extends StatefulWidget {
  final Establishment establishment;
  final Payment payment;

  const QueueNumberSelectionScreen({
    super.key,
    required this.establishment,
    required this.payment,
  });

  @override
  State<QueueNumberSelectionScreen> createState() =>
      _QueueNumberSelectionScreenState();
}

class _QueueNumberSelectionScreenState
    extends State<QueueNumberSelectionScreen> {
  final QueueService _queueService = QueueService();
  Timer? _timer;
  int _timeRemaining = 600; // 10 minutes in seconds
  int? _selectedNumber;
  List<int> _availableNumbers = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadAvailableNumbers();
    _startTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _loadAvailableNumbers() {
    final queueStatus = _queueService.getQueueStatus(widget.establishment.id);
    if (queueStatus != null) {
      setState(() {
        // Ensure exactly 5 numbers are available
        _availableNumbers = queueStatus.availableNumbers.take(5).toList();
        // If somehow less than 5, generate additional numbers
        if (_availableNumbers.length < 5) {
          _generateAdditionalNumbers();
        }
      });
    } else {
      // Fallback: generate 5 random available numbers
      _generateFallbackNumbers();
    }
  }

  void _generateAdditionalNumbers() {
    final Random random = Random();
    final Set<int> existingNumbers = Set.from(_availableNumbers);
    int nextNumber = _availableNumbers.isNotEmpty
        ? _availableNumbers.last + 1
        : random.nextInt(50) + 20;

    while (_availableNumbers.length < 5) {
      if (!existingNumbers.contains(nextNumber)) {
        _availableNumbers.add(nextNumber);
        existingNumbers.add(nextNumber);
      }
      nextNumber++;
    }

    _availableNumbers.sort();
  }

  void _generateFallbackNumbers() {
    final Random random = Random();
    final Set<int> numbers = {};
    final int baseNumber = random.nextInt(50) + 20; // Start from 20-70

    while (numbers.length < 5) {
      int offset = numbers.length + random.nextInt(3);
      numbers.add(baseNumber + offset);
    }

    setState(() {
      _availableNumbers = numbers.toList()..sort();
    });
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _timeRemaining--;
      });

      if (_timeRemaining <= 0) {
        _timer?.cancel();
        _handleTimeout();
      }
    });
  }

  void _handleTimeout() {
    final localizations = AppLocalizations.of(context)!;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Text(
          localizations.language == 'Language'
              ? 'Time Expired'
              : 'Temps Expiré',
        ),
        content: Text(
          localizations.language == 'Language'
              ? 'Your 10-minute selection time has expired. You will need to make a new payment to access the queue.'
              : 'Votre temps de sélection de 10 minutes a expiré. Vous devrez effectuer un nouveau paiement pour accéder à la file.',
        ),
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop(); // Close dialog
              Navigator.of(context).pop(); // Go back to establishments screen
            },
            child: Text(
              localizations.language == 'Language' ? 'OK' : 'OK',
            ),
          ),
        ],
      ),
    );
  }

  String _formatTime(int seconds) {
    final minutes = seconds ~/ 60;
    final remainingSeconds = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    final queueStatus = _queueService.getQueueStatus(widget.establishment.id);

    return Scaffold(
      appBar: AppBar(
        title: Text(localizations.language == 'Language'
            ? 'Select Queue Number'
            : 'Sélectionnez un Numéro'),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
          tooltip: localizations.language == 'Language' ? 'Back' : 'Retour',
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.home),
            onPressed: () =>
                Navigator.of(context).popUntil((route) => route.isFirst),
            tooltip: localizations.language == 'Language' ? 'Home' : 'Accueil',
          ),
        ],
      ),
      body: Column(
        children: [
          // Timer and establishment info
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  _timeRemaining > 120 ? Colors.green : Colors.red.shade400,
                  _timeRemaining > 120
                      ? Colors.green.shade600
                      : Colors.red.shade600,
                ],
              ),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.timer,
                      color: Colors.white,
                      size: 24,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      _formatTime(_timeRemaining),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'monospace',
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  localizations.language == 'Language'
                      ? 'Time remaining to select your number'
                      : 'Temps restant pour sélectionner votre numéro',
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    children: [
                      Text(
                        widget.establishment.name,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (queueStatus != null) ...[
                        const SizedBox(height: 4),
                        Text(
                          localizations.language == 'Language'
                              ? 'Currently serving: #${queueStatus.currentlyServing}'
                              : 'Actuellement servi: #${queueStatus.currentlyServing}',
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Instructions
          Padding(
            padding: const EdgeInsets.all(16),
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Icon(
                      Icons.info_outline,
                      color: Theme.of(context).primaryColor,
                      size: 24,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      localizations.language == 'Language'
                          ? 'Select one of the available queue numbers below. You have 10 minutes to make your selection.'
                          : 'Sélectionnez l\'un des numéros de file disponibles ci-dessous. Vous avez 10 minutes pour faire votre sélection.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.grey[700],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Instructions section
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            margin: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Theme.of(context).primaryColor.withValues(alpha: 0.3),
                width: 1,
              ),
            ),
            child: Column(
              children: [
                Icon(
                  Icons.touch_app,
                  color: Theme.of(context).primaryColor,
                  size: 32,
                ),
                const SizedBox(height: 12),
                Text(
                  localizations.language == 'Language'
                      ? 'Select Your Ticket Line Number'
                      : 'Sélectionnez Votre Ticket Line',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).primaryColor,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  localizations.language == 'Language'
                      ? '5 ticket line numbers are available below. Choose one ticket line to secure your spot.'
                      : '5 tickets line sont disponibles ci-dessous. Choisissez-en un pour réserver votre place.',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[700],
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),

          // Available numbers
          Expanded(
            child: _availableNumbers.isEmpty
                ? _buildEmptyState(localizations)
                : _buildNumberGrid(),
          ),

          // Confirm button
          if (_selectedNumber != null)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              child: ElevatedButton(
                onPressed: _isLoading ? null : _confirmSelection,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).primaryColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: _isLoading
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
                                ? 'Confirming...'
                                : 'Confirmation...',
                          ),
                        ],
                      )
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.check, size: 20),
                          const SizedBox(width: 8),
                          Text(
                            localizations.language == 'Language'
                                ? 'Confirm Number $_selectedNumber'
                                : 'Confirmer le Numéro $_selectedNumber',
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
    );
  }

  Widget _buildEmptyState(AppLocalizations localizations) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.hourglass_empty,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            localizations.language == 'Language'
                ? 'No numbers available'
                : 'Aucun numéro disponible',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            localizations.language == 'Language'
                ? 'Please try again later'
                : 'Veuillez réessayer plus tard',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNumberGrid() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Header text
          Text(
            AppLocalizations.of(context)!.language == 'Language'
                ? 'Ticket Line Numbers Available (5 total)'
                : 'Tickets Line Disponibles (5 au total)',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).primaryColor,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),

          // Numbers grid - optimized for 5 numbers
          Expanded(
            child: _availableNumbers.length <= 3
                ? _buildHorizontalLayout()
                : _buildGridLayout(),
          ),
        ],
      ),
    );
  }

  Widget _buildHorizontalLayout() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: _availableNumbers
          .map(
            (number) => Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: _buildNumberCard(number, true),
              ),
            ),
          )
          .toList(),
    );
  }

  Widget _buildGridLayout() {
    return GridView.builder(
      shrinkWrap: true,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount:
            _availableNumbers.length == 5 ? 3 : 2, // 3 columns for 5 numbers
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 1.3,
      ),
      itemCount: _availableNumbers.length,
      itemBuilder: (context, index) {
        final number = _availableNumbers[index];
        return _buildNumberCard(number, false);
      },
    );
  }

  Widget _buildNumberCard(int number, bool isHorizontal) {
    final isSelected = _selectedNumber == number;

    return AspectRatio(
      aspectRatio: isHorizontal ? 1.2 : 1.3,
      child: Card(
        elevation: isSelected ? 8 : 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(
            color: isSelected
                ? Theme.of(context).primaryColor
                : Colors.transparent,
            width: 3,
          ),
        ),
        child: InkWell(
          onTap: () {
            setState(() {
              _selectedNumber = number;
            });
          },
          borderRadius: BorderRadius.circular(12),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              gradient: isSelected
                  ? LinearGradient(
                      colors: [
                        Theme.of(context).primaryColor.withValues(alpha: 0.1),
                        Theme.of(context).primaryColor.withValues(alpha: 0.2),
                      ],
                    )
                  : null,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  AppLocalizations.of(context)!.language == 'Language'
                      ? 'Ticket Line'
                      : 'Ticket Line',
                  style: TextStyle(
                    fontSize: isHorizontal ? 12 : 14,
                    fontWeight: FontWeight.w600,
                    color: isSelected
                        ? Theme.of(context).primaryColor
                        : Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  '#$number',
                  style: TextStyle(
                    fontSize: isHorizontal ? 24 : 32,
                    fontWeight: FontWeight.bold,
                    color: isSelected
                        ? Theme.of(context).primaryColor
                        : Colors.grey[700],
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? Theme.of(context).primaryColor
                        : Colors.grey[300],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    AppLocalizations.of(context)!.language == 'Language'
                        ? 'Available'
                        : 'Disponible',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: isSelected ? Colors.white : Colors.grey[600],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _confirmSelection() async {
    if (_selectedNumber == null) return;

    setState(() {
      _isLoading = true;
    });

    // Capture context values before async operation
    final localizations = AppLocalizations.of(context)!;
    final scaffoldMessenger = ScaffoldMessenger.of(context);

    try {
      final ticket = await _queueService.purchaseQueueNumber(
        establishmentId: widget.establishment.id,
        establishmentName: widget.establishment.name,
        establishmentAddress: widget.establishment.address,
        queueNumber: _selectedNumber!,
        paymentId: widget.payment.id,
      );

      _timer?.cancel(); // Stop the timer

      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => TicketConfirmationScreen(
              ticket: ticket,
              payment: widget.payment,
              establishment: widget.establishment,
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        scaffoldMessenger.showSnackBar(
          SnackBar(
            content: Text(
              localizations.language == 'Language'
                  ? 'Error purchasing queue number. Please try again.'
                  : 'Erreur lors de l\'achat du numéro de file. Veuillez réessayer.',
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
}
