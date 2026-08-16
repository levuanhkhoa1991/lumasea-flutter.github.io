import 'package:flutter/material.dart';
import '../data/catalog.dart';
import '../l10n/app_localizations.dart';

/// Itemized list of selected services with icon, name, and price.
/// Used both while confirming the cart and in the final order summary.
class OrderItemsList extends StatelessWidget {
  final List<ServiceItem> items;
  const OrderItemsList({super.key, required this.items});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Column(
      children: [
        for (final item in items)
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Row(children: [
              Container(
                width: 36,
                height: 36,
                alignment: Alignment.center,
                decoration: BoxDecoration(color: const Color(0xFFDFF6FA), borderRadius: BorderRadius.circular(10)),
                child: Icon(item.icon, size: 18, color: const Color(0xFF0E7490)),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(l10n.t(item.titleKey),
                    maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.w600)),
              ),
              Text(formatVnd(item.priceVnd), style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
            ]),
          ),
      ],
    );
  }
}

/// Full order summary card: itemized list, subtotal, service fee, and
/// total — shown as the final step of the booking flow.
class OrderSummaryCard extends StatelessWidget {
  final List<ServiceItem> items;
  const OrderSummaryCard({super.key, required this.items});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final subtotal = items.fold<int>(0, (sum, item) => sum + item.priceVnd);
    final fee = (subtotal * 0.05).round();
    final total = subtotal + fee;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(color: const Color(0xFFF1F9FA), borderRadius: BorderRadius.circular(18)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(l10n.t('orderSummaryTitle'),
            style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15, color: Color(0xFF073B4C))),
        const SizedBox(height: 14),
        OrderItemsList(items: items),
        const Divider(height: 22),
        _totalsRow(l10n.t('subtotal'), formatVnd(subtotal)),
        const SizedBox(height: 6),
        _totalsRow(l10n.t('serviceFee'), formatVnd(fee)),
        const SizedBox(height: 10),
        _totalsRow(l10n.t('total'), formatVnd(total), emphasize: true),
      ]),
    );
  }

  Widget _totalsRow(String label, String value, {bool emphasize = false}) {
    final style = TextStyle(
      fontWeight: emphasize ? FontWeight.w800 : FontWeight.w600,
      fontSize: emphasize ? 15 : 13,
      color: emphasize ? const Color(0xFF073B4C) : Colors.black54,
    );
    return Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
      Text(label, style: style),
      Text(value, style: style),
    ]);
  }
}
