import 'package:flutter/foundation.dart';

import '../models/location_models.dart';

class FavoritesService extends ChangeNotifier {
  static FavoritesService? _instance;
  final List<Establishment> _favorites = [];

  factory FavoritesService() {
    _instance ??= FavoritesService._internal();
    return _instance!;
  }

  FavoritesService._internal();

  List<Establishment> get favorites => List.unmodifiable(_favorites);

  bool isFavorite(String establishmentId) {
    return _favorites.any((establishment) => establishment.id == establishmentId);
  }

  void addToFavorites(Establishment establishment) {
    if (!isFavorite(establishment.id)) {
      _favorites.add(establishment);
      debugPrint('✅ Added ${establishment.name} to favorites. Total: ${_favorites.length}');
      notifyListeners();
    } else {
      debugPrint('⚠️ ${establishment.name} is already in favorites');
    }
  }

  void removeFromFavorites(String establishmentId) {
    final initialLength = _favorites.length;
    final establishment = _favorites.firstWhere(
      (est) => est.id == establishmentId,
      orElse: () => Establishment(
        id: establishmentId,
        name: 'Unknown',
        address: '',
        cityId: '',
        hours: EstablishmentHours(openTime: '', closeTime: '', workingDays: []),
        status: EstablishmentStatus.closed,
        latitude: 0,
        longitude: 0,
      ),
    );
    
    _favorites.removeWhere((establishment) => establishment.id == establishmentId);

    if (_favorites.length != initialLength) {
      debugPrint('🗑️ Removed ${establishment.name} from favorites. Total: ${_favorites.length}');
      notifyListeners();
    } else {
      debugPrint('⚠️ Could not find establishment $establishmentId to remove');
    }
  }

  void toggleFavorite(Establishment establishment) {
    final wasAlreadyFavorite = isFavorite(establishment.id);
    
    if (wasAlreadyFavorite) {
      removeFromFavorites(establishment.id);
    } else {
      addToFavorites(establishment);
    }
    
    debugPrint('🔄 Toggled ${establishment.name}: ${wasAlreadyFavorite ? 'removed' : 'added'}');
  }

  void clearAllFavorites() {
    final count = _favorites.length;
    _favorites.clear();
    debugPrint('🧹 Cleared all $count favorites');
    notifyListeners();
  }

  int get favoritesCount => _favorites.length;

  /// Get a specific favorite by ID
  Establishment? getFavoriteById(String establishmentId) {
    try {
      return _favorites.firstWhere((est) => est.id == establishmentId);
    } catch (e) {
      return null;
    }
  }

  /// Get favorites with a specific status
  List<Establishment> getFavoritesByStatus(EstablishmentStatus status) {
    return _favorites.where((est) => est.status == status).toList();
  }

  /// Get open favorites
  List<Establishment> get openFavorites => getFavoritesByStatus(EstablishmentStatus.open);

  /// Get closed favorites  
  List<Establishment> get closedFavorites => getFavoritesByStatus(EstablishmentStatus.closed);
}