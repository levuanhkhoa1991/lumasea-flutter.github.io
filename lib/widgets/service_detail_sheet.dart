import 'package:flutter/material.dart';
import '../data/catalog.dart';
import '../l10n/app_localizations.dart';
import '../state/cart_model.dart';
import 'contact_sheet.dart';
import 'photo_carousel.dart';
import 'route_map.dart';

String _categoryDescriptionKey(ServiceCategory category) {
  switch (category) {
    case ServiceCategory.tours:
      return 'descTours';
    case ServiceCategory.hotels:
      return 'descHotels';
    case ServiceCategory.restaurants:
      return 'descRestaurants';
    case ServiceCategory.transport:
      return 'descTransport';
  }
}

/// Full detail sheet for a single tour/hotel/restaurant/transport item:
/// photo carousel, description, a mini route map, bundled add-on
/// services (hotels/restaurants to pair with a tour), and quick actions
/// to contact the team or jump straight into booking.
void showServiceDetailSheet(BuildContext context, ServiceItem service, {required VoidCallback onSchedule}) {
  showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) {
      return AnimatedBuilder(
        animation: cart,
        builder: (context, _) {
          final l10n = AppLocalizations.of(context);
          final addOns = catalog
              .where((i) => i.id != service.id && (i.category == ServiceCategory.hotels || i.category == ServiceCategory.restaurants))
              .take(4)
              .toList();

          return DraggableScrollableSheet(
            initialChildSize: 0.9,
            maxChildSize: 0.95,
            minChildSize: 0.5,
            expand: false,
            builder: (context, scrollController) => Container(
              decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.vertical(top: Radius.circular(32))),
              child: ListView(
                controller: scrollController,
                padding: EdgeInsets.zero,
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
                    child: PhotoCarousel(imageUrls: service.photos, fallbackIcon: service.icon, height: 220, borderRadius: BorderRadius.zero),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(22, 18, 22, 24),
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text(l10n.t(service.titleKey), style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: Color(0xFF073B4C))),
                      const SizedBox(height: 6),
                      Text('${l10n.t('priceFrom')} ${formatVnd(service.priceVnd)}', style: const TextStyle(color: Color(0xFF0E7490), fontWeight: FontWeight.w700)),
                      const SizedBox(height: 14),
                      Text(l10n.t(_categoryDescriptionKey(service.category)), style: const TextStyle(color: Colors.black54, height: 1.5)),
                      const SizedBox(height: 22),
                      Text(l10n.t('routeTitle'), style: const TextStyle(fontWeight: FontWeight.w800, color: Color(0xFF073B4C))),
                      const SizedBox(height: 10),
                      RouteMap(
                        stopLabels: [l10n.t('startingPoint'), l10n.t(service.titleKey)],
                        mode: service.transportMode ?? TransportMode.boat,
                        height: 160,
                      ),
                      const SizedBox(height: 24),
                      Text(l10n.t('bundledServices'), style: const TextStyle(fontWeight: FontWeight.w800, color: Color(0xFF073B4C))),
                      const SizedBox(height: 4),
                      Text(l10n.t('bundledServicesSubtitle'), style: const TextStyle(color: Colors.black54, fontSize: 13)),
                      const SizedBox(height: 12),
                      for (final addOn in addOns) _AddOnRow(item: addOn),
                      const SizedBox(height: 24),
                      Row(children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () => showContactSheet(context),
                            icon: const Icon(Icons.call_outlined),
                            label: Text(l10n.t('contactUs')),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          flex: 2,
                          child: FilledButton.icon(
                            onPressed: () {
                              if (!cart.contains(service.id)) cart.add(service.id);
                              Navigator.pop(context);
                              onSchedule();
                            },
                            icon: const Icon(Icons.event_available),
                            label: Text(l10n.t('scheduleNow')),
                          ),
                        ),
                      ]),
                    ]),
                  ),
                ],
              ),
            ),
          );
        },
      );
    },
  );
}

class _AddOnRow extends StatelessWidget {
  final ServiceItem item;
  const _AddOnRow({required this.item});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final inCart = cart.contains(item.id);
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(children: [
        Container(
          width: 40,
          height: 40,
          alignment: Alignment.center,
          decoration: BoxDecoration(color: const Color(0xFFDFF6FA), borderRadius: BorderRadius.circular(12)),
          child: Icon(item.icon, size: 18, color: const Color(0xFF0E7490)),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(l10n.t(item.titleKey), maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
            Text(formatVnd(item.priceVnd), style: const TextStyle(color: Colors.black54, fontSize: 12)),
          ]),
        ),
        IconButton(
          onPressed: () => inCart ? cart.remove(item.id) : cart.add(item.id),
          icon: Icon(inCart ? Icons.check_circle : Icons.add_circle_outline, color: inCart ? const Color(0xFF0E7490) : Colors.black45),
        ),
      ]),
    );
  }
}
