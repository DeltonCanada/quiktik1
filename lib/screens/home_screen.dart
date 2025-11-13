// QuikTik Home Screen - Main entry point for the app
import 'package:flutter/material.dart';
import '../utils/app_localizations.dart';
import '../widgets/language_selector.dart';
import '../widgets/buy_ticket_widget.dart';
import '../widgets/my_favorite_establishments_widget.dart';
import '../widgets/favorites_counter_widget.dart';
import 'about_screen.dart';
import 'testimonials_screen.dart';
import 'founder_screen.dart';
import 'register_screen.dart';
import 'login_screen.dart';
import 'active_tickets_screen.dart';
import 'favorite_widgets_demo.dart';
import 'favorites_flow_demo.dart';

class HomeScreen extends StatelessWidget {
  final Function(Locale) onLocaleChange;

  const HomeScreen({super.key, required this.onLocaleChange});

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: const Text('QuikTik'),
        actions: [
          const Padding(
            padding: EdgeInsets.only(right: 12.0),
            child: FavoritesCounterWidget(),
          ),
          Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: LanguageSelector(onLocaleChange: onLocaleChange),
          ),
        ],
      ),
      drawer: _buildDrawer(context, localizations),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Welcome section
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24.0),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Theme.of(context).primaryColor,
                    Theme.of(context).primaryColor.withValues(alpha: 0.7),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    localizations.welcome,
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    localizations.homeDescription,
                    style: const TextStyle(fontSize: 16, color: Colors.white70),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),

            // Buy Ticket Widget - Prominent placement
            const BuyTicketWidget(),

            const SizedBox(height: 24),

            // My Favorite Establishments Widget
            const MyFavoriteEstablishmentsWidget(),

            const SizedBox(height: 32),

            // Quick navigation cards
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              children: [
                _buildNavigationCard(
                  context,
                  localizations.activeTickets,
                  Icons.confirmation_number,
                  () => _navigateToScreen(context, const ActiveTicketsScreen()),
                ),
                _buildNavigationCard(
                  context,
                  localizations.about,
                  Icons.info_outline,
                  () => _navigateToScreen(context, const AboutScreen()),
                ),
                _buildNavigationCard(
                  context,
                  localizations.testimonials,
                  Icons.star_outline,
                  () => _navigateToScreen(context, const TestimonialsScreen()),
                ),
                _buildNavigationCard(
                  context,
                  localizations.founderInfo,
                  Icons.person_outline,
                  () => _navigateToScreen(context, const FounderScreen()),
                ),
                _buildNavigationCard(
                  context,
                  localizations.signUp,
                  Icons.person_add_outlined,
                  () => _navigateToScreen(context, const RegisterScreen()),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDrawer(BuildContext context, AppLocalizations localizations) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: BoxDecoration(color: Theme.of(context).primaryColor),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text(
                  'QuikTik',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'Skip the Line, Save Your Time',
                  style: TextStyle(color: Colors.white70, fontSize: 14),
                ),
              ],
            ),
          ),
          ListTile(
            leading: const Icon(Icons.confirmation_number),
            title: Text(localizations.activeTickets),
            onTap: () {
              Navigator.pop(context);
              _navigateToScreen(context, const ActiveTicketsScreen());
            },
          ),
          ListTile(
            leading: const Icon(Icons.info_outline),
            title: Text(localizations.about),
            onTap: () {
              Navigator.pop(context);
              _navigateToScreen(context, const AboutScreen());
            },
          ),
          ListTile(
            leading: const Icon(Icons.star_outline),
            title: Text(localizations.testimonials),
            onTap: () {
              Navigator.pop(context);
              _navigateToScreen(context, const TestimonialsScreen());
            },
          ),
          ListTile(
            leading: const Icon(Icons.person_outline),
            title: Text(localizations.founderInfo),
            onTap: () {
              Navigator.pop(context);
              _navigateToScreen(context, const FounderScreen());
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.widgets),
            title: const Text('Favorites Widget Demo'),
            onTap: () {
              Navigator.pop(context);
              _navigateToScreen(context, const FavoriteWidgetsDemo());
            },
          ),
          ListTile(
            leading: const Icon(Icons.person_add_outlined),
            title: Text(localizations.signUp),
            onTap: () {
              Navigator.pop(context);
              _navigateToScreen(context, const RegisterScreen());
            },
          ),
          ListTile(
            leading: const Icon(Icons.favorite_border),
            title: const Text('Favorites Flow Demo'),
            onTap: () {
              Navigator.pop(context);
              _navigateToScreen(context, const FavoritesFlowDemo());
            },
          ),
          ListTile(
            leading: const Icon(Icons.widgets),
            title: Text(localizations.logIn),
            onTap: () {
              Navigator.pop(context);
              _navigateToScreen(context, const LoginScreen());
            },
          ),
        ],
      ),
    );
  }

  Widget _buildNavigationCard(
    BuildContext context,
    String title,
    IconData icon,
    VoidCallback onTap,
  ) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 48, color: Theme.of(context).primaryColor),
              const SizedBox(height: 12),
              Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _navigateToScreen(BuildContext context, Widget screen) {
    Navigator.push(context, MaterialPageRoute(builder: (context) => screen));
  }
}
