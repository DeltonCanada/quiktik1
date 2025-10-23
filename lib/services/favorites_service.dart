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
      notifyListeners();
    }
  }

  void removeFromFavorites(String establishmentId) {
    final initialLength = _favorites.length;
    _favorites.removeWhere((establishment) => establishment.id == establishmentId);

    if (_favorites.length != initialLength) {
      notifyListeners();
    }
  }

  void toggleFavorite(Establishment establishment) {
    if (isFavorite(establishment.id)) {
      removeFromFavorites(establishment.id);
    } else {
      addToFavorites(establishment);
    }
  }

  void clearAllFavorites() {
    _favorites.clear();
    notifyListeners();
  }

  int get favoritesCount => _favorites.length;
}