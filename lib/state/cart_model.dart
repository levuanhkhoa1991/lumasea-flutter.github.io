import 'package:flutter/foundation.dart';
import '../data/catalog.dart';

/// One resolved row in the cart: a catalog item plus how many of it.
class CartLine {
  final ServiceItem item;
  final int quantity;
  const CartLine(this.item, this.quantity);

  int get lineTotal => item.priceVnd * quantity;
}

/// Global shopping cart for the app. Holds quantities by service id and
/// notifies listeners (badge, cart sheet, booking flow) on any change.
///
/// Usage: wrap any widget that should rebuild on cart changes with
/// `AnimatedBuilder(animation: cart, builder: (context, _) => ...)`.
class CartModel extends ChangeNotifier {
  final Map<String, int> _quantities = {};

  int quantityOf(String id) => _quantities[id] ?? 0;

  bool contains(String id) => quantityOf(id) > 0;

  int get totalItems => _quantities.values.fold(0, (sum, q) => sum + q);

  bool get isEmpty => _quantities.isEmpty;

  List<CartLine> get lines => _quantities.entries
      .map((e) {
        final item = catalog.where((i) => i.id == e.key);
        if (item.isEmpty) return null;
        return CartLine(item.first, e.value);
      })
      .whereType<CartLine>()
      .toList();

  int get subtotal => lines.fold(0, (sum, l) => sum + l.lineTotal);

  void add(String id, {int by = 1}) {
    _quantities[id] = (_quantities[id] ?? 0) + by;
    notifyListeners();
  }

  void setQuantity(String id, int quantity) {
    if (quantity <= 0) {
      _quantities.remove(id);
    } else {
      _quantities[id] = quantity;
    }
    notifyListeners();
  }

  void remove(String id) {
    _quantities.remove(id);
    notifyListeners();
  }

  void clear() {
    _quantities.clear();
    notifyListeners();
  }
}

/// A single global cart instance shared across the app.
final CartModel cart = CartModel();
