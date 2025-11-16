import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../services/auth_service.dart';
import '../../services/favorites_service.dart';
import '../../services/location_data_service.dart';
import '../../services/queue_service.dart';

/// Provides a singleton [AuthService] instance backed by Riverpod.
final authServiceProvider = ChangeNotifierProvider<AuthService>((ref) {
  return AuthService();
});

/// Exposes the favorites service so widgets can react to updates.
final favoritesServiceProvider = ChangeNotifierProvider<FavoritesService>(
  (ref) => FavoritesService(),
);

/// Queue interactions and ticket streams.
final queueServiceProvider = Provider<QueueService>((ref) {
  return QueueService();
});

/// Location data and establishment hierarchy.
final locationDataServiceProvider = Provider<LocationDataService>((ref) {
  return LocationDataService();
});
