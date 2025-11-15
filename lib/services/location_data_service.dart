import '../models/location_models.dart';
import 'queue_service.dart';

class LocationDataService {
  static final LocationDataService _instance = LocationDataService._internal();
  factory LocationDataService() => _instance;
  LocationDataService._internal();

  late List<Province> _provinces;
  bool _isInitialized = false;

  List<Province> get provinces => _provinces;

  void initializeData() {
    if (_isInitialized) {
      return;
    }

    _provinces = [
      // Saskatchewan
      Province(
        id: 'sk',
        name: 'Saskatchewan',
        code: 'SK',
        cities: [
          City(
            id: 'meadow_lake',
            name: 'Meadow Lake',
            provinceId: 'sk',
            establishments: [
              Establishment(
                id: 'innovation_cu_meadow_lake',
                name: 'Innovation Federal Credit Union Meadow Lake',
                address: '125 Centre St, Meadow Lake, SK S9X 1Z7',
                cityId: 'meadow_lake',
                hours: EstablishmentHours(
                  openTime: '9:00 a.m.',
                  closeTime: '5:00 p.m.',
                  workingDays: [1, 2, 3, 4, 5],
                ),
                status: EstablishmentStatus.open,
                latitude: 54.1289,
                longitude: -108.4342,
                phoneNumber: '1-866-446-7001',
                website: 'https://innovationcu.ca',
              ),
              Establishment(
                id: 'meadow_lake_primary_health_centre',
                name: 'Meadow Lake Primary Health Care Centre',
                address: '218 Centre St, Meadow Lake, SK S9X 1H2',
                cityId: 'meadow_lake',
                hours: EstablishmentHours(
                  openTime: '8:30 a.m.',
                  closeTime: '4:30 p.m.',
                  workingDays: [1, 2, 3, 4, 5],
                ),
                status: EstablishmentStatus.open,
                latitude: 54.1286,
                longitude: -108.4358,
                phoneNumber: '(306) 236-1581',
                website: 'https://www.saskhealthauthority.ca',
              ),
            ],
          ),
        ],
      ),
      // Alberta
      Province(
        id: 'ab',
        name: 'Alberta',
        code: 'AB',
        cities: [
          City(
            id: 'calgary',
            name: 'Calgary',
            provinceId: 'ab',
            establishments: const [],
          ),
          City(
            id: 'edmonton',
            name: 'Edmonton',
            provinceId: 'ab',
            establishments: const [],
          ),
        ],
      ),
      // Ontario
      Province(
        id: 'on',
        name: 'Ontario',
        code: 'ON',
        cities: [
          City(
            id: 'toronto',
            name: 'Toronto',
            provinceId: 'on',
            establishments: const [],
          ),
        ],
      ),
    ];

    _isInitialized = true;
    _initializeQueueService();
  }

  List<Province> getProvincesWithEstablishments() {
    return _provinces
        .where((province) =>
            province.cities.any((city) => city.establishments.isNotEmpty))
        .toList();
  }

  Province? getProvinceById(String id) {
    try {
      return _provinces.firstWhere((province) => province.id == id);
    } catch (e) {
      return null;
    }
  }

  City? getCityById(String id) {
    for (var province in _provinces) {
      try {
        return province.cities.firstWhere((city) => city.id == id);
      } catch (e) {
        continue;
      }
    }
    return null;
  }

  Establishment? getEstablishmentById(String id) {
    for (var province in _provinces) {
      for (var city in province.cities) {
        try {
          return city.establishments.firstWhere((est) => est.id == id);
        } catch (e) {
          continue;
        }
      }
    }
    return null;
  }

  List<Establishment> searchEstablishments(String query, {String? cityId}) {
    List<Establishment> allEstablishments = [];

    for (var province in _provinces) {
      for (var city in province.cities) {
        if (cityId == null || city.id == cityId) {
          allEstablishments.addAll(city.establishments);
        }
      }
    }

    if (query.isEmpty) return allEstablishments;

    return allEstablishments.where((establishment) {
      return establishment.name.toLowerCase().contains(query.toLowerCase()) ||
          establishment.address.toLowerCase().contains(query.toLowerCase());
    }).toList();
  }

  void _initializeQueueService() {
    final allEstablishments = _provinces
        .expand((province) => province.cities)
        .expand((city) => city.establishments)
        .toList();

    if (allEstablishments.isEmpty) {
      return;
    }

    QueueService().initializeQueues(allEstablishments);
  }
}
