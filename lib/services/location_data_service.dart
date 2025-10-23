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
            id: 'saskatoon',
            name: 'Saskatoon',
            provinceId: 'sk',
            establishments: [
              Establishment(
                id: 'innovation_cu_saskatoon',
                name: 'Innovation Credit Union',
                address: '1330 20th St W, Saskatoon, SK S7M 0Z8',
                cityId: 'saskatoon',
                hours: EstablishmentHours(
                  openTime: '8:30 a.m.',
                  closeTime: '4:00 p.m.',
                  workingDays: [1, 2, 3, 4, 5], // Monday to Friday
                ),
                status: EstablishmentStatus.open,
                latitude: 52.1332,
                longitude: -106.6700,
                phoneNumber: '(306) 244-1000',
                website: 'https://innovationcu.ca',
              ),
              Establishment(
                id: 'affinity_cu_saskatoon',
                name: 'Affinity Credit Union',
                address: '1441 2nd Ave N, Saskatoon, SK S7K 2G3',
                cityId: 'saskatoon',
                hours: EstablishmentHours(
                  openTime: '9:00 a.m.',
                  closeTime: '5:00 p.m.',
                  workingDays: [1, 2, 3, 4, 5],
                ),
                status: EstablishmentStatus.open,
                latitude: 52.1394,
                longitude: -106.6617,
                phoneNumber: '(306) 934-4000',
                website: 'https://affinitycu.ca',
              ),
              Establishment(
                id: 'conexus_cu_saskatoon',
                name: 'Conexus Credit Union',
                address: '123 2nd Ave S, Saskatoon, SK S7K 1K6',
                cityId: 'saskatoon',
                hours: EstablishmentHours(
                  openTime: '9:30 a.m.',
                  closeTime: '4:30 p.m.',
                  workingDays: [1, 2, 3, 4, 5],
                ),
                status: EstablishmentStatus.closed,
                latitude: 52.1280,
                longitude: -106.6700,
                phoneNumber: '(306) 244-3200',
                website: 'https://conexuscu.com',
              ),
            ],
          ),
          City(
            id: 'regina',
            name: 'Regina',
            provinceId: 'sk',
            establishments: [
              Establishment(
                id: 'conexus_cu_regina',
                name: 'Conexus Credit Union',
                address: '1960 Albert St, Regina, SK S4P 2T8',
                cityId: 'regina',
                hours: EstablishmentHours(
                  openTime: '9:00 a.m.',
                  closeTime: '5:00 p.m.',
                  workingDays: [1, 2, 3, 4, 5],
                ),
                status: EstablishmentStatus.open,
                latitude: 50.4452,
                longitude: -104.6189,
                phoneNumber: '(306) 566-6000',
                website: 'https://conexuscu.com',
              ),
              Establishment(
                id: 'innovation_cu_regina',
                name: 'Innovation Credit Union',
                address: '1777 Victoria Ave, Regina, SK S4P 4K5',
                cityId: 'regina',
                hours: EstablishmentHours(
                  openTime: '8:30 a.m.',
                  closeTime: '4:00 p.m.',
                  workingDays: [1, 2, 3, 4, 5],
                ),
                status: EstablishmentStatus.open,
                latitude: 50.4520,
                longitude: -104.6100,
                phoneNumber: '(306) 791-8000',
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
                id: 'servus_cu_calgary',
                name: 'Servus Credit Union',
                address: '800 6 Ave SW, Calgary, AB T2P 3G3',
                cityId: 'calgary',
                hours: EstablishmentHours(
                  openTime: '9:00 a.m.',
                  closeTime: '5:00 p.m.',
                  workingDays: [1, 2, 3, 4, 5],
                ),
                status: EstablishmentStatus.open,
                latitude: 51.0447,
                longitude: -114.0719,
                phoneNumber: '(403) 276-7000',
                website: 'https://servus.ca',
              ),
              Establishment(
                id: 'atb_financial_calgary',
                name: 'ATB Financial',
                address: '707 7 Ave SW, Calgary, AB T2P 0Z3',
                cityId: 'calgary',
                hours: EstablishmentHours(
                  openTime: '9:30 a.m.',
                  closeTime: '4:30 p.m.',
                  workingDays: [1, 2, 3, 4, 5],
                ),
                status: EstablishmentStatus.open,
                latitude: 51.0456,
                longitude: -114.0820,
                phoneNumber: '(403) 514-4300',
                website: 'https://atb.com',
              ),
            ],
          ),
          City(
            id: 'edmonton',
            name: 'Edmonton',
            provinceId: 'ab',
            establishments: [
              Establishment(
                id: 'servus_cu_edmonton',
                name: 'Servus Credit Union',
                address: '10220 103 Ave NW, Edmonton, AB T5J 0K4',
                cityId: 'edmonton',
                hours: EstablishmentHours(
                  openTime: '9:00 a.m.',
                  closeTime: '5:00 p.m.',
                  workingDays: [1, 2, 3, 4, 5],
                ),
                status: EstablishmentStatus.open,
                latitude: 53.5461,
                longitude: -113.4938,
                phoneNumber: '(780) 496-7000',
                website: 'https://servus.ca',
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
                id: 'meridian_cu_toronto',
                name: 'Meridian Credit Union',
                address: '100 King St W, Toronto, ON M5X 1A9',
                cityId: 'toronto',
                hours: EstablishmentHours(
                  openTime: '9:00 a.m.',
                  closeTime: '5:00 p.m.',
                  workingDays: [1, 2, 3, 4, 5],
                ),
                status: EstablishmentStatus.open,
                latitude: 43.6532,
                longitude: -79.3832,
                phoneNumber: '(416) 515-8000',
                website: 'https://meridiancu.ca',
              ),
              Establishment(
                id: 'duca_financial_toronto',
                name: 'Duca Financial Services',
                address: '5290 Yonge St, Toronto, ON M2N 5P9',
                cityId: 'toronto',
                hours: EstablishmentHours(
                  openTime: '9:30 a.m.',
                  closeTime: '4:30 p.m.',
                  workingDays: [1, 2, 3, 4, 5],
                ),
                status: EstablishmentStatus.temporarilyClosed,
                latitude: 43.7615,
                longitude: -79.4121,
                phoneNumber: '(416) 223-8000',
                website: 'https://duca.com',
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
    return _provinces.where((province) =>
        province.cities.any((city) => city.establishments.isNotEmpty)).toList();
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