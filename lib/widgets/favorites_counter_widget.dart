import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/di/app_providers.dart';
import '../services/favorites_service.dart';
import '../utils/app_localizations.dart';

/// A simple widget that shows real-time favorites count
/// Demonstrates the live connection between favorite actions and the UI
class FavoritesCounterWidget extends ConsumerStatefulWidget {
  const FavoritesCounterWidget({super.key});

  @override
  ConsumerState<FavoritesCounterWidget> createState() =>
      _FavoritesCounterWidgetState();
}

class _FavoritesCounterWidgetState extends ConsumerState<FavoritesCounterWidget>
    with TickerProviderStateMixin {
  late final AnimationController _animationController;
  late final Animation<double> _scaleAnimation;
  ProviderSubscription<FavoritesService>? _favoritesSubscription;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.3,
    ).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.elasticOut,
      ),
    );

    _favoritesSubscription = ref.listenManual<FavoritesService>(
      favoritesServiceProvider,
      (previous, next) {
        final previousCount = previous?.favoritesCount ?? next.favoritesCount;
        final currentCount = next.favoritesCount;

        if (currentCount != previousCount && mounted) {
          _animationController.forward(from: 0).then((_) {
            if (mounted) {
              _animationController.reverse();
            }
          });
        }
      },
      fireImmediately: true,
    );
  }

  @override
  void dispose() {
    _favoritesSubscription?.close();
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    final favoritesService = ref.watch(favoritesServiceProvider);
    final count = favoritesService.favoritesCount;

    return AnimatedBuilder(
      animation: _scaleAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: count > 0
                    ? [
                        Colors.red.withValues(alpha: 0.8),
                        Colors.pink.withValues(alpha: 0.6)
                      ]
                    : [
                        Colors.grey.withValues(alpha: 0.3),
                        Colors.grey.withValues(alpha: 0.2)
                      ],
              ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: count > 0
                  ? [
                      BoxShadow(
                        color: Colors.red.withValues(alpha: 0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ]
                  : null,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.favorite,
                  color: count > 0 ? Colors.white : Colors.grey[600],
                  size: 16,
                ),
                const SizedBox(width: 6),
                Text(
                  '$count',
                  style: TextStyle(
                    color: count > 0 ? Colors.white : Colors.grey[600],
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(width: 4),
                Text(
                  localizations.language == 'Language' ? 'fav' : 'fav',
                  style: TextStyle(
                    color: count > 0 ? Colors.white70 : Colors.grey[500],
                    fontSize: 10,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
