import 'package:flutter/material.dart';

class Province {
  final String id;
  final String name;
  final String code; // e.g., "SK" for Saskatchewan
  final List<City> cities;

  Province({
    required this.id,
    required this.name,
    required this.code,
    required this.cities,
  });

  @override
  String toString() => '$name ($code)';
}

class City {
  final String id;
  final String name;
  final String provinceId;
  final List<Establishment> establishments;

  City({
    required this.id,
    required this.name,
    required this.provinceId,
    required this.establishments,
  });

  @override
  String toString() => name;
}

class Establishment {
  final String id;
  final String name;
  final String address;
  final String cityId;
  final EstablishmentHours hours;
  final EstablishmentStatus status;
  final double latitude;
  final double longitude;
  final String? phoneNumber;
  final String? website;

  Establishment({
    required this.id,
    required this.name,
    required this.address,
    required this.cityId,
    required this.hours,
    required this.status,
    required this.latitude,
    required this.longitude,
    this.phoneNumber,
    this.website,
  });

  bool get isOpen => status == EstablishmentStatus.open;
  bool get isClosed => status == EstablishmentStatus.closed;

  @override
  String toString() => name;
}

class EstablishmentHours {
  final String openTime;
  final String closeTime;
  final List<int> workingDays; // 1-7, Monday to Sunday

  EstablishmentHours({
    required this.openTime,
    required this.closeTime,
    required this.workingDays,
  });

  String get displayText => '$openTime – $closeTime';

  bool isOpenOnDay(int dayOfWeek) => workingDays.contains(dayOfWeek);
}

enum EstablishmentStatus {
  open,
  closed,
  temporarilyClosed,
}

extension EstablishmentStatusExtension on EstablishmentStatus {
  String getDisplayText(String languageCode) {
    switch (this) {
      case EstablishmentStatus.open:
        return languageCode == 'fr' ? 'Ouvert' : 'Open';
      case EstablishmentStatus.closed:
        return languageCode == 'fr' ? 'Fermé' : 'Closed';
      case EstablishmentStatus.temporarilyClosed:
        return languageCode == 'fr' ? 'Temporairement fermé' : 'Temporarily Closed';
    }
  }

  Color get color {
    switch (this) {
      case EstablishmentStatus.open:
        return Colors.green;
      case EstablishmentStatus.closed:
        return Colors.red;
      case EstablishmentStatus.temporarilyClosed:
        return Colors.orange;
    }
  }
}