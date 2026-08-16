# LumaSea — Flutter Island Travel Booking

LumaSea is a pure Flutter/Dart mobile prototype for island travel: book tours, coastal hotels, and restaurants in one seamless journey. Available in **English (default), Japanese, and Vietnamese**.

## Features

- Blue ocean hero with animated waves using `CustomPainter`.
- **17 destinations & services** across Tours, Hotels, and Restaurants — Phu Quoc, Ha Long Bay, Nha Trang, Hoi An, Con Dao, Sapa, Mekong Delta, Ninh Binh, Da Nang, and more.
- **Transport category**: River & sea boat, private car, domestic flight, and a futuristic **FlyCar air taxi** (2026 premium option) — each with its own duration and price, addable to your journey like any other service.
- Filter by Tours, Hotels, Restaurants, and Transport.
- Add or remove services from your journey.
- **5-step booking flow**: confirm services → journey route map → passenger details → simulated payment → full order summary.
- **Illustrated route map**: an animated, stylized journey map (not a real GPS map — no API key needed) showing your stops with a moving icon for your chosen transport mode.
- **Order details**: itemized list of every selected service with prices, subtotal, service fee, and total.
- Material 3 interface with an ocean-inspired palette.
- In-app language switcher (tap the language pill in the top-right of the hero) — switches instantly between English, 日本語, and Tiếng Việt without restarting the app.
- Animated hero background: layered painted waves + a slowly shifting gradient by default. Drop a video at `assets/videos/hero_wave.mp4` (see `assets/videos/README.txt`) and it automatically plays there instead — no code changes needed.
- Swipeable photo carousel on every card, with animated dot indicators. Ships with placeholder network photos; swap in your own URLs (or local assets) any time.
- Staggered fade + rise-in entrance animation for cards, a smooth fade when switching filter chips, and an animated add/remove toggle on each service.

## Run the project

```bash
flutter pub get
flutter run
```

## Structure

```text
lib/
├── main.dart                       # app, explore screen, 5-step booking flow
├── l10n/
│   └── app_localizations.dart      # translation strings (en / ja / vi) + language switcher logic
├── data/
│   └── catalog.dart                # all destinations, hotels, restaurants & transport options
└── widgets/
    ├── hero_background.dart        # video-with-fallback animated hero background
    ├── photo_carousel.dart         # reusable swipeable image carousel + dot indicators
    ├── service_card.dart           # tour/hotel/restaurant/transport card
    ├── route_map.dart              # illustrated animated journey map
    └── order_summary.dart          # itemized order list + subtotal/fee/total
assets/
├── videos/                         # drop hero_wave.mp4 here for a real video background
└── images/                         # optional local images
```

## Adding more destinations or transport options

Everything lives in `lib/data/catalog.dart` as a single `List<ServiceItem>`. To add a new destination, hotel, restaurant, or transport option, add another `ServiceItem(...)` entry with a unique `id`, then add its `titleKey` (and translated text for en/ja/vi) to `lib/l10n/app_localizations.dart`.

## About the route map

The journey map in the booking flow is a **stylized illustration** (curved path, stop dots, and an animated icon for your transport mode), built entirely with Flutter's `CustomPainter` — it needs no API key and no native map SDK setup, so it works everywhere this project runs, including Snack. If you'd like a real interactive map later, swap `RouteMap` for the `google_maps_flutter` package with your own Google Maps API key (this requires native Android/iOS configuration that isn't practical inside a Snack-style project).

## Localization

This project uses a lightweight, dependency-free localization approach (a `Map<String, Map<String, String>>` inside `lib/l10n/app_localizations.dart`) instead of Flutter's `gen-l10n` code generation. This keeps the project a single, self-contained Dart codebase — ideal for pasting into tools like **Snack** / DartPad-style Flutter playgrounds that don't run a build step.

To add a new string:
1. Add a key to the `en` map in `app_localizations.dart` (source of truth).
2. Add the same key with translated text to the `ja` and `vi` maps.
3. Use it in the UI with `AppLocalizations.of(context).t('yourKey')`.

To add a new language, add another `Locale` to `AppLocalizations.supportedLocales`, a matching entry to `_languageNames`, and a translation map under `_values`.

## Product notes

Data and payments are currently in-memory mocks for UI prototyping only. A production release should add an API, authentication, booking management, payment gateway, and server-side price validation.
