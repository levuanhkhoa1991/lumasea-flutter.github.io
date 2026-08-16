import 'package:flutter/material.dart';
import '../data/catalog.dart';
import '../l10n/app_localizations.dart';
import '../state/cart_model.dart';
import 'contact_sheet.dart';

/// Full cart: every selected service with a quantity stepper (add/remove
/// one at a time) and a trash button to remove the line entirely.
/// Live-updates as the cart changes, since it listens to [cart].
void showCartSheet(BuildContext context, {required VoidCallback onCheckout}) {
  showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) {
      return AnimatedBuilder(
        animation: cart,
        builder: (context, _) {
          final l10n = AppLocalizations.of(context);
          final lines = cart.lines;
          return Container(
            height: MediaQuery.sizeOf(context).height * .75,
            padding: const EdgeInsets.fromLTRB(24, 12, 24, 20),
            decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.vertical(top: Radius.circular(32))),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Center(child: Container(width: 42, height: 4, decoration: BoxDecoration(color: Colors.black12, borderRadius: BorderRadius.circular(8)))),
              const SizedBox(height: 18),
              Text(l10n.t('cartTitle'), style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w800, color: Color(0xFF073B4C))),
              const SizedBox(height: 16),
              Expanded(
                child: lines.isEmpty
                    ? Center(
                        child: Text(l10n.t('cartEmpty'), style: const TextStyle(color: Colors.black45)),
                      )
                    : ListView.separated(
                        itemCount: lines.length,
                        separatorBuilder: (_, __) => const Divider(height: 22),
                        itemBuilder: (context, index) => _CartLineRow(line: lines[index]),
                      ),
              ),
              if (lines.isNotEmpty) ...[
                const Divider(height: 24),
                Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                  Text(l10n.t('subtotal'), style: const TextStyle(fontWeight: FontWeight.w700)),
                  Text(formatVnd(cart.subtotal), style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
                ]),
                const SizedBox(height: 16),
                Row(children: [
                  OutlinedButton.icon(
                    onPressed: () => showContactSheet(context),
                    icon: const Icon(Icons.call_outlined, size: 18),
                    label: Text(l10n.t('contactUs')),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: FilledButton.icon(
                      onPressed: () {
                        Navigator.pop(context);
                        onCheckout();
                      },
                      icon: const Icon(Icons.event_available),
                      label: Text(l10n.t('scheduleNow')),
                    ),
                  ),
                ]),
              ],
            ]),
          );
        },
      );
    },
  );
}

class _CartLineRow extends StatelessWidget {
  final CartLine line;
  const _CartLineRow({required this.line});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Row(children: [
      Container(
        width: 44,
        height: 44,
        alignment: Alignment.center,
        decoration: BoxDecoration(color: const Color(0xFFDFF6FA), borderRadius: BorderRadius.circular(12)),
        child: Icon(line.item.icon, color: const Color(0xFF0E7490)),
      ),
      const SizedBox(width: 12),
      Expanded(
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(l10n.t(line.item.titleKey), maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.w700)),
          const SizedBox(height: 3),
          Text(formatVnd(line.item.priceVnd), style: const TextStyle(color: Colors.black54, fontSize: 12)),
        ]),
      ),
      const SizedBox(width: 8),
      _QuantityStepper(line: line),
      IconButton(
        onPressed: () => cart.remove(line.item.id),
        icon: const Icon(Icons.delete_outline, color: Colors.black38, size: 20),
      ),
    ]);
  }
}

class _QuantityStepper extends StatelessWidget {
  final CartLine line;
  const _QuantityStepper({required this.line});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(color: const Color(0xFFF1F9FA), borderRadius: BorderRadius.circular(20)),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        IconButton(
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
          onPressed: () => cart.setQuantity(line.item.id, line.quantity - 1),
          icon: const Icon(Icons.remove, size: 16),
        ),
        SizedBox(width: 20, child: Text('${line.quantity}', textAlign: TextAlign.center, style: const TextStyle(fontWeight: FontWeight.w700))),
        IconButton(
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
          onPressed: () => cart.add(line.item.id),
          icon: const Icon(Icons.add, size: 16),
        ),
      ]),
    );
  }
}
