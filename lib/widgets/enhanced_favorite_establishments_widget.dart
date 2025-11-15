import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/di/app_providers.dart';
import '../models/location_models.dart';
import '../services/favorites_service.dart';
import '../utils/app_localizations.dart';

/// Enhanced My Favorite Establishments Widget
///
/// This widget provides a comprehensive view of user's favorite establishments
/// with improved animations, better empty state, and enhanced navigation.
class EnhancedFavoriteEstablishmentsWidget extends ConsumerStatefulWidget {
  /// Optional height constraint for the widget
  final double? height;

  /// Whether to show the full list or a compact view
  final bool isCompact;

  /// Maximum number of items to show in compact mode
  final int maxCompactItems;

  const EnhancedFavoriteEstablishmentsWidget({
    super.key,
    this.height,
    this.isCompact = false,
    this.maxCompactItems = 3,
  });

  @override
  ConsumerState<EnhancedFavoriteEstablishmentsWidget> createState() =>
      _EnhancedFavoriteEstablishmentsWidgetState();
}

class _EnhancedFavoriteEstablishmentsWidgetState
    extends ConsumerState<EnhancedFavoriteEstablishmentsWidget>
    with TickerProviderStateMixin {
  late FavoritesService _favoritesService;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _favoritesService = ref.read(favoritesServiceProvider);
    _favoritesService.addListener(_handleFavoritesChanged);

    // Initialize animations
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    _animationController.forward();
  }

  @override
  void dispose() {
    _favoritesService.removeListener(_handleFavoritesChanged);
    _animationController.dispose();
    super.dispose();
  }

  void _handleFavoritesChanged() {
    if (mounted) {
      setState(() {});
      _animationController.reset();
      _animationController.forward();
    }
  }

  void _navigateToEstablishments() async {
    final localizations = AppLocalizations.of(context)!;

    // For now, navigate to a generic establishments screen
    // In a real app, you'd want to navigate to a dedicated favorites management screen
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          localizations.language == 'Language'
              ? 'Browse establishments to add favorites'
              : 'Parcourir les établissements pour ajouter des favoris',
        ),
        action: SnackBarAction(
          label: localizations.language == 'Language' ? 'Browse' : 'Parcourir',
          onPressed: () {
            // Navigate to location selection
            Navigator.of(context).pushNamed('/locations');
          },
        ),
      ),
    );
  }

  void _navigateToEstablishment(Establishment establishment) {
    final localizations = AppLocalizations.of(context)!;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          localizations.language == 'Language'
              ? 'Opening ${establishment.name}'
              : 'Ouverture de ${establishment.name}',
        ),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    final favorites = _favoritesService.favorites;
    final displayFavorites = widget.isCompact
        ? favorites.take(widget.maxCompactItems).toList()
        : favorites;

    return FadeTransition(
      opacity: _fadeAnimation,
      child: SizedBox(
        height: widget.height,
        child: Card(
          elevation: 6,
          margin: const EdgeInsets.symmetric(vertical: 8),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(
              color: Theme.of(context).primaryColor.withValues(alpha: 0.2),
              width: 1,
            ),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildEnhancedHeader(context, localizations, favorites.length),
                Expanded(
                  child: favorites.isEmpty
                      ? _buildEnhancedEmptyState(localizations)
                      : _buildEnhancedFavoritesList(displayFavorites),
                ),
                if (widget.isCompact &&
                    favorites.length > widget.maxCompactItems)
                  _buildViewAllButton(localizations, favorites.length),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEnhancedHeader(
    BuildContext context,
    AppLocalizations localizations,
    int favoritesCount,
  ) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Theme.of(context).primaryColor.withValues(alpha: 0.15),
            Theme.of(context).primaryColor.withValues(alpha: 0.08),
          ],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              Icons.favorite,
              color: Theme.of(context).primaryColor,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              localizations.myFavoriteEstablishments,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).primaryColor,
              ),
            ),
          ),
          if (favoritesCount > 0) ...[
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color:
                        Theme.of(context).primaryColor.withValues(alpha: 0.3),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Text(
                '$favoritesCount',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildEnhancedEmptyState(AppLocalizations localizations) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.grey.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.favorite_border,
                size: 48,
                color: Colors.grey[400],
              ),
            ),
            const SizedBox(height: 20),
            Text(
              localizations.noFavorites,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              localizations.language == 'Language'
                  ? 'Start exploring establishments to add your favorites!'
                  : 'Commencez à explorer les établissements pour ajouter vos favoris!',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[500],
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: _navigateToEstablishments,
              icon: const Icon(Icons.explore, size: 18),
              label: Text(
                localizations.language == 'Language'
                    ? 'Explore Now'
                    : 'Explorer Maintenant',
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).primaryColor,
                foregroundColor: Colors.white,
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEnhancedFavoritesList(List<Establishment> favorites) {
    return ListView.separated(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      itemCount: favorites.length,
      separatorBuilder: (context, index) => const SizedBox(height: 8),
      itemBuilder: (context, index) {
        final establishment = favorites[index];
        return _buildEnhancedFavoriteCard(establishment, index);
      },
    );
  }

  Widget _buildEnhancedFavoriteCard(Establishment establishment, int index) {
    final localizations = AppLocalizations.of(context)!;

    return AnimatedContainer(
      duration: Duration(milliseconds: 300 + (index * 50)),
      curve: Curves.easeOutBack,
      child: Card(
        elevation: 2,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () => _navigateToEstablishment(establishment),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Hero(
                  tag: 'establishment_${establishment.id}',
                  child: Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: establishment.status.color.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color:
                            establishment.status.color.withValues(alpha: 0.3),
                        width: 1,
                      ),
                    ),
                    child: Icon(
                      establishment.isOpen
                          ? Icons.store
                          : Icons.store_mall_directory,
                      color: establishment.status.color,
                      size: 24,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        establishment.name,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        establishment.address,
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 12,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color:
                              establishment.status.color.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          establishment.status
                              .getDisplayText('en'), // Simplified for now
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w500,
                            color: establishment.status.color,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.favorite, color: Colors.red, size: 20),
                  onPressed: () {
                    _favoritesService.removeFromFavorites(establishment.id);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          localizations.language == 'Language'
                              ? 'Removed ${establishment.name} from favorites'
                              : 'Retiré ${establishment.name} des favoris',
                        ),
                        duration: const Duration(seconds: 2),
                      ),
                    );
                  },
                  tooltip: localizations.removeFromFavorites,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildViewAllButton(AppLocalizations localizations, int totalCount) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      child: TextButton(
        onPressed: () {
          // Navigate to full favorites screen
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => Scaffold(
                appBar: AppBar(
                  title: Text(localizations.myFavoriteEstablishments),
                  backgroundColor: Theme.of(context).primaryColor,
                  foregroundColor: Colors.white,
                ),
                body: const EnhancedFavoriteEstablishmentsWidget(
                    isCompact: false),
              ),
            ),
          );
        },
        child: Text(
          localizations.language == 'Language'
              ? 'View All $totalCount Favorites'
              : 'Voir Tous les $totalCount Favoris',
          style: TextStyle(
            color: Theme.of(context).primaryColor,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }
}
