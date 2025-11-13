import 'package:flutter/material.dart';
import '../utils/app_localizations.dart';
import '../widgets/active_tickets_widget.dart';

class ActiveTicketsScreen extends StatefulWidget {
  const ActiveTicketsScreen({super.key});

  @override
  State<ActiveTicketsScreen> createState() => _ActiveTicketsScreenState();
}

class _ActiveTicketsScreenState extends State<ActiveTicketsScreen> {
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(localizations.activeTickets),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
      ),
      body: ActiveTicketsWidget(
        scrollController: _scrollController,
      ),
    );
  }
}
