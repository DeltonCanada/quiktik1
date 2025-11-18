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
              Establishment(
                id: 'meadow_lake_service_canada',
                name: 'Service Canada Meadow Lake Centre',
                address: '204 Centre St, Meadow Lake, SK S9X 1K4',
                cityId: 'meadow_lake',
                hours: EstablishmentHours(
                  openTime: '8:30 a.m.',
                  closeTime: '4:00 p.m.',
                  workingDays: [1, 2, 3, 4, 5],
                ),
                status: EstablishmentStatus.temporarilyClosed,
                latitude: 54.1293,
                longitude: -108.4371,
                phoneNumber: '1-800-622-6232',
                website: 'https://www.canada.ca/en/employment-social-development.html',
              ),
            ],
          ),
          City(
            id: 'saskatoon',
            name: 'Saskatoon',
            provinceId: 'sk',
            establishments: [
              Establishment(
                id: 'saskatoon_city_hall',
                name: 'Saskatoon City Hall',
                address: '222 3rd Ave N, Saskatoon, SK S7K 0J5',
                cityId: 'saskatoon',
                hours: EstablishmentHours(
                  openTime: '8:00 a.m.',
                  closeTime: '5:00 p.m.',
                  workingDays: [1, 2, 3, 4, 5],
                ),
                status: EstablishmentStatus.open,
                latitude: 52.1318,
                longitude: -106.6608,
                phoneNumber: '(306) 975-2476',
                website: 'https://www.saskatoon.ca',
              ),
              Establishment(
                id: 'saskatoon_service_canada',
                name: 'Service Canada Centre - Saskatoon',
                address: '101 22nd St E, Saskatoon, SK S7K 0E1',
                cityId: 'saskatoon',
                hours: EstablishmentHours(
                  openTime: '8:30 a.m.',
                  closeTime: '4:00 p.m.',
                  workingDays: [1, 2, 3, 4, 5],
                ),
                status: EstablishmentStatus.open,
                latitude: 52.1301,
                longitude: -106.6587,
                phoneNumber: '1-800-622-6232',
                website: 'https://www.canada.ca/en/employment-social-development.html',
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
            establishments: [
              Establishment(
                id: 'calgary_city_hall',
                name: 'Calgary City Hall',
                address: '800 Macleod Trail SE, Calgary, AB T2P 2M5',
                cityId: 'calgary',
                hours: EstablishmentHours(
                  openTime: '8:00 a.m.',
                  closeTime: '6:00 p.m.',
                  workingDays: [1, 2, 3, 4, 5],
                ),
                status: EstablishmentStatus.open,
                latitude: 51.0453,
                longitude: -114.0570,
                phoneNumber: '(403) 268-2489',
                website: 'https://www.calgary.ca',
              ),
              Establishment(
                id: 'calgary_service_alberta',
                name: 'Service Alberta Registry - Downtown',
                address: '355 Centre St S, Calgary, AB T2G 0W1',
                cityId: 'calgary',
                hours: EstablishmentHours(
                  openTime: '9:00 a.m.',
                  closeTime: '5:00 p.m.',
                  workingDays: [1, 2, 3, 4, 5],
                ),
                status: EstablishmentStatus.open,
                latitude: 51.0447,
                longitude: -114.0640,
                phoneNumber: '(403) 297-6250',
                website: 'https://www.alberta.ca/registries',
              ),
            ],
          ),
          City(
            id: 'edmonton',
            name: 'Edmonton',
            provinceId: 'ab',
            establishments: [
              Establishment(
                id: 'edmonton_service_alberta',
                name: 'Service Alberta Registry - Edson Building',
                address: '10410 99 Ave NW, Edmonton, AB T5K 2K2',
                cityId: 'edmonton',
                hours: EstablishmentHours(
                  openTime: '8:15 a.m.',
                  closeTime: '4:30 p.m.',
                  workingDays: [1, 2, 3, 4, 5],
                ),
                status: EstablishmentStatus.open,
                latitude: 53.5411,
                longitude: -113.4938,
                phoneNumber: '(780) 427-7013',
                website: 'https://www.alberta.ca/registries',
              ),
            ],
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
            establishments: [
              Establishment(
                id: 'toronto_serviceontario_centre',
                name: 'ServiceOntario College Park',
                address: '777 Bay St, Toronto, ON M5B 2H7',
                cityId: 'toronto',
                hours: EstablishmentHours(
                  openTime: '9:00 a.m.',
                  closeTime: '5:00 p.m.',
                  workingDays: [1, 2, 3, 4, 5],
                ),
                status: EstablishmentStatus.open,
                latitude: 43.6605,
                longitude: -79.3836,
                phoneNumber: '1-800-267-8097',
                website: 'https://www.ontario.ca/page/serviceontario',
              ),
              Establishment(
                id: 'toronto_city_hall',
                name: 'Toronto City Hall',
                address: '100 Queen St W, Toronto, ON M5H 2N2',
                cityId: 'toronto',
                hours: EstablishmentHours(
                  openTime: '8:30 a.m.',
                  closeTime: '4:30 p.m.',
                  workingDays: [1, 2, 3, 4, 5],
                ),
                status: EstablishmentStatus.open,
                latitude: 43.6535,
                longitude: -79.3841,
                phoneNumber: '311',
                website: 'https://www.toronto.ca',
              ),
            ],
          ),
          City(
            id: 'ottawa',
            name: 'Ottawa',
            provinceId: 'on',
            establishments: [
              Establishment(
                id: 'ottawa_serviceontario',
                name: 'ServiceOntario Ottawa Centre',
                address: '110 Laurier Ave W, Ottawa, ON K1P 1J1',
                cityId: 'ottawa',
                hours: EstablishmentHours(
                  openTime: '8:30 a.m.',
                  closeTime: '4:30 p.m.',
                  workingDays: [1, 2, 3, 4, 5],
                ),
                status: EstablishmentStatus.open,
                latitude: 45.4236,
                longitude: -75.6950,
                phoneNumber: '1-800-267-8097',
                website: 'https://www.ontario.ca/page/serviceontario',
              ),
            ],
          ),
        ],
      ),
      // British Columbia
      Province(
        id: 'bc',
        name: 'British Columbia',
        code: 'BC',
        cities: [
          City(
            id: 'vancouver',
            name: 'Vancouver',
            provinceId: 'bc',
            establishments: [
              Establishment(
                id: 'vancouver_servicebc',
                name: 'ServiceBC Vancouver',
                address: '757 Hastings St W, Vancouver, BC V6C 1A1',
                cityId: 'vancouver',
                hours: EstablishmentHours(
                  openTime: '8:30 a.m.',
                  closeTime: '4:30 p.m.',
                  workingDays: [1, 2, 3, 4, 5],
                ),
                status: EstablishmentStatus.open,
                latitude: 49.2870,
                longitude: -123.1150,
                phoneNumber: '1-800-663-7867',
                website: 'https://www2.gov.bc.ca/gov/content/governments/servicebc',
              ),
              Establishment(
                id: 'vancouver_city_hall',
                name: 'Vancouver City Hall',
                address: '453 W 12th Ave, Vancouver, BC V5Y 1V4',
                cityId: 'vancouver',
                hours: EstablishmentHours(
                  openTime: '8:30 a.m.',
                  closeTime: '5:00 p.m.',
                  workingDays: [1, 2, 3, 4, 5],
                ),
                status: EstablishmentStatus.open,
                latitude: 49.2609,
                longitude: -123.1140,
                phoneNumber: '3-1-1',
                website: 'https://vancouver.ca',
              ),
            ],
          ),
          City(
            id: 'victoria',
            name: 'Victoria',
            provinceId: 'bc',
            establishments: [
              Establishment(
                id: 'victoria_servicebc',
                name: 'ServiceBC Victoria',
                address: '403-1803 Douglas St, Victoria, BC V8T 5C3',
                cityId: 'victoria',
                hours: EstablishmentHours(
                  openTime: '8:30 a.m.',
                  closeTime: '4:30 p.m.',
                  workingDays: [1, 2, 3, 4, 5],
                ),
                status: EstablishmentStatus.open,
                latitude: 48.4272,
                longitude: -123.3657,
                phoneNumber: '1-800-663-7867',
                website: 'https://www2.gov.bc.ca/gov/content/governments/servicebc',
              ),
            ],
          ),
        ],
      ),
      // Manitoba
      Province(
        id: 'mb',
        name: 'Manitoba',
        code: 'MB',
        cities: [
          City(
            id: 'winnipeg',
            name: 'Winnipeg',
            provinceId: 'mb',
            establishments: [
              Establishment(
                id: 'winnipeg_service_mb',
                name: 'Service Manitoba Centre - Downtown',
                address: '1035-401 York Ave, Winnipeg, MB R3C 0P8',
                cityId: 'winnipeg',
                hours: EstablishmentHours(
                  openTime: '8:30 a.m.',
                  closeTime: '4:30 p.m.',
                  workingDays: [1, 2, 3, 4, 5],
                ),
                status: EstablishmentStatus.open,
                latitude: 49.8880,
                longitude: -97.1485,
                phoneNumber: '1-866-626-4862',
                website: 'https://residents.gov.mb.ca/servicecentres.html',
              ),
              Establishment(
                id: 'winnipeg_city_hall',
                name: 'Winnipeg City Hall',
                address: '510 Main St, Winnipeg, MB R3B 1B9',
                cityId: 'winnipeg',
                hours: EstablishmentHours(
                  openTime: '8:30 a.m.',
                  closeTime: '4:30 p.m.',
                  workingDays: [1, 2, 3, 4, 5],
                ),
                status: EstablishmentStatus.open,
                latitude: 49.8994,
                longitude: -97.1375,
                phoneNumber: '3-1-1',
                website: 'https://winnipeg.ca',
              ),
            ],
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
