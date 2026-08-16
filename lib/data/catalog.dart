import 'package:flutter/material.dart';

enum ServiceCategory { tours, hotels, restaurants, transport }

/// Transport modes offered between destinations.
/// [flyCar] is a fun near-future 2026 air-taxi option — a premium,
/// faster alternative alongside the more conventional boat/car/flight.
enum TransportMode { boat, car, flight, flyCar }

enum PaymentMethod { domestic, international }

/// A real ocean photo used as the hero background. If it fails to load
/// (e.g. no internet), the hero automatically falls back to the
/// animated gradient + wave painter — see widgets/hero_background.dart.
const String heroPhotoUrl =
    'https://images.unsplash.com/photo-1507525428034-b723cf961d3e?auto=format&fit=crop&w=1600&q=80';

class ServiceItem {
  final String id;
  final ServiceCategory category;
  final String titleKey;
  final int priceVnd;
  final IconData icon;
  final List<String> photos;
  final TransportMode? transportMode;
  final String? duration; // e.g. "3h", "35 min" — universal, not localized

  const ServiceItem({
    required this.id,
    required this.category,
    required this.titleKey,
    required this.priceVnd,
    required this.icon,
    required this.photos,
    this.transportMode,
    this.duration,
  });
}

List<String> _photos(String seed) => [
      'https://picsum.photos/seed/$seed-1/800/600',
      'https://picsum.photos/seed/$seed-2/800/600',
      'https://picsum.photos/seed/$seed-3/800/600',
    ];

/// The full catalog: tours across many Vietnamese destinations, hotels,
/// restaurants, and transport options (river/sea boat, private car,
/// domestic flight, and a futuristic FlyCar air taxi).
final List<ServiceItem> catalog = [
  // --- Tours / destinations ---
  ServiceItem(id: 'tour-phuquoc', category: ServiceCategory.tours, titleKey: 'service0Title', priceVnd: 2890000, icon: Icons.sailing, photos: _photos('phuquoc')),
  ServiceItem(id: 'tour-halong', category: ServiceCategory.tours, titleKey: 'destHaLong', priceVnd: 3590000, icon: Icons.landscape, photos: _photos('halong')),
  ServiceItem(id: 'tour-nhatrang', category: ServiceCategory.tours, titleKey: 'destNhaTrang', priceVnd: 2190000, icon: Icons.beach_access, photos: _photos('nhatrang')),
  ServiceItem(id: 'tour-hoian', category: ServiceCategory.tours, titleKey: 'destHoiAn', priceVnd: 1490000, icon: Icons.nightlife, photos: _photos('hoian')),
  ServiceItem(id: 'tour-condao', category: ServiceCategory.tours, titleKey: 'destConDao', priceVnd: 4290000, icon: Icons.park, photos: _photos('condao')),
  ServiceItem(id: 'tour-sapa', category: ServiceCategory.tours, titleKey: 'destSapa', priceVnd: 1990000, icon: Icons.terrain, photos: _photos('sapa')),
  ServiceItem(id: 'tour-mekong', category: ServiceCategory.tours, titleKey: 'destMekong', priceVnd: 990000, icon: Icons.water, photos: _photos('mekong')),
  ServiceItem(id: 'tour-ninhbinh', category: ServiceCategory.tours, titleKey: 'destNinhBinh', priceVnd: 1290000, icon: Icons.water, photos: _photos('ninhbinh')),
  ServiceItem(id: 'tour-danang', category: ServiceCategory.tours, titleKey: 'destDaNang', priceVnd: 1690000, icon: Icons.location_city, photos: _photos('danang')),

  // --- Hotels ---
  ServiceItem(id: 'hotel-hotram', category: ServiceCategory.hotels, titleKey: 'service1Title', priceVnd: 1650000, icon: Icons.hotel, photos: _photos('hotram')),
  ServiceItem(id: 'hotel-halong', category: ServiceCategory.hotels, titleKey: 'hotelHalongLux', priceVnd: 3290000, icon: Icons.hotel, photos: _photos('halonghotel')),
  ServiceItem(id: 'hotel-hoian', category: ServiceCategory.hotels, titleKey: 'hotelHoiAnBoutique', priceVnd: 1190000, icon: Icons.apartment, photos: _photos('hoianhotel')),
  ServiceItem(id: 'hotel-nhatrang', category: ServiceCategory.hotels, titleKey: 'hotelNhaTrangResort', priceVnd: 2090000, icon: Icons.hotel, photos: _photos('nhatranghotel')),

  // --- Restaurants ---
  ServiceItem(id: 'rest-ganhdau', category: ServiceCategory.restaurants, titleKey: 'service2Title', priceVnd: 490000, icon: Icons.restaurant, photos: _photos('ganhdau')),
  ServiceItem(id: 'rest-hoian', category: ServiceCategory.restaurants, titleKey: 'restHoiAnLantern', priceVnd: 390000, icon: Icons.local_dining, photos: _photos('hoianrest')),
  ServiceItem(id: 'rest-mekong', category: ServiceCategory.restaurants, titleKey: 'restMekongFloating', priceVnd: 290000, icon: Icons.set_meal, photos: _photos('mekongrest')),

  // --- Transport ---
  ServiceItem(id: 'transport-boat', category: ServiceCategory.transport, titleKey: 'transportBoat', priceVnd: 350000, icon: Icons.directions_boat_filled, photos: _photos('boat'), transportMode: TransportMode.boat, duration: '3h'),
  ServiceItem(id: 'transport-car', category: ServiceCategory.transport, titleKey: 'transportCar', priceVnd: 890000, icon: Icons.directions_car_filled, photos: _photos('car'), transportMode: TransportMode.car, duration: '5h'),
  ServiceItem(id: 'transport-flight-eco', category: ServiceCategory.transport, titleKey: 'transportFlightEco', priceVnd: 890000, icon: Icons.flight, photos: _photos('flighteco'), transportMode: TransportMode.flight, duration: '1h10'),
  ServiceItem(id: 'transport-flight-plus', category: ServiceCategory.transport, titleKey: 'transportFlightPlus', priceVnd: 1490000, icon: Icons.flight, photos: _photos('flightplus'), transportMode: TransportMode.flight, duration: '1h10'),
  ServiceItem(id: 'transport-flight-business', category: ServiceCategory.transport, titleKey: 'transportFlightBusiness', priceVnd: 2790000, icon: Icons.flight, photos: _photos('flightbiz'), transportMode: TransportMode.flight, duration: '1h05'),
  ServiceItem(id: 'transport-flycar', category: ServiceCategory.transport, titleKey: 'transportFlyCar', priceVnd: 2990000, icon: Icons.flight_takeoff, photos: _photos('flycar'), transportMode: TransportMode.flyCar, duration: '35 min'),
];

IconData transportIcon(TransportMode mode) {
  switch (mode) {
    case TransportMode.boat:
      return Icons.directions_boat_filled;
    case TransportMode.car:
      return Icons.directions_car_filled;
    case TransportMode.flight:
      return Icons.flight;
    case TransportMode.flyCar:
      return Icons.flight_takeoff;
  }
}

String transportModeLabelKey(TransportMode mode) {
  switch (mode) {
    case TransportMode.boat:
      return 'modeBoat';
    case TransportMode.car:
      return 'modeCar';
    case TransportMode.flight:
      return 'modeFlight';
    case TransportMode.flyCar:
      return 'modeFlyCar';
  }
}

/// Formats a VND amount as "2,890,000 VND".
String formatVnd(int amount) {
  final s = amount.toString();
  final buffer = StringBuffer();
  for (var i = 0; i < s.length; i++) {
    if (i > 0 && (s.length - i) % 3 == 0) buffer.write(',');
    buffer.write(s[i]);
  }
  return '${buffer.toString()} VND';
}
