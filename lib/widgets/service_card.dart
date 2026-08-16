import 'package:flutter/material.dart';
import '../data/catalog.dart';
import '../l10n/app_localizations.dart';
import '../state/cart_model.dart';
import 'photo_carousel.dart';

/// A single explorable service (tour / hotel / restaurant / transport)
/// shown as a card with a swipeable photo carousel on top, info below,
/// and a staggered fade + slide-in entrance animation based on [index].
///
/// Tapping the card body opens the full detail sheet ([onTap]); tapping
/// the +/− button quick-adds or removes one from the cart directly.
class ServiceCard extends StatelessWidget {
  final ServiceItem service;
  final VoidCallback onTap;
  final int index;

  const ServiceCard({
    super.key,
    required this.service,
    required this.onTap,
    required this.index,
  });

  String _typeLabel(AppLocalizations l10n, ServiceCategory category) {
    switch (category) {
      case ServiceCategory.tours:
        return l10n.t('filterTours');
      case ServiceCategory.hotels:
        return l10n.t('filterHotels');
      case ServiceCategory.restaurants:
        return l10n.t('filterRestaurants');
      case ServiceCategory.transport:
        return l10n.t('filterTransport');
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final isFlyCar = service.transportMode == TransportMode.flyCar;

    final card = Card(
      margin: const EdgeInsets.only(bottom: 16),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(children: [
              PhotoCarousel(
                imageUrls: service.photos,
                fallbackIcon: service.icon,
                height: 170,
                borderRadius: BorderRadius.zero,
              ),
              if (isFlyCar)
                Positioned(
                  top: 10,
                  left: 10,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
                    decoration: BoxDecoration(color: const Color(0xFFF4C95D), borderRadius: BorderRadius.circular(20)),
                    child: Text(l10n.t('newBadge'),
                        style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: Color(0xFF073B4C))),
                  ),
                ),
            ]),
            Padding(
              padding: const EdgeInsets.all(14),
              child: Row(children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(children: [
                        Text(_typeLabel(l10n, service.category),
                            style: const TextStyle(
                                color: Color(0xFF0E7490), fontSize: 12, fontWeight: FontWeight.w700)),
                        if (service.duration != null) ...[
                          const SizedBox(width: 8),
                          const Icon(Icons.schedule, size: 12, color: Colors.black38),
                          const SizedBox(width: 2),
                          Text(service.duration!, style: const TextStyle(fontSize: 12, color: Colors.black54)),
                        ],
                      ]),
                      const SizedBox(height: 4),
                      Text(l10n.t(service.titleKey), style: const TextStyle(fontWeight: FontWeight.w800)),
                      const SizedBox(height: 6),
                      Text('${l10n.t('priceFrom')} ${formatVnd(service.priceVnd)}',
                          style: const TextStyle(color: Colors.black54)),
                    ],
                  ),
                ),
                AnimatedBuilder(
                  animation: cart,
                  builder: (context, _) {
                    final selected = cart.contains(service.id);
                    return AnimatedScale(
                      scale: selected ? 1.1 : 1.0,
                      duration: const Duration(milliseconds: 180),
                      child: IconButton(
                        onPressed: () => selected ? cart.remove(service.id) : cart.add(service.id),
                        icon: Icon(
                          selected ? Icons.check_circle : Icons.add_circle_outline,
                          color: selected ? const Color(0xFF0E7490) : Colors.black45,
                          size: 28,
                        ),
                      ),
                    );
                  },
                ),
              ]),
            ),
          ],
        ),
      ),
    );

    // Staggered fade + rise-in entrance, timed by the item's index.
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: Duration(milliseconds: 420 + index * 90),
      curve: Curves.easeOutCubic,
      builder: (context, value, child) => Opacity(
        opacity: value,
        child: Transform.translate(
          offset: Offset(0, (1 - value) * 24),
          child: child,
        ),
      ),
      child: card,
    );
  }
}
