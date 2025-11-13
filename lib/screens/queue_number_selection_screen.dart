import 'dart:async';
import 'dart:math' as math;
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
    debugPrint('🚀 Initializing Queue Number Selection Screen');
    _loadAvailableNumbers();
    _startTimer();

    // Ensure we always have numbers - double check after a delay
    Future.delayed(const Duration(milliseconds: 500), () {
      if (_availableNumbers.isEmpty) {
        debugPrint('⚠️ No numbers after delay, force generating...');
        _generateFallbackNumbers();
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _loadAvailableNumbers() {
    debugPrint(
        '🔍 Loading available numbers for establishment: ${widget.establishment.id}');

    // First, ensure the queue is initialized for this establishment
    _queueService.initializeQueues([widget.establishment]);
    
    final queueStatus = _queueService.getQueueStatus(widget.establishment.id);
    debugPrint('📊 Queue status: $queueStatus');

    if (queueStatus != null) {
      debugPrint(
          '✅ Found queue status with ${queueStatus.availableNumbers.length} numbers');
      debugPrint('📋 Raw available numbers: ${queueStatus.availableNumbers}');
      debugPrint('🎯 Currently serving: ${queueStatus.currentlyServing}');
      debugPrint('👥 Total waiting: ${queueStatus.totalWaiting}');
      
      setState(() {
        // Ensure exactly 5 numbers are available
        _availableNumbers = queueStatus.availableNumbers.take(5).toList();
        debugPrint('🎯 Available numbers after processing: $_availableNumbers');
        // If somehow less than 5, generate additional numbers
        if (_availableNumbers.length < 5) {
          debugPrint('⚠️ Less than 5 numbers, generating additional...');
          _generateAdditionalNumbers();
        }
      });
    } else {
      debugPrint('❌ No queue status found, generating fallback numbers');
      // Fallback: generate 5 random available numbers
      _generateFallbackNumbers();
    }

    debugPrint('🎲 Final available numbers: $_availableNumbers (count: ${_availableNumbers.length})');
  }

  void _generateAdditionalNumbers() {
    final math.Random random = math.Random();
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
    debugPrint('🎯 Generating fallback numbers...');
    final math.Random random = math.Random();
    final Set<int> numbers = {};
    final int baseNumber = random.nextInt(50) + 20; // Start from 20-70

    while (numbers.length < 5) {
      int offset = numbers.length + random.nextInt(3);
      numbers.add(baseNumber + offset);
    }

    setState(() {
      _availableNumbers = numbers.toList()..sort();
      debugPrint('✅ Generated fallback numbers: $_availableNumbers');
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
      body: SingleChildScrollView(
        child: Column(
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
                        const SizedBox(height: 8),
                        // Current serving number
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.record_voice_over,
                              color: Colors.white70,
                              size: 16,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              localizations.language == 'Language'
                                  ? 'Now Serving: #${queueStatus.currentlyServing}'
                                  : 'Actuellement: #${queueStatus.currentlyServing}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        // Total waiting
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.people_outline,
                              color: Colors.white70,
                              size: 16,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              localizations.language == 'Language'
                                  ? '${queueStatus.totalWaiting} people waiting'
                                  : '${queueStatus.totalWaiting} personnes en attente',
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        // Available numbers count
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.confirmation_number,
                              color: Colors.white70,
                              size: 16,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              localizations.language == 'Language'
                                  ? '${_availableNumbers.length} tickets available'
                                  : '${_availableNumbers.length} tickets disponibles',
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 12,
                              ),
                            ),
                          ],
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

          // Payment Success & Queue Information
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            margin: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.green[50]!,
                  Colors.green[100]!,
                ],
              ),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Colors.green[300]!,
                width: 2,
              ),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.green[600],
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Icon(
                        Icons.check,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      localizations.language == 'Language'
                          ? 'Payment Successful!'
                          : 'Paiement Réussi!',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.green[700],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.green[200]!),
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            localizations.language == 'Language'
                                ? 'Queue Access Fee:'
                                : 'Frais d\'accès:',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[700],
                            ),
                          ),
                          Text(
                            '\$${widget.payment.amount.toStringAsFixed(2)}',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Colors.green[700],
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
                                ? 'Payment Method:'
                                : 'Méthode de paiement:',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[700],
                            ),
                          ),
                          Text(
                            widget.payment.method.name.toUpperCase(),
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: Colors.grey[700],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 16),

          // Queue Selection Instructions
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            margin: const EdgeInsets.symmetric(horizontal: 16),
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
                      ? 'Choose Your Queue Number'
                      : 'Choisissez Votre Numéro',
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
                      ? 'Select from ${_availableNumbers.length} available queue numbers below. Each shows estimated wait time.'
                      : 'Sélectionnez parmi ${_availableNumbers.length} numéros disponibles ci-dessous. Chacun montre le temps d\'attente estimé.',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[700],
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),

          // Queue Status Summary
          _buildQueueStatusSummary(localizations),

          // Available numbers
          _availableNumbers.isEmpty
              ? _buildEmptyState(localizations)
              : _buildNumberGrid(),

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
      ),
    );
  }

  Widget _buildQueueStatusSummary(AppLocalizations localizations) {
    final queueStatus = _queueService.getQueueStatus(widget.establishment.id);
    final currentlyServing = queueStatus?.currentlyServing ?? 0;
    final totalWaiting = queueStatus?.totalWaiting ?? 0;
    
    return Column(
      children: [
        // Currently Serving - Large prominent display
        Container(
          width: double.infinity,
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.green[400]!, Colors.green[600]!],
            ),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.green.withValues(alpha: 0.3),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            children: [
              const Icon(
                Icons.record_voice_over,
                color: Colors.white,
                size: 32,
              ),
              const SizedBox(height: 8),
              Text(
                localizations.language == 'Language'
                    ? 'NOW SERVING'
                    : 'ACTUELLEMENT SERVI',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '#$currentlyServing',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 48,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                localizations.language == 'Language'
                    ? '$totalWaiting people waiting'
                    : '$totalWaiting personnes en attente',
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
        
        // Queue Statistics
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.blue[50]!, Colors.blue[100]!],
            ),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.blue[300]!),
          ),
          child: Column(
            children: [
              Text(
                localizations.language == 'Language'
                    ? 'Queue Information'
                    : 'Informations sur la File',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue[800],
                ),
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildStatusItem(
                    Icons.confirmation_number,
                    localizations.language == 'Language' 
                        ? 'Available' 
                        : 'Disponible',
                    '${_availableNumbers.length}',
                    Colors.blue,
                  ),
                  _buildStatusItem(
                    Icons.people_outline,
                    localizations.language == 'Language' 
                        ? 'In Queue' 
                        : 'Dans la File',
                    '$totalWaiting',
                    Colors.orange,
                  ),
                  _buildStatusItem(
                    Icons.schedule,
                    localizations.language == 'Language' 
                        ? 'Est. Wait' 
                        : 'Attente Est.',
                    '${(totalWaiting * 3).clamp(0, 60)}m',
                    Colors.purple,
                  ),
                ],
              ),
              if (_availableNumbers.isNotEmpty) ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.blue[200]!),
                  ),
                  child: Column(
                    children: [
                      Text(
                        localizations.language == 'Language'
                            ? 'Available Queue Numbers'
                            : 'Numéros de File Disponibles',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue[800],
                        ),
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        children: _availableNumbers.map((number) => Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12, 
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.blue[50],
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: Colors.blue[300]!),
                          ),
                          child: Text(
                            '#$number',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Colors.blue[700],
                            ),
                          ),
                        )).toList(),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStatusItem(IconData icon, String label, String value, Color color) {
    return Column(
      children: [
        Icon(icon, color: color, size: 24),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
      ],
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
          const SizedBox(height: 20),
          ElevatedButton.icon(
            onPressed: () {
              debugPrint('🔄 Manual refresh requested');
              _generateFallbackNumbers();
            },
            icon: const Icon(Icons.refresh),
            label: Text(
              localizations.language == 'Language'
                  ? 'Refresh Numbers'
                  : 'Actualiser les Numéros',
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).primaryColor,
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNumberGrid() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header text
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.purple[400]!, Colors.purple[600]!],
              ),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.touch_app,
                  color: Colors.white,
                  size: 24,
                ),
                const SizedBox(width: 8),
                Text(
                  AppLocalizations.of(context)!.language == 'Language'
                      ? 'SELECT YOUR QUEUE NUMBER'
                      : 'SÉLECTIONNEZ VOTRE NUMÉRO',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    letterSpacing: 0.8,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          
          Text(
            AppLocalizations.of(context)!.language == 'Language'
                ? 'Choose from ${_availableNumbers.length} available numbers below'
                : 'Choisissez parmi ${_availableNumbers.length} numéros disponibles ci-dessous',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[700],
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),

          // Numbers grid - always use grid layout for consistency
          _buildGridLayout(),
        ],
      ),
    );
  }

  Widget _buildGridLayout() {
    // Determine optimal layout based on number count
    int crossAxisCount = 2;
    double childAspectRatio = 1.2;
    
    if (_availableNumbers.length <= 3) {
      crossAxisCount = _availableNumbers.length;
      childAspectRatio = 1.0;
    } else if (_availableNumbers.length == 4) {
      crossAxisCount = 2;
      childAspectRatio = 1.1;
    } else {
      crossAxisCount = 3;
      childAspectRatio = 1.0;
    }
    
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: childAspectRatio,
      ),
      itemCount: _availableNumbers.length,
      itemBuilder: (context, index) {
        final number = _availableNumbers[index];
        return _buildNumberCard(number);
      },
    );
  }

  Widget _buildNumberCard(int number) {
    final isSelected = _selectedNumber == number;
    final queueStatus = _queueService.getQueueStatus(widget.establishment.id);
    final currentlyServing = queueStatus?.currentlyServing ?? 0;
    final peopleAhead = math.max(0, number - currentlyServing - 1);
    final estimatedWaitMinutes = peopleAhead * 5; // Estimate 5 minutes per person

    return Card(
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
                // Queue Number
                Text(
                  '#$number',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: isSelected
                        ? Theme.of(context).primaryColor
                        : Colors.grey[700],
                  ),
                ),
                const SizedBox(height: 4),
                
                // Status Badge
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? Theme.of(context).primaryColor
                        : Colors.green[100],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    AppLocalizations.of(context)!.language == 'Language'
                        ? 'Available'
                        : 'Disponible',
                    style: TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.bold,
                      color: isSelected ? Colors.white : Colors.green[700],
                    ),
                  ),
                ),
                
                const SizedBox(height: 6),
                
                // Wait Time Info
                if (peopleAhead > 0) ...[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.people,
                        size: 12,
                        color: Colors.grey[600],
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '$peopleAhead',
                        style: TextStyle(
                          fontSize: 10,
                          color: Colors.grey[600],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.access_time,
                        size: 12,
                        color: Colors.grey[600],
                      ),
                      const SizedBox(width: 4),
                      Text(
                        estimatedWaitMinutes > 60 
                            ? '${(estimatedWaitMinutes / 60).ceil()}h'
                            : '${estimatedWaitMinutes}min',
                        style: TextStyle(
                          fontSize: 10,
                          color: Colors.grey[600],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ] else ...[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.flash_on,
                        size: 12,
                        color: Colors.orange[700],
                      ),
                      const SizedBox(width: 4),
                      Text(
                        AppLocalizations.of(context)!.language == 'Language'
                            ? 'Next Up!'
                            : 'Suivant!',
                        style: TextStyle(
                          fontSize: 10,
                          color: Colors.orange[700],
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ],
              ],
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
