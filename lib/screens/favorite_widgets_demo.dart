import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/di/app_providers.dart';
import '../widgets/my_favorite_establishments_widget.dart';
import '../widgets/enhanced_favorite_establishments_widget.dart';
import '../services/favorites_service.dart';
import '../models/location_models.dart';

/// Demo screen to showcase both favorite establishments widgets
class FavoriteWidgetsDemo extends ConsumerStatefulWidget {
  const FavoriteWidgetsDemo({super.key});

  @override
  ConsumerState<FavoriteWidgetsDemo> createState() =>
      _FavoriteWidgetsDemoState();
}

class _FavoriteWidgetsDemoState extends ConsumerState<FavoriteWidgetsDemo> {
  late FavoritesService _favoritesService;
  int _selectedTab = 0;

  @override
  void initState() {
    super.initState();
    _favoritesService = ref.read(favoritesServiceProvider);
    _favoritesService.addListener(_onFavoritesChanged);
    _addSampleFavorites();
  }

  @override
  void dispose() {
    _favoritesService.removeListener(_onFavoritesChanged);
    super.dispose();
  }

  void _onFavoritesChanged() {
    if (mounted) {
      setState(() {});
    }
  }

  void _addSampleFavorites() {
    // Add some sample establishments to showcase the widgets
    final sampleEstablishments = [
      Establishment(
        id: 'sample_1',
        name: 'QuikTik Downtown',
        address: '123 Main St, Downtown',
        cityId: 'city_1',
        hours: EstablishmentHours(
          openTime: '09:00',
          closeTime: '17:00',
          workingDays: [1, 2, 3, 4, 5], // Monday to Friday
        ),
        status: EstablishmentStatus.open,
        latitude: 52.1579,
        longitude: -106.6702,
        phoneNumber: '(306) 555-0123',
      ),
      Establishment(
        id: 'sample_2',
        name: 'QuikTik Mall',
        address: '456 Shopping Center Blvd',
        cityId: 'city_1',
        hours: EstablishmentHours(
          openTime: '10:00',
          closeTime: '21:00',
          workingDays: [1, 2, 3, 4, 5, 6, 7], // All week
        ),
        status: EstablishmentStatus.temporarilyClosed,
        latitude: 52.1304,
        longitude: -106.6900,
        phoneNumber: '(306) 555-0456',
      ),
      Establishment(
        id: 'sample_3',
        name: 'QuikTik Express',
        address: '789 Quick Service Ave',
        cityId: 'city_1',
        hours: EstablishmentHours(
          openTime: '08:00',
          closeTime: '20:00',
          workingDays: [1, 2, 3, 4, 5, 6], // Monday to Saturday
        ),
        status: EstablishmentStatus.closed,
        latitude: 52.1200,
        longitude: -106.7000,
        phoneNumber: '(306) 555-0789',
      ),
    ];

    for (final establishment in sampleEstablishments) {
      if (!_favoritesService.isFavorite(establishment.id)) {
        _favoritesService.addToFavorites(establishment);
      }
    }
  }

  void _clearAllFavorites() {
    _favoritesService.clearAllFavorites();
  }

  void _restoreSampleFavorites() {
    _clearAllFavorites();
    _addSampleFavorites();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Favorite Establishments Widgets Demo'),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) {
              switch (value) {
                case 'clear':
                  _clearAllFavorites();
                  break;
                case 'restore':
                  _restoreSampleFavorites();
                  break;
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'clear',
                child: Text('Clear All Favorites'),
              ),
              const PopupMenuItem(
                value: 'restore',
                child: Text('Restore Sample Favorites'),
              ),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          // Tab selector
          Container(
            margin: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(25),
            ),
            child: Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => _selectedTab = 0),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        color: _selectedTab == 0
                            ? Theme.of(context).primaryColor
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(25),
                      ),
                      child: Text(
                        'Original Widget',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color:
                              _selectedTab == 0 ? Colors.white : Colors.black87,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => _selectedTab = 1),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        color: _selectedTab == 1
                            ? Theme.of(context).primaryColor
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(25),
                      ),
                      child: Text(
                        'Enhanced Widget',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color:
                              _selectedTab == 1 ? Colors.white : Colors.black87,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Widget display area
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: _selectedTab == 0
                  ? Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Original My Favorite Establishments Widget',
                          style:
                              Theme.of(context).textTheme.titleLarge?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'This is the existing widget with its current styling and functionality.',
                          style:
                              Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: Colors.grey[600],
                                  ),
                        ),
                        const SizedBox(height: 16),
                        const Expanded(
                          child: MyFavoriteEstablishmentsWidget(),
                        ),
                      ],
                    )
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Enhanced Favorite Establishments Widget',
                          style:
                              Theme.of(context).textTheme.titleLarge?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Enhanced version with animations, better styling, and improved user experience.',
                          style:
                              Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: Colors.grey[600],
                                  ),
                        ),
                        const SizedBox(height: 16),
                        const Expanded(
                          child: EnhancedFavoriteEstablishmentsWidget(
                              isCompact: false),
                        ),
                      ],
                    ),
            ),
          ),

          // Compact mode demo for enhanced widget
          if (_selectedTab == 1) ...[
            const Divider(),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Compact Mode Example',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 8),
                  const SizedBox(
                    height: 200,
                    child: EnhancedFavoriteEstablishmentsWidget(
                      isCompact: true,
                      maxCompactItems: 2,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}
