import 'package:flutter/material.dart';
import '../utils/app_localizations.dart';
import '../models/location_models.dart';
import '../services/location_data_service.dart';
import '../services/favorites_service.dart';
import 'payment_screen.dart';

class EstablishmentsScreen extends StatefulWidget {
  final City city;
  final String provinceName;

  const EstablishmentsScreen({
    super.key,
    required this.city,
    required this.provinceName,
  });

  @override
  State<EstablishmentsScreen> createState() => _EstablishmentsScreenState();
}

class _EstablishmentsScreenState extends State<EstablishmentsScreen> {
  final TextEditingController _searchController = TextEditingController();
  final LocationDataService _dataService = LocationDataService();
  final FavoritesService _favoritesService = FavoritesService();
  List<Establishment> _filteredEstablishments = [];
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _filteredEstablishments = widget.city.establishments;
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    setState(() {
      _searchQuery = _searchController.text;
      _filteredEstablishments = _dataService.searchEstablishments(
        _searchQuery,
        cityId: widget.city.id,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.city.name}, ${widget.provinceName}'),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          // Header section
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20.0),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Theme.of(context).primaryColor,
                  Theme.of(context).primaryColor.withValues(alpha: 0.7),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Column(
              children: [
                const Icon(
                  Icons.business,
                  size: 48,
                  color: Colors.white,
                ),
                const SizedBox(height: 12),
                Text(
                  localizations.language == 'Language'
                    ? 'QuikTik Establishments'
                    : 'Établissements QuikTik',
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  localizations.language == 'Language'
                    ? 'Select an establishment to join the queue'
                    : 'Sélectionnez un établissement pour rejoindre la file',
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.white70,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
          
          // Search bar
          Container(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: localizations.language == 'Language'
                  ? 'Search establishments...'
                  : 'Rechercher des établissements...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchQuery.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        _searchController.clear();
                      },
                    )
                  : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: Colors.grey[50],
              ),
            ),
          ),
          
          // Results count
          if (_searchQuery.isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  localizations.language == 'Language'
                    ? '${_filteredEstablishments.length} establishments found'
                    : '${_filteredEstablishments.length} établissements trouvés',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 12,
                  ),
                ),
              ),
            ),
          
          // Establishments list
          Expanded(
            child: _filteredEstablishments.isEmpty
              ? _buildEmptyState(localizations)
              : _buildEstablishmentsList(),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(AppLocalizations localizations) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            _searchQuery.isNotEmpty ? Icons.search_off : Icons.business_outlined,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            _searchQuery.isNotEmpty
              ? (localizations.language == 'Language'
                  ? 'No establishments found'
                  : 'Aucun établissement trouvé')
              : (localizations.language == 'Language'
                  ? 'No establishments available'
                  : 'Aucun établissement disponible'),
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey[600],
            ),
          ),
          if (_searchQuery.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              localizations.language == 'Language'
                ? 'Try a different search term'
                : 'Essayez un autre terme de recherche',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[500],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildEstablishmentsList() {
    return ListView.builder(
      padding: const EdgeInsets.all(16.0),
      itemCount: _filteredEstablishments.length,
      itemBuilder: (context, index) {
        final establishment = _filteredEstablishments[index];
        return _buildEstablishmentCard(establishment);
      },
    );
  }

  Widget _buildEstablishmentCard(Establishment establishment) {
    final localizations = AppLocalizations.of(context)!;
    final currentLocale = Localizations.localeOf(context);
    
    return Card(
      elevation: 4,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header row with name and status
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        establishment.name,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        establishment.address,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
                // Favorite button
                IconButton(
                  icon: Icon(
                    _favoritesService.isFavorite(establishment.id)
                        ? Icons.favorite
                        : Icons.favorite_border,
                    color: _favoritesService.isFavorite(establishment.id)
                        ? Colors.red
                        : Colors.grey[600],
                  ),
                  onPressed: () {
                    setState(() {
                      _favoritesService.toggleFavorite(establishment);
                    });
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          _favoritesService.isFavorite(establishment.id)
                              ? localizations.addToFavorites
                              : localizations.removeFromFavorites,
                        ),
                        duration: const Duration(seconds: 2),
                      ),
                    );
                  },
                  tooltip: _favoritesService.isFavorite(establishment.id)
                      ? localizations.removeFromFavorites
                      : localizations.addToFavorites,
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: establishment.status.color.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(16),
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
                        establishment.status.getDisplayText(currentLocale.languageCode),
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: establishment.status.color,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 16),
            
            // Hours and contact info
            Row(
              children: [
                Icon(
                  Icons.access_time,
                  size: 16,
                  color: Colors.grey[600],
                ),
                const SizedBox(width: 8),
                Text(
                  establishment.hours.displayText,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[700],
                  ),
                ),
                if (establishment.phoneNumber != null) ...[
                  const SizedBox(width: 16),
                  Icon(
                    Icons.phone,
                    size: 16,
                    color: Colors.grey[600],
                  ),
                  const SizedBox(width: 4),
                  Text(
                    establishment.phoneNumber!,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[700],
                    ),
                  ),
                ],
              ],
            ),
            
            const SizedBox(height: 16),
            
            // Action button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: establishment.isOpen
                  ? () => _joinQueue(establishment)
                  : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: establishment.isOpen
                    ? Theme.of(context).primaryColor
                    : Colors.grey[300],
                  foregroundColor: establishment.isOpen
                    ? Colors.white
                    : Colors.grey[600],
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      establishment.isOpen ? Icons.people : Icons.block,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      establishment.isOpen
                        ? (localizations.language == 'Language'
                            ? 'Join the Queue'
                            : 'Accéder à la Fila')
                        : (localizations.language == 'Language'
                            ? 'Currently Closed'
                            : 'Actuellement Fermé'),
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _joinQueue(Establishment establishment) {
    _showJoinQueueConfirmation(establishment);
  }

  void _showJoinQueueConfirmation(Establishment establishment) {
    final localizations = AppLocalizations.of(context)!;
    
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            localizations.confirmSelection,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          content: Text(
            '${localizations.youHaveSelected} ${establishment.name}',
            style: const TextStyle(fontSize: 16),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close dialog
              },
              child: Text(
                localizations.no,
                style: TextStyle(color: Colors.grey[600]),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close dialog
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => PaymentScreen(establishment: establishment),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).primaryColor,
                foregroundColor: Colors.white,
              ),
              child: Text(
                localizations.yes,
              ),
            ),
          ],
        );
      },
    );
  }


}