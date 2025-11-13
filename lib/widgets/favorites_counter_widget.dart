import 'package:flutter/material.dart';
import '../services/favorites_service.dart';
import '../utils/app_localizations.dart';

/// A simple widget that shows real-time favorites count
/// Demonstrates the live connection between favorite actions and the UI
class FavoritesCounterWidget extends StatefulWidget {
  const FavoritesCounterWidget({super.key});

  @override
  State<FavoritesCounterWidget> createState() => _FavoritesCounterWidgetState();
}

class _FavoritesCounterWidgetState extends State<FavoritesCounterWidget>
    with TickerProviderStateMixin {
  final FavoritesService _favoritesService = FavoritesService();
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  int _previousCount = 0;

  @override
  void initState() {
    super.initState();
    _favoritesService.addListener(_onFavoritesChanged);
    _previousCount = _favoritesService.favoritesCount;

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.3,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.elasticOut,
    ));
  }

  @override
  void dispose() {
    _favoritesService.removeListener(_onFavoritesChanged);
    _animationController.dispose();
    super.dispose();
  }

  void _onFavoritesChanged() {
    if (mounted) {
      final currentCount = _favoritesService.favoritesCount;
      if (currentCount != _previousCount) {
        // Animate when count changes
        _animationController.forward().then((_) {
          _animationController.reverse();
        });
        _previousCount = currentCount;
      }
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    final count = _favoritesService.favoritesCount;

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
