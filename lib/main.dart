import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:google_fonts/google_fonts.dart';
import 'data/catalog.dart';
import 'l10n/app_localizations.dart';
import 'widgets/hero_background.dart';
import 'widgets/order_summary.dart';
import 'widgets/route_map.dart';
import 'widgets/service_card.dart';

void main() => runApp(const LumaSeaApp());

/// Global notifier so any widget can change the app's language.
/// Defaults to English.
final ValueNotifier<Locale> appLocale = ValueNotifier(const Locale('en'));

class LumaSeaApp extends StatelessWidget {
  const LumaSeaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<Locale>(
      valueListenable: appLocale,
      builder: (context, locale, _) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'LumaSea',
          locale: locale,
          supportedLocales: AppLocalizations.supportedLocales,
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          localeResolutionCallback: (deviceLocale, supported) => locale,
          theme: ThemeData(
            useMaterial3: true,
            scaffoldBackgroundColor: const Color(0xFFF7F4EC),
            colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF075985)),
            textTheme: GoogleFonts.plusJakartaSansTextTheme(),
          ),
          home: const ExplorePage(),
        );
      },
    );
  }
}

const List<ServiceCategory?> _filterOptions = [null, ServiceCategory.tours, ServiceCategory.hotels, ServiceCategory.restaurants, ServiceCategory.transport];
const int _bookingStepCount = 5;

class ExplorePage extends StatefulWidget {
  const ExplorePage({super.key});

  @override
  State<ExplorePage> createState() => _ExplorePageState();
}

class _ExplorePageState extends State<ExplorePage> {
  final List<String> selectedIds = [];
  ServiceCategory? filter;
  int bookingStep = 0;

  List<ServiceItem> get selectedItems => catalog.where((i) => selectedIds.contains(i.id)).toList();

  /// Route stops for the map: Ho Chi Minh City plus each unique
  /// destination among the selected tours/hotels. Falls back to a demo
  /// route so the map always has something to show.
  List<String> _routeStopKeys(AppLocalizations l10n) {
    final destinationKeys = selectedItems
        .where((i) => i.category == ServiceCategory.tours || i.category == ServiceCategory.hotels)
        .map((i) => i.titleKey)
        .toSet()
        .toList();
    if (destinationKeys.isEmpty) destinationKeys.add('service0Title');
    return ['startingPoint', ...destinationKeys.take(3)];
  }

  TransportMode _selectedTransportMode() {
    final transportItem = selectedItems.where((i) => i.transportMode != null).toList();
    return transportItem.isNotEmpty ? transportItem.first.transportMode! : TransportMode.boat;
  }

  void _openBooking(AppLocalizations l10n) {
    if (selectedIds.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.t('addServiceWarning'))));
      return;
    }
    bookingStep = 0;
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => StatefulBuilder(builder: (context, setModalState) {
        final l = AppLocalizations.of(context);
        return Container(
          height: MediaQuery.sizeOf(context).height * .82,
          padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
          decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.vertical(top: Radius.circular(32))),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Center(child: Container(width: 42, height: 4, decoration: BoxDecoration(color: Colors.black12, borderRadius: BorderRadius.circular(8)))),
            const SizedBox(height: 22),
            Text(l.t('bookingTitle'), style: GoogleFonts.dmSerifDisplay(fontSize: 28, color: const Color(0xFF073B4C))),
            const SizedBox(height: 18),
            Row(children: List.generate(_bookingStepCount, (index) => Expanded(child: Container(margin: const EdgeInsets.only(right: 5), height: 5, decoration: BoxDecoration(color: index <= bookingStep ? const Color(0xFF0E7490) : const Color(0xFFE5E7EB), borderRadius: BorderRadius.circular(8)))))),
            const SizedBox(height: 24),
            Expanded(
              child: SingleChildScrollView(
                child: _BookingContent(
                  step: bookingStep,
                  items: selectedItems,
                  routeStops: _routeStopKeys(l).map((key) => l.t(key)).toList(),
                  transportMode: _selectedTransportMode(),
                ),
              ),
            ),
            const SizedBox(height: 12),
            Row(children: [
              if (bookingStep > 0) OutlinedButton(onPressed: () => setModalState(() => bookingStep--), child: Text(l.t('back'))),
              const Spacer(),
              FilledButton.icon(onPressed: () {
                if (bookingStep < _bookingStepCount - 1) {
                  setModalState(() => bookingStep++);
                } else {
                  Navigator.pop(context);
                }
              }, icon: Icon(bookingStep == _bookingStepCount - 1 ? Icons.check : Icons.arrow_forward), label: Text(bookingStep == _bookingStepCount - 1 ? l.t('finish') : l.t('continueLabel'))),
            ]),
          ]),
        );
      }),
    );
  }

  String _filterLabel(AppLocalizations l10n, ServiceCategory? category) {
    switch (category) {
      case ServiceCategory.tours:
        return l10n.t('filterTours');
      case ServiceCategory.hotels:
        return l10n.t('filterHotels');
      case ServiceCategory.restaurants:
        return l10n.t('filterRestaurants');
      case ServiceCategory.transport:
        return l10n.t('filterTransport');
      case null:
        return l10n.t('filterAll');
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final filtered = catalog.where((item) => filter == null || item.category == filter).toList();

    return Scaffold(
      body: CustomScrollView(slivers: [
        const SliverToBoxAdapter(child: _Hero()),
        SliverPadding(padding: const EdgeInsets.fromLTRB(20, 28, 20, 40), sliver: SliverList(delegate: SliverChildListDelegate([
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Text(l10n.t('destinationsHeading'), style: GoogleFonts.dmSerifDisplay(fontSize: 27, color: const Color(0xFF073B4C))),
            TextButton(onPressed: () {}, child: Text(l10n.t('viewAll'))),
          ]),
          const SizedBox(height: 14),
          SizedBox(height: 42, child: ListView(scrollDirection: Axis.horizontal, children: _filterOptions.map((category) => Padding(padding: const EdgeInsets.only(right: 8), child: ChoiceChip(label: Text(_filterLabel(l10n, category)), selected: filter == category, onSelected: (_) => setState(() => filter = category)))).toList())),
          const SizedBox(height: 18),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 260),
            child: Column(
              key: ValueKey(filter),
              children: [
                for (var i = 0; i < filtered.length; i++)
                  ServiceCard(
                    service: filtered[i],
                    index: i,
                    selected: selectedIds.contains(filtered[i].id),
                    onToggle: () => setState(() {
                      final id = filtered[i].id;
                      selectedIds.contains(id) ? selectedIds.remove(id) : selectedIds.add(id);
                    }),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 260),
            transitionBuilder: (child, animation) => FadeTransition(
              opacity: animation,
              child: SizeTransition(sizeFactor: animation, child: child),
            ),
            child: selectedIds.isEmpty
                ? const SizedBox.shrink()
                : Card(
                    key: const ValueKey('journey-card'),
                    color: const Color(0xFFE0F2FE),
                    child: Padding(
                      padding: const EdgeInsets.all(18),
                      child: Row(children: [
                        const Icon(Icons.luggage_outlined, color: Color(0xFF075985)),
                        const SizedBox(width: 12),
                        Expanded(child: Text('${selectedIds.length} ${l10n.t('journeyCount')}', style: const TextStyle(fontWeight: FontWeight.w700))),
                        FilledButton(onPressed: () => _openBooking(l10n), child: Text(l10n.t('bookNow'))),
                      ]),
                    ),
                  ),
          ),
        ]))),
      ]),
    );
  }
}

class _Hero extends StatelessWidget {
  const _Hero();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return SizedBox(
      height: 430,
      child: Stack(fit: StackFit.expand, children: [
        // Plays assets/videos/hero_wave.mp4 if present, otherwise falls
        // back to an animated gradient + wave painter automatically.
        const HeroBackground(),
        SafeArea(child: Padding(padding: const EdgeInsets.fromLTRB(22, 22, 22, 30), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Text('LumaSea', style: GoogleFonts.dmSerifDisplay(color: Colors.white, fontSize: 29)),
            const _LanguageSwitcher(),
          ]),
          const Spacer(),
          Container(padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 7), decoration: BoxDecoration(color: const Color(0xFFF4C95D), borderRadius: BorderRadius.circular(20)), child: Text(l10n.t('promoTag'), style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w800))),
          const SizedBox(height: 12),
          Text(l10n.t('heroTitle'), style: GoogleFonts.dmSerifDisplay(color: Colors.white, fontSize: 43, height: 1.02)),
          const SizedBox(height: 12),
          Text(l10n.t('heroSubtitle'), style: const TextStyle(color: Colors.white70, fontSize: 15, height: 1.5)),
          const SizedBox(height: 20),
          FilledButton.icon(onPressed: () {}, icon: const Icon(Icons.explore_outlined), label: Text(l10n.t('exploreButton')), style: FilledButton.styleFrom(backgroundColor: const Color(0xFFF4C95D), foregroundColor: const Color(0xFF073B4C), padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14))),
        ]))),
      ]),
    );
  }
}

/// Small pill button in the hero that opens a language picker.
/// Tapping a language updates [appLocale], which rebuilds the whole app.
class _LanguageSwitcher extends StatelessWidget {
  const _LanguageSwitcher();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return PopupMenuButton<Locale>(
      tooltip: l10n.t('language'),
      initialValue: appLocale.value,
      onSelected: (locale) => appLocale.value = locale,
      itemBuilder: (context) => AppLocalizations.supportedLocales.map((locale) {
        final label = AppLocalizations(locale).languageName;
        return PopupMenuItem(value: locale, child: Text(label));
      }).toList(),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(20)),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          const Icon(Icons.language, color: Colors.white, size: 18),
          const SizedBox(width: 6),
          Text(l10n.locale.languageCode.toUpperCase(), style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w700)),
        ]),
      ),
    );
  }
}

/// Content for each of the 5 booking steps:
/// 0. Confirm services  1. Route map  2. Passenger details
/// 3. Payment           4. Order summary
class _BookingContent extends StatelessWidget {
  final int step;
  final List<ServiceItem> items;
  final List<String> routeStops;
  final TransportMode transportMode;

  const _BookingContent({
    required this.step,
    required this.items,
    required this.routeStops,
    required this.transportMode,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    switch (step) {
      case 0:
        return _wrap(
          icon: Icons.map_outlined,
          title: l10n.t('step0Title'),
          subtitle: l10n.t('step0Subtitle'),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(color: const Color(0xFFF1F9FA), borderRadius: BorderRadius.circular(18)),
            child: OrderItemsList(items: items),
          ),
        );
      case 1:
        return _wrap(
          icon: Icons.alt_route,
          title: l10n.t('routeTitle'),
          subtitle: l10n.t('routeSubtitle'),
          child: Column(children: [
            RouteMap(stopLabels: routeStops, mode: transportMode),
            const SizedBox(height: 14),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(color: const Color(0xFFF1F9FA), borderRadius: BorderRadius.circular(14)),
              child: Row(children: [
                Icon(transportIcon(transportMode), color: const Color(0xFF0E7490)),
                const SizedBox(width: 10),
                Expanded(child: Text(l10n.t(transportModeLabelKey(transportMode)), style: const TextStyle(fontWeight: FontWeight.w700))),
              ]),
            ),
          ]),
        );
      case 2:
        return _wrap(
          icon: Icons.person_outline,
          title: l10n.t('step1Title'),
          subtitle: l10n.t('step1Subtitle'),
          child: _textBox(l10n.t('step1Body')),
        );
      case 3:
        return _wrap(
          icon: Icons.credit_card,
          title: l10n.t('step2Title'),
          subtitle: l10n.t('step2Subtitle'),
          child: _textBox(l10n.t('step2Body')),
        );
      default:
        return _wrap(
          icon: Icons.check_circle_outline,
          title: l10n.t('step3Title'),
          subtitle: l10n.t('step3Subtitle'),
          child: Column(children: [
            OrderSummaryCard(items: items),
            const SizedBox(height: 12),
            _textBox(l10n.t('step3Body')),
          ]),
        );
    }
  }

  Widget _textBox(String body) => Container(
        width: double.infinity,
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(color: const Color(0xFFF1F9FA), borderRadius: BorderRadius.circular(18)),
        child: Text(body, style: const TextStyle(height: 1.6, fontWeight: FontWeight.w600)),
      );

  Widget _wrap({required IconData icon, required String title, required String subtitle, required Widget child}) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Icon(icon, color: const Color(0xFF0E7490), size: 34),
      const SizedBox(height: 14),
      Text(title, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: Color(0xFF073B4C))),
      const SizedBox(height: 8),
      Text(subtitle, style: const TextStyle(color: Colors.black54)),
      const SizedBox(height: 20),
      child,
    ]);
  }
}
