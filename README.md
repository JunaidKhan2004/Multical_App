# Multical

An all-in-one calculator suite built with Flutter, styled with a bold neo-brutalist look (thick borders, hard shadows, monospace type) with full dark/light theme support.

## Calculators

| Calculator | Features |
|---|---|
| **Calculator** | Basic & scientific — trig, log/ln, powers, factorial, constants (π, e), DEG/RAD toggle, live evaluation |
| **Programmer** | HEX · DEC · OCT · BIN with bitwise AND/OR/XOR/NOT and bit shifts |
| **Financial** | EMI, simple/compound interest, tax & percentage |
| **Unit Converter** | Length, weight, temperature, speed, area, volume |
| **Statistics** | Mean, median, mode, standard deviation, variance, range |
| **Date & Time** | Age calculator, date difference, add/subtract days |
| **Health** | BMI, BMR (Harris-Benedict), calories burned |
| **Academic** | GPA, CGPA, target GPA, marks-to-grade converter |
| **Discount** | Discount/markup calculator, unit price comparison |
| **Currency** | Offline exchange rate conversion (reference rates) |

Calculations are saved to a searchable history (backed by [Hive](https://pub.dev/packages/hive)), with results long-press-to-copy where relevant.

## Tech stack

- **Flutter** 3.8+
- **Hive** / **hive_flutter** — local calculation history storage
- **shared_preferences** — settings persistence (theme, haptics, history limit)
- **google_fonts** — Space Mono typeface

No external state management library — plain `StatefulWidget` + `setState`.

## Getting started

```bash
flutter pub get
flutter run
```

## Running tests

```bash
flutter test
```

Tests cover the hand-rolled expression parser and calculator logic (`lib/logic/calculator_logic.dart`) — arithmetic precedence, scientific functions, parentheses auto-closing, sign toggling, and live-calculation behavior.

## Project structure

```
lib/
├── logic/           # Pure calculation logic (expression parser, etc.)
├── models/          # Hive data models
├── services/        # History persistence, app settings cache
├── screens/         # One screen per calculator + home/settings/history/splash
├── theme/           # App-wide colors & text theme
└── widgets/         # Shared brutalist UI components (buttons, fields, cards)
```

## Platforms

Configured for Android and iOS. Web, macOS, Windows, and Linux scaffolding is present but not the primary target.
