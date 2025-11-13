import 'dart:async';
import 'package:flutter/material.dart';

void main() {
  runApp(const QuikTikDemoApp());
}

class QuikTikDemoApp extends StatelessWidget {
  const QuikTikDemoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'QuikTik Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      home: const QuikTikDemoScreen(),
    );
  }
}

class QuikTikDemoScreen extends StatefulWidget {
  const QuikTikDemoScreen({super.key});

  @override
  State<QuikTikDemoScreen> createState() => _QuikTikDemoScreenState();
}

class _QuikTikDemoScreenState extends State<QuikTikDemoScreen> {
  int _currentStep = 0;
  int _countdown = 600; // 10 minutes in seconds
  bool _isRunning = false;

  final List<String> _steps = [
    'Select Province',
    'Select City',
    'Select Establishment',
    'Payment Processing',
    'Queue Number Selection',
    'Ticket Confirmation',
  ];

  void _startDemo() {
    setState(() {
      _isRunning = true;
      _currentStep = 0;
    });

    // Simulate the flow
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() {
          _currentStep = 1;
        });
      }
    });

    Future.delayed(const Duration(seconds: 4), () {
      if (mounted) {
        setState(() {
          _currentStep = 2;
        });
      }
    });

    Future.delayed(const Duration(seconds: 6), () {
      if (mounted) {
        setState(() {
          _currentStep = 3;
        });
      }
    });

    Future.delayed(const Duration(seconds: 8), () {
      if (mounted) {
        setState(() {
          _currentStep = 4;
        });
        _startCountdown();
      }
    });
  }

  void _startCountdown() {
    Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_countdown > 0 && mounted) {
        setState(() {
          _countdown--;
        });
      } else {
        timer.cancel();
        if (mounted) {
          setState(() {
            _currentStep = 5;
          });
        }
      }
    });
  }

  String _formatTime(int seconds) {
    int minutes = seconds ~/ 60;
    int remainingSeconds = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('QuikTik - Queue Management System'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Header
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.blue, Colors.blue.shade700],
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Column(
                children: [
                  Text(
                    'QuikTik',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Smart Queue Management System',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 30),

            // Demo Button
            if (!_isRunning)
              ElevatedButton(
                onPressed: _startDemo,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
                ),
                child: const Text(
                  'Start Demo Flow',
                  style: TextStyle(fontSize: 18),
                ),
              ),

            if (_isRunning) ...[
              // Progress Steps
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey[300]!),
                ),
                child: Column(
                  children: [
                    Text(
                      'Current Step: ${_steps[_currentStep]}',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Progress indicator
                    LinearProgressIndicator(
                      value: (_currentStep + 1) / _steps.length,
                      backgroundColor: Colors.grey[300],
                      valueColor:
                          const AlwaysStoppedAnimation<Color>(Colors.blue),
                    ),

                    const SizedBox(height: 20),

                    // Step details
                    if (_currentStep == 4) ...[
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.orange[50],
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.orange[200]!),
                        ),
                        child: Column(
                          children: [
                            const Icon(
                              Icons.timer,
                              color: Colors.orange,
                              size: 48,
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              '10-Minute Timer Active',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              _formatTime(_countdown),
                              style: const TextStyle(
                                fontSize: 36,
                                fontWeight: FontWeight.bold,
                                color: Colors.orange,
                              ),
                            ),
                            const SizedBox(height: 16),
                            // Queue Numbers Grid
                            const Text('Available Queue Numbers:'),
                            const SizedBox(height: 8),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                for (int i = 1; i <= 5; i++)
                                  Container(
                                    width: 50,
                                    height: 50,
                                    decoration: BoxDecoration(
                                      color: Colors.blue,
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Center(
                                      child: Text(
                                        '#$i',
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],

                    if (_currentStep == 5) ...[
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.green[50],
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.green[200]!),
                        ),
                        child: const Column(
                          children: [
                            Icon(
                              Icons.check_circle,
                              color: Colors.green,
                              size: 48,
                            ),
                            SizedBox(height: 8),
                            Text(
                              'Purchase Confirmed!',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.green,
                              ),
                            ),
                            SizedBox(height: 8),
                            Text(
                              'Queue Number: #3',
                              style: TextStyle(
                                fontSize: 16,
                              ),
                            ),
                            Text(
                              'Currently Serving: #1',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Feature List
              const Text(
                'Implemented Features:',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),

              Expanded(
                child: ListView(
                  children: const [
                    FeatureTile(
                      icon: Icons.location_on,
                      title: 'Location Selection',
                      description: 'Province → City → Establishment flow',
                    ),
                    FeatureTile(
                      icon: Icons.payment,
                      title: 'Payment Processing',
                      description:
                          'Credit/Debit cards, PayPal, Apple Pay, Google Pay',
                    ),
                    FeatureTile(
                      icon: Icons.timer,
                      title: '10-Minute Timer',
                      description:
                          'Queue number selection with automatic timeout',
                    ),
                    FeatureTile(
                      icon: Icons.confirmation_number,
                      title: 'Active Tickets',
                      description:
                          'Real-time queue status and position tracking',
                    ),
                    FeatureTile(
                      icon: Icons.receipt_long,
                      title: 'Invoice System',
                      description:
                          'Professional invoices with print/email options',
                    ),
                    FeatureTile(
                      icon: Icons.language,
                      title: 'Multilingual',
                      description: 'English and French language support',
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class FeatureTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;

  const FeatureTile({
    super.key,
    required this.icon,
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Icon(icon, color: Colors.blue),
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(description),
      ),
    );
  }
}
