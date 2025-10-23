import 'package:flutter/material.dart';

import '../models/location_models.dart';
import '../services/favorites_service.dart';
import '../utils/app_localizations.dart';

class MyFavoriteEstablishmentsWidget extends StatefulWidget {
  const MyFavoriteEstablishmentsWidget({super.key});

  @override
  State<MyFavoriteEstablishmentsWidget> createState() =>
      _MyFavoriteEstablishmentsWidgetState();
}

class _MyFavoriteEstablishmentsWidgetState
    extends State<MyFavoriteEstablishmentsWidget> {
  final FavoritesService _favoritesService = FavoritesService();

  @override
  void initState() {
    super.initState();
    _favoritesService.addListener(_handleFavoritesChanged);
  }

  @override
  void dispose() {
    _favoritesService.removeListener(_handleFavoritesChanged);
    super.dispose();
  }

  void _handleFavoritesChanged() {
    if (mounted) {
      setState(() {});
    }
  }

  void _openFavoritesExplorer() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const FavoritesExplorerScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    final favorites = _favoritesService.favorites;

    return LayoutBuilder(
      builder: (context, constraints) {
        final double fallbackHeight = favorites.isEmpty ? 240 : 320;
        final double targetHeight = constraints.hasBoundedHeight
            ? constraints.maxHeight
            : fallbackHeight;

        return ConstrainedBox(
          constraints: BoxConstraints.tightFor(height: targetHeight),
          child: Card(
            elevation: 8,
            margin: const EdgeInsets.symmetric(vertical: 8),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: BorderSide(
                color: Theme.of(context).primaryColor.withValues(alpha: 0.2),
                width: 1,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(context, localizations, favorites.length),
                const SizedBox(height: 12),
                Expanded(
                  child: favorites.isEmpty
                      ? _buildEmptyState(localizations)
                      : _buildFavoritesList(favorites),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeader(
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
            Theme.of(context).primaryColor.withValues(alpha: 0.1),
            Theme.of(context).primaryColor.withValues(alpha: 0.05),
          ],
        ),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(12),
          topRight: Radius.circular(12),
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.favorite,
            color: Theme.of(context).primaryColor,
            size: 24,
          ),
          const SizedBox(width: 12),
          Text(
            localizations.myFavoriteEstablishments,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).primaryColor,
            ),
          ),
          const Spacer(),
          if (favoritesCount > 0) ...[
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor,
                borderRadius: BorderRadius.circular(12),
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
            const SizedBox(width: 8),
          ],
          TextButton(
            onPressed: _openFavoritesExplorer,
            child: Text(
              localizations.language == 'Language' ? 'Manage' : 'Gérer',
              style: TextStyle(color: Theme.of(context).primaryColor),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(AppLocalizations localizations) {
    return Center(
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.favorite_border,
              size: 48,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              localizations.noFavorites,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            OutlinedButton.icon(
              onPressed: () {
                _openFavoritesExplorer();
              },
              icon: const Icon(Icons.search),
              label: Text(
                localizations.language == 'Language'
                    ? 'Browse Establishments'
                    : 'Parcourir les Établissements',
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFavoritesList(List<Establishment> favorites) {
    return ListView.builder(
      padding: const EdgeInsets.all(8),
      itemCount: favorites.length,
      physics: const BouncingScrollPhysics(),
      itemBuilder: (context, index) {
        final establishment = favorites[index];
        return _buildFavoriteCard(establishment);
      },
    );
  }

  Widget _buildFavoriteCard(Establishment establishment) {
    final localizations = AppLocalizations.of(context)!;

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: establishment.status.color,
          child: Icon(
            establishment.isOpen ? Icons.store : Icons.store_mall_directory,
            color: Colors.white,
            size: 20,
          ),
        ),
        title: Text(
          establishment.name,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              establishment.address,
              style: TextStyle(color: Colors.grey[600]),
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: establishment.status.color.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                    border:
                        Border.all(color: establishment.status.color, width: 1),
                  ),
                  child: Text(
                    establishment.status.getDisplayText(
                        localizations.language == 'Language' ? 'en' : 'fr'),
                    style: TextStyle(
                      color: establishment.status.color,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  establishment.hours.displayText,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.favorite, color: Colors.red),
              onPressed: () {
                setState(() {
                  _favoritesService.removeFromFavorites(establishment.id);
                });
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      localizations.language == 'Language'
                          ? 'Removed from favorites'
                          : 'Retiré des favoris',
                    ),
                    duration: const Duration(seconds: 2),
                  ),
                );
              },
              tooltip: localizations.removeFromFavorites,
            ),
            Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: Colors.grey[400],
            ),
          ],
        ),
        onTap: () {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                localizations.language == 'Language'
                    ? 'Selected ${establishment.name}'
                    : 'Sélectionné ${establishment.name}',
              ),
              duration: const Duration(seconds: 2),
            ),
          );
        },
      ),
    );
  }
}

class FavoritesExplorerScreen extends StatefulWidget {
  const FavoritesExplorerScreen({super.key});

  @override
  State<FavoritesExplorerScreen> createState() => _FavoritesExplorerScreenState();
}

class _FavoritesExplorerScreenState extends State<FavoritesExplorerScreen> {
  final FavoritesService _favoritesService = FavoritesService();

  @override
  void initState() {
    super.initState();
    _favoritesService.addListener(_onFavoritesChanged);
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

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    final favorites = _favoritesService.favorites;

    return Scaffold(
      appBar: AppBar(
        title: Text(localizations.myFavoriteEstablishments),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
      ),
      body: favorites.isEmpty
          ? _buildEmptyState(localizations)
          : ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: favorites.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final establishment = favorites[index];
                return _FavoriteEstablishmentTile(
                  establishment: establishment,
                  onRemove: () {
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
                );
              },
            ),
    );
  }

  Widget _buildEmptyState(AppLocalizations localizations) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.favorite_border,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              localizations.noFavorites,
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              localizations.language == 'Language'
                  ? 'Mark establishments as favorites to see them listed here.'
                  : 'Ajoutez des établissements aux favoris pour les voir ici.',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[500],
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _FavoriteEstablishmentTile extends StatelessWidget {
  final Establishment establishment;
  final VoidCallback onRemove;

  const _FavoriteEstablishmentTile({
    required this.establishment,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;

    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  backgroundColor: establishment.status.color,
                  child: Icon(
                    establishment.isOpen ? Icons.store : Icons.store_mall_directory,
                    color: Colors.white,
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
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        establishment.address,
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  tooltip: localizations.removeFromFavorites,
                  onPressed: onRemove,
                  icon: const Icon(Icons.delete_outline),
                  color: Colors.red,
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                _StatusChip(establishment: establishment),
                const SizedBox(width: 8),
                Icon(
                  Icons.access_time,
                  size: 16,
                  color: Colors.grey[600],
                ),
                const SizedBox(width: 4),
                Text(
                  establishment.hours.displayText,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  final Establishment establishment;

  const _StatusChip({required this.establishment});

  @override
  Widget build(BuildContext context) {
    final localeCode = AppLocalizations.of(context)!.language == 'Language' ? 'en' : 'fr';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: establishment.status.color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: establishment.status.color, width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.circle,
            size: 8,
            color: establishment.status.color,
          ),
          const SizedBox(width: 6),
          Text(
            establishment.status.getDisplayText(localeCode),
            style: TextStyle(
              color: establishment.status.color,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
