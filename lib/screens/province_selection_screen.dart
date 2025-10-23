import 'package:flutter/material.dart';
import '../utils/app_localizations.dart';
import '../models/location_models.dart';
import '../services/location_data_service.dart';
import 'city_selection_screen.dart';

class ProvinceSelectionScreen extends StatefulWidget {
  const ProvinceSelectionScreen({super.key});

  @override
  State<ProvinceSelectionScreen> createState() => _ProvinceSelectionScreenState();
}

class _ProvinceSelectionScreenState extends State<ProvinceSelectionScreen> {
  final LocationDataService _dataService = LocationDataService();
  List<Province> _provinces = [];

  @override
  void initState() {
    super.initState();
    _dataService.initializeData();
    _provinces = _dataService.getProvincesWithEstablishments();
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    
    return Scaffold(
      appBar: AppBar(
        title: Text(localizations.language == 'Language' 
          ? 'Select Province' 
          : 'Sélectionnez une Province'),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
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
                  Icons.location_on,
                  size: 48,
                  color: Colors.white,
                ),
                const SizedBox(height: 12),
                Text(
                  localizations.language == 'Language'
                    ? 'Choose Your Province'
                    : 'Choisissez Votre Province',
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
                    ? 'Select a province to view available QuikTik locations'
                    : 'Sélectionnez une province pour voir les emplacements QuikTik disponibles',
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.white70,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
          Expanded(
            child: _provinces.isEmpty 
              ? _buildEmptyState(localizations)
              : _buildProvinceList(),
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
            Icons.location_off,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            localizations.language == 'Language'
              ? 'No locations available'
              : 'Aucun emplacement disponible',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProvinceList() {
    return ListView.builder(
      padding: const EdgeInsets.all(16.0),
      itemCount: _provinces.length,
      itemBuilder: (context, index) {
        final province = _provinces[index];
        return _buildProvinceCard(province);
      },
    );
  }

  Widget _buildProvinceCard(Province province) {
    final totalEstablishments = province.cities
        .map((city) => city.establishments.length)
        .fold(0, (prev, count) => prev + count);

    final openEstablishments = province.cities
        .expand((city) => city.establishments)
        .where((est) => est.status == EstablishmentStatus.open)
        .length;

    return Card(
      elevation: 4,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: () => _navigateToProvince(province),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center(
                  child: Text(
                    province.code,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).primaryColor,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      province.name,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      AppLocalizations.of(context)!.language == 'Language'
                        ? '$totalEstablishments locations • $openEstablishments open'
                        : '$totalEstablishments emplacements • $openEstablishments ouverts',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.green.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.circle,
                                size: 8,
                                color: Colors.green,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                '$openEstablishments',
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Colors.green,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '${province.cities.length} ${AppLocalizations.of(context)!.language == 'Language' ? 'cities' : 'villes'}',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[500],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios,
                size: 16,
                color: Colors.grey[400],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _navigateToProvince(Province province) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CitySelectionScreen(province: province),
      ),
    );
  }
}