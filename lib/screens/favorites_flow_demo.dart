import 'package:flutter/material.dart';
import '../utils/app_localizations.dart';
import '../widgets/my_favorite_establishments_widget.dart';
import '../services/favorites_service.dart';
import '../models/location_models.dart';

/// Test screen to demonstrate the favorite establishments flow
/// Shows how marking establishments as favorites immediately updates the widget
class FavoritesFlowDemo extends StatefulWidget {
  const FavoritesFlowDemo({super.key});

  @override
  State<FavoritesFlowDemo> createState() => _FavoritesFlowDemoState();
}

class _FavoritesFlowDemoState extends State<FavoritesFlowDemo> {
  final FavoritesService _favoritesService = FavoritesService();
  late List<Establishment> _availableEstablishments;

  @override
  void initState() {
    super.initState();
    _initializeTestEstablishments();
  }

  void _initializeTestEstablishments() {
    _availableEstablishments = [
      Establishment(
        id: 'test_1',
        name: 'QuikTik Downtown Store',
        address: '123 Main Street, Downtown',
        cityId: 'city_1',
        hours: EstablishmentHours(
          openTime: '09:00',
          closeTime: '18:00',
          workingDays: [1, 2, 3, 4, 5], // Monday to Friday
        ),
        status: EstablishmentStatus.open,
        latitude: 52.1579,
        longitude: -106.6702,
        phoneNumber: '(306) 555-0001',
        website: 'https://quiktik.com/downtown',
      ),
      Establishment(
        id: 'test_2',
        name: 'QuikTik Mall Location',
        address: '456 Shopping Plaza, Mall District',
        cityId: 'city_1',
        hours: EstablishmentHours(
          openTime: '10:00',
          closeTime: '21:00',
          workingDays: [1, 2, 3, 4, 5, 6, 7], // All week
        ),
        status: EstablishmentStatus.open,
        latitude: 52.1304,
        longitude: -106.6900,
        phoneNumber: '(306) 555-0002',
        website: 'https://quiktik.com/mall',
      ),
      Establishment(
        id: 'test_3',
        name: 'QuikTik Express',
        address: '789 Quick Ave, Express District',
        cityId: 'city_1',
        hours: EstablishmentHours(
          openTime: '08:00',
          closeTime: '20:00',
          workingDays: [1, 2, 3, 4, 5, 6], // Monday to Saturday
        ),
        status: EstablishmentStatus.temporarilyClosed,
        latitude: 52.1200,
        longitude: -106.7000,
        phoneNumber: '(306) 555-0003',
        website: 'https://quiktik.com/express',
      ),
      Establishment(
        id: 'test_4',
        name: 'QuikTik North Branch',
        address: '321 North Road, North District',
        cityId: 'city_1',
        hours: EstablishmentHours(
          openTime: '09:30',
          closeTime: '17:30',
          workingDays: [1, 2, 3, 4, 5], // Monday to Friday
        ),
        status: EstablishmentStatus.closed,
        latitude: 52.1800,
        longitude: -106.6500,
        phoneNumber: '(306) 555-0004',
        website: 'https://quiktik.com/north',
      ),
    ];
  }

  void _toggleFavorite(Establishment establishment) {
    setState(() {
      _favoritesService.toggleFavorite(establishment);
    });

    final localizations = AppLocalizations.of(context)!;
    final isFavorite = _favoritesService.isFavorite(establishment.id);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              isFavorite ? Icons.favorite : Icons.favorite_border,
              color: Colors.white,
              size: 20,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                isFavorite
                    ? '${localizations.language == 'Language' ? 'Added' : 'Ajouté'} ${establishment.name} ${localizations.language == 'Language' ? 'to favorites' : 'aux favoris'}'
                    : '${localizations.language == 'Language' ? 'Removed' : 'Retiré'} ${establishment.name} ${localizations.language == 'Language' ? 'from favorites' : 'des favoris'}',
              ),
            ),
          ],
        ),
        backgroundColor: isFavorite ? Colors.green : Colors.orange,
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _clearAllFavorites() {
    _favoritesService.clearAllFavorites();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          AppLocalizations.of(context)!.language == 'Language'
              ? 'All favorites cleared'
              : 'Tous les favoris supprimés',
        ),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          localizations.language == 'Language'
              ? 'Favorites Flow Demo'
              : 'Démonstration des Favoris',
        ),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.clear_all),
            onPressed: _clearAllFavorites,
            tooltip: localizations.language == 'Language'
                ? 'Clear All Favorites'
                : 'Effacer Tous les Favoris',
          ),
        ],
      ),
      body: Column(
        children: [
          // Instructions
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            color: Colors.blue.withValues(alpha: 0.1),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  localizations.language == 'Language'
                      ? '💡 How it works:'
                      : '💡 Comment ça fonctionne:',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  localizations.language == 'Language'
                      ? '1. Tap the heart icons below to add/remove favorites\n2. Watch the "My Favorites" widget update instantly\n3. The widget shows real-time changes!'
                      : '1. Appuyez sur les icônes cœur ci-dessous pour ajouter/supprimer des favoris\n2. Regardez le widget "Mes Favoris" se mettre à jour instantanément\n3. Le widget affiche les changements en temps réel!',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[700],
                  ),
                ),
              ],
            ),
          ),

          // My Favorites Widget - This will update automatically
          Expanded(
            flex: 2,
            child: Container(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.favorite,
                        color: Theme.of(context).primaryColor,
                        size: 24,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        localizations.myFavoriteEstablishments,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).primaryColor,
                        ),
                      ),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Theme.of(context).primaryColor,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          '${_favoritesService.favorites.length}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  const Expanded(
                    child: MyFavoriteEstablishmentsWidget(),
                  ),
                ],
              ),
            ),
          ),

          const Divider(thickness: 2),

          // Available Establishments to mark as favorites
          Expanded(
            flex: 3,
            child: Container(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    localizations.language == 'Language'
                        ? 'Available Establishments'
                        : 'Établissements Disponibles',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    child: ListView.builder(
                      itemCount: _availableEstablishments.length,
                      itemBuilder: (context, index) {
                        final establishment = _availableEstablishments[index];
                        final isFavorite =
                            _favoritesService.isFavorite(establishment.id);

                        return Card(
                          margin: const EdgeInsets.only(bottom: 8),
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundColor: establishment.status.color
                                  .withValues(alpha: 0.1),
                              child: Icon(
                                establishment.isOpen
                                    ? Icons.store
                                    : Icons.store_mall_directory,
                                color: establishment.status.color,
                                size: 20,
                              ),
                            ),
                            title: Text(
                              establishment.name,
                              style:
                                  const TextStyle(fontWeight: FontWeight.bold),
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(establishment.address),
                                const SizedBox(height: 4),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: establishment.status.color
                                        .withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    establishment.status.getDisplayText(
                                        localizations.language == 'Language'
                                            ? 'en'
                                            : 'fr'),
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                      color: establishment.status.color,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            trailing: IconButton(
                              icon: Icon(
                                isFavorite
                                    ? Icons.favorite
                                    : Icons.favorite_border,
                                color:
                                    isFavorite ? Colors.red : Colors.grey[600],
                                size: 28,
                              ),
                              onPressed: () => _toggleFavorite(establishment),
                              tooltip: isFavorite
                                  ? localizations.removeFromFavorites
                                  : localizations.addToFavorites,
                            ),
                          ),
                        );
                      },
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
}
