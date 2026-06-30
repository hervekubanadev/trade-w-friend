<div align="center">
  <h1>TradeWFriend</h1>
  <p><strong>Offline-First POS & Digital Payments Infrastructure for African Retail</strong></p>
  <p>
    <img src="https://img.shields.io/badge/Flutter-02569B?logo=flutter" alt="Flutter">
    <img src="https://img.shields.io/badge/Supabase-3ECF8E?logo=supabase" alt="Supabase">
    <img src="https://img.shields.io/badge/Riverpod-7B1FA2?logo=riverpod" alt="Riverpod">
    <img src="https://img.shields.io/badge/Dart-0175C2?logo=dart" alt="Dart">
    <img src="https://img.shields.io/badge/GoRouter-4285F4" alt="GoRouter">
    <img src="https://img.shields.io/badge/Platform-Android%20%7C%20iOS%20%7C%20Web-6DB33F" alt="Multi-platform">
    <img src="https://img.shields.io/badge/License-MIT-yellow" alt="MIT License">
  </p>
  <p>
    <a href="#-architecture">Architecture</a> •
    <a href="#-api-documentation">API</a> •
    <a href="#-security">Security</a> •
    <a href="#-roadmap">Roadmap</a> •
    <a href="#-deployment">Deployment</a>
  </p>
</div>

---

## Problem

Across sub-Saharan Africa, 90%+ of retail transactions are still cash-based. SMBs lack affordable, offline-capable POS infrastructure that works on existing tablets and smartphones. Existing solutions require constant internet connectivity, charge SaaS fees in USD, and do not support the mobile-money-first payments landscape.

**TradeWFriend** solves this with an offline-first Flutter kiosk POS that:
- Runs on any Android/iOS tablet as a locked-down kiosk
- Operates with intermittent connectivity via Supabase local cache
- Supports Rwandan Franc (RWF) with phone-based PIN auth
- Tracks inventory, sales, debts, and customer ledgers in real time
- Is designed for mobile money gateway integration (MTN MoMo, Airtel Money, Tigo Cash)

---

## Screenshots

<p align="center">
  <em>Screenshots coming soon — replace these placeholders with actual app screenshots.</em>
</p>

| Kiosk Dashboard | Sales Recording | Inventory Management | Debt Ledger |
|:---:|:---:|:---:|:---:|
| ![](assets/screenshots/dashboard.png) | ![](assets/screenshots/sales.png) | ![](assets/screenshots/inventory.png) | ![](assets/screenshots/debts.png) |

---

## Architecture

```
┌─────────────────────────────────────────────────────────────────────┐
│                        Presentation Layer                           │
│  ┌────────────┐ ┌──────────┐ ┌───────────┐ ┌──────────┐ ┌───────┐  │
│  │ Auth Screen│ │Dashboard │ │ Inventory │ │  Sales   │ │Debts  │  │
│  └─────┬──────┘ └────┬─────┘ └─────┬─────┘ └────┬─────┘ └───┬───┘  │
│        │             │             │            │           │      │
│  ┌─────┴─────────────┴─────────────┴────────────┴───────────┴──┐   │
│  │              GoRouter (Declarative Routing)                   │   │
│  └──────────────────────────────┬───────────────────────────────┘   │
│                                 │                                   │
│  ┌──────────────────────────────┴───────────────────────────────┐   │
│  │              Riverpod (StateNotifier + Provider)              │   │
│  │  ┌──────────┐ ┌──────────┐ ┌──────────┐ ┌────────────────┐  │   │
│  │  │ Auth     │ │Inventory │ │  Sales   │ │   Dashboard    │  │   │
│  │  │Notifier  │ │Notifier  │ │ Notifier │ │   Notifier     │  │   │
│  │  └────┬─────┘ └────┬─────┘ └────┬─────┘ └───────┬────────┘  │   │
│  └───────┼────────────┼────────────┼───────────────┼────────────┘   │
│          │            │            │               │                │
│  ┌───────┴────────────┴────────────┴───────────────┴────────────┐   │
│  │                    Repository Layer                           │   │
│  │  ┌──────────┐ ┌──────────────┐ ┌───────────┐ ┌───────────┐  │   │
│  │  │ AuthRepo │ │ InventoryRepo│ │ SalesRepo │ │ DebtRepo  │  │   │
│  │  └────┬─────┘ └──────┬───────┘ └─────┬─────┘ └─────┬─────┘  │   │
│  └───────┼──────────────┼───────────────┼─────────────┼─────────┘   │
│          │              │               │             │             │
│  ┌───────┴──────────────┴───────────────┴─────────────┴─────────┐   │
│  │                Supabase Client (supabase_flutter)             │   │
│  │           Real-time subscriptions + Local caching             │   │
│  └──────────────────────────────┬───────────────────────────────┘   │
└─────────────────────────────────┼───────────────────────────────────┘
                                  │
                    ┌─────────────┴─────────────┐
                    │        Supabase            │
                    │  ┌─────────────────────┐   │
                    │  │   PostgreSQL 16      │   │
                    │  │   Row-Level Security │   │
                    │  │   Realtime Broadcast │   │
                    │  └─────────────────────┘   │
                    └───────────────────────────┘
```

### Tech Stack

| Layer | Technology | Purpose |
|-------|-----------|---------|
| **UI Framework** | Flutter 3.x / Dart 3.12+ | Cross-platform, single codebase for Android/iOS/Web |
| **State Management** | Riverpod 2.x | Compile-safe, testable, dependency-injected state |
| **Routing** | GoRouter 14.x | Declarative, deep-linkable, redirect-guarded routing |
| **Backend** | Supabase (PostgreSQL 16) | Managed Postgres, real-time, row-level security |
| **Charts** | fl_chart 0.70 | 7-day revenue bar charts, ledger visualizations |
| **Auth** | SHA-256 PIN (phone+salt) | Offline-capable, no backend dependency for auth |
| **Kiosk** | SystemChrome + SharedPreferences | Immersive mode, back-button interception |
| **Local Storage** | SharedPreferences | Kiosk PIN hash, theme preference, session |

---

## API Documentation

### Database Schema (Supabase)

The app uses 6 Supabase tables. All queries use the **anon key** with Row-Level Security (RLS) policies scoping data per business.

#### `employees`

| Column | Type | Description |
|--------|------|-------------|
| `id` | `uuid PK` | Auto-generated |
| `phone` | `text` | Normalized Rwandan phone (e.g. `0788123456`) |
| `display_name` | `text` | Employee display name |
| `business_name` | `text` | Business/trade name |
| `pin_hash` | `text` | SHA-256(`normalizedPhone:pin`) |
| `role` | `text` | `owner` or `employee` |
| `created_by` | `text` | Phone of creator |
| `email` | `text?` | Optional email |
| `is_active` | `bool` | Account disabled flag |
| `created_at` | `timestamptz` | Default `now()` |

**Key queries:**
```dart
// Sign-in — exact phone match, verify PIN hash
supabase.from('employees').select().eq('phone', normalizedPhone).maybeSingle();

// Registration — insert new owner
supabase.from('employees').insert({ display_name, phone, pin_hash, business_name, ... });
```

#### `inventory_items`

| Column | Type | Description |
|--------|------|-------------|
| `id` | `uuid PK` | Auto-generated |
| `item_name` | `text` | Product name |
| `quantity` | `int4` | Current stock count |
| `cost_price` | `float8` | Unit cost price in RWF |
| `category` | `text?` | Product category |
| `subcategory` | `text?` | Product subcategory |
| `created_at` | `timestamptz` | Default `now()` |

**Key queries:**
```dart
// All inventory, sorted
supabase.from('inventory_items').select().order('item_name', ascending: true);

// Stock update
supabase.from('inventory_items').update({'quantity': newQuantity}).eq('id', id);
```

#### `sales`

| Column | Type | Description |
|--------|------|-------------|
| `id` | `uuid PK` | Auto-generated |
| `item_name` | `text` | Product name at time of sale |
| `quantity` | `int4` | Units sold |
| `sale_price` | `float8` | Sale price per unit in RWF |
| `cost_price` | `float8` | Cost price per unit (for profit calc) |
| `created_at` | `timestamptz` | Default `now()` |

**Key queries:**
```dart
// All sales, newest first
supabase.from('sales').select().order('created_at', ascending: false);

// Record sale
supabase.from('sales').insert({ item_name, quantity, sale_price, cost_price });
```

#### `customers`

| Column | Type | Description |
|--------|------|-------------|
| `id` | `uuid PK` | Auto-generated |
| `name` | `text` | Customer name |
| `phone` | `text?` | Contact phone |
| `email` | `text?` | Contact email |
| `amount` | `float8` | Outstanding debt amount in RWF |
| `total_paid` | `float8` | Cumulative payments received |
| `business_id` | `text?` | Scoping to business |
| `is_paid` | `bool?` | Payment status flag |
| `due_date` | `date?` | Expected repayment date |
| `created_at` | `timestamptz` | Default `now()` |

**Key queries:**
```dart
// All customers for a business
supabase.from('customers').select().eq('business_id', businessId).order('created_at', ascending: false);

// Record payment
supabase.from('customers').update({ 'amount': newAmount, 'total_paid': currentPaid + amount }).eq('id', id);
```

#### `debt_payments`

| Column | Type | Description |
|--------|------|-------------|
| `id` | `uuid PK` | Auto-generated |
| `customer_id` | `uuid FK` | References `customers.id` |
| `amount` | `float8` | Payment amount |
| `paid_at` | `timestamptz` | Default `now()` |

#### `app_settings`

| Column | Type | Description |
|--------|------|-------------|
| `id` | `uuid PK` | Auto-generated |
| `setting_key` | `text` | Config key (e.g. `daily_sales_target`) |
| `setting_value` | `text` | Config value (stored as string, parsed by app) |

---

## Security

### PIN Hashing (SHA-256)

Employee PINs are never stored in plaintext. The hash algorithm matches the existing React web implementation for cross-platform compatibility:

```dart
String hashPin(String pin, String phone) {
  final raw = '$phone:$pin';         // "0788123456:123456"
  final bytes = utf8.encode(raw);
  final digest = sha256.convert(bytes);
  return digest.toString();           // hex-encoded SHA-256
}
```

- PINs are 6 digits minimum
- Phone numbers are normalized (`0788xxxxxx` format) before hashing
- The phone acts as a salt, preventing rainbow-table attacks
- Hash is verified server-side (Supabase) but can be verified offline

### Kiosk Lockdown

- **Immersive mode**: `SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky)` hides system bars
- **Back-button interception**: All back navigation routes through kiosk lock screen
- **Admin PIN**: 6-digit SHA-256 hashed PIN stored in SharedPreferences
- **Orientation lock**: Portrait-up forced during kiosk mode
- **Session persistence**: Auth state survives app restart

### Supabase RLS

Row-Level Security policies should be configured per table:

```sql
-- Example: employees RLS policy
CREATE POLICY "Users can read own business employees"
  ON employees FOR SELECT
  USING (created_by = current_setting('app.employee_phone')::text);
```

---

## Scalability

### State Management (Riverpod)

- **Provider** — Singleton dependencies (Supabase client, repositories)
- **StateNotifierProvider** — Feature-level state with immutable updates
- **FutureProvider** — Async data fetching with automatic refresh
- All providers are lazily initialized and dispose automatically

### Routing (GoRouter)

- Declarative route definitions in `core/router.dart`
- Guarded redirects for unauthenticated access
- Shell route support for bottom-navigation layout
- Deep-linkable for future receipt URL sharing

---

## Deployment

### Prerequisites

```bash
# Install Flutter SDK (3.x)
# https://docs.flutter.dev/get-started/install

# Verify installation
flutter doctor

# Clone project
git clone https://github.com/hervekubanadev/trade-w-friend.git
cd trade-w-friend

# Install dependencies
flutter pub get
```

### Environment Configuration

Copy `.env.example` and configure your Supabase project:

```bash
cp .env.example .env
# Edit .env with your Supabase URL and anon key
```

### Android

```bash
# Debug APK
flutter build apk --debug

# Release APK (requires signing config in android/app/build.gradle)
flutter build apk --release

# App Bundle for Play Store
flutter build appbundle --release

# Output: build/app/outputs/flutter-apk/app-release.apk
```

### iOS

```bash
# Requires macOS + Xcode
flutter build ios --release

# Open in Xcode to archive and distribute
open ios/Runner.xcworkspace
```

### Web

```bash
# Static files output to build/web/
flutter build web --release

# Deploy to any static host (Vercel, Netlify, Supabase Hosting)
npx vercel deploy build/web
```

### Linux / macOS / Windows

```bash
flutter build linux --release   # Linux
flutter build macos --release   # macOS
flutter build windows --release # Windows
```

---

## Project Structure

```
lib/
├── main.dart                          # App entry, Supabase init
├── core/
│   ├── theme.dart                     # AppTheme (light/dark), AppColors
│   ├── router.dart                    # GoRouter configuration
│   ├── kiosk_manager.dart             # Kiosk mode singleton
│   ├── providers.dart                 # Global Riverpod providers
│   └── utils/
│       └── hash_utils.dart            # SHA-256 PIN hashing + phone normalization
├── features/
│   ├── auth/                          # Authentication (domain/data/application/presentation)
│   ├── dashboard/                     # Dashboard KPI cards and workspace grid
│   ├── inventory/                     # Inventory CRUD
│   ├── sales/                         # Sales recording and reports
│   ├── clients/                       # Customer management
│   ├── debts/                         # Debt tracking and ledgers
│   ├── kiosk/                         # Kiosk mode lock screen
│   └── settings/                      # Business profile and app settings
└── shared/
    ├── widgets/                       # Reusable NumPad, GlassCard, etc.
    └── utils/                         # Shared utility functions
```

### Architecture Pattern (per feature)

```
features/<feature>/
├── domain/          # Data models (immutable, with fromMap/toMap)
├── data/            # Repository implementations (Supabase queries)
├── application/     # Riverpod StateNotifiers
└── presentation/    # UI screens and widgets
```

---

## Roadmap

### ✅ Phase 1 — Core POS (Current)
- [x] Phone + 6-digit PIN authentication
- [x] Full-screen kiosk mode with admin lock
- [x] Inventory management (CRUD, stock status)
- [x] Sales recording with profit tracking
- [x] Customer management
- [x] Debt tracking and payment recording
- [x] 7-day sales reports with fl_chart
- [x] Dark/light theme support
- [x] Business profile settings + factory reset

### 🚀 Phase 2 — Fintech Foundations
- [ ] **Offline-first sync**: SQLite local cache with Supabase sync on reconnect
- [ ] **Multi-business support**: Business switching for multi-store owners
- [ ] **Barcode scanning**: Camera-based product lookup
- [ ] **Inventory categories**: Hierarchical categorization + bulk operations
- [ ] **Receipt printing**: Bluetooth thermal printer support
- [ ] **Export to CSV/PDF**: Sales reports and ledgers

### 💳 Phase 3 — Mobile Money & Payments
- [ ] **MTN MoMo API integration**: Direct mobile money collection
- [ ] **Airtel Money API integration**: Dual-wallet support
- [ ] **QR code payments**: Static merchant QR for customer scan-to-pay
- [ ] **Payment reconciliation**: Auto-match payments to sales records
- [ ] **Transaction SMS/email receipts**: Auto-delivered payment confirmations

### 🌍 Phase 4 — African Retail Infrastructure
- [ ] **Multi-currency support**: RWF, UGX, TZS, KES, XAF
- [ ] **Tax calculation**: VAT/NHIL for multiple jurisdictions
- [ ] **Supplier management**: Purchase orders and supplier ledgers
- [ ] **Employee time tracking**: Clock-in/out with shift management
- [ ] **Cloud dashboard**: Web-based analytics for business owners
- [ ] **Offline payments**: NFC/Bluetooth P2P for truly offline settlements

### Mobile Money Interoperability Vision

```
┌──────────────┐     ┌──────────────────┐     ┌──────────────────┐
│   MTN MoMo   │     │   Airtel Money   │     │   Tigo Cash      │
│   (Rwanda)    │     │   (Rwanda)       │     │   (Rwanda)       │
└──────┬───────┘     └────────┬─────────┘     └────────┬─────────┘
       │                      │                        │
       └──────────────────────┼────────────────────────┘
                              │
               ┌──────────────┴──────────────┐
               │   Unified Payment SDK        │
               │   (Riverpod Provider)         │
               └──────────────┬──────────────┘
                              │
               ┌──────────────┴──────────────┐
               │       TradeWFriend POS       │
               │   Sale → Payment → Receipt   │
               └─────────────────────────────┘
```

By abstracting mobile money operators behind a unified **PaymentProvider** (Riverpod), the system can switch between MTN MoMo, Airtel Money, or Tigo Cash without changing business logic. The architecture mirrors the M-Pesa Daraja API pattern for east African interoperability.

---

## Development

### Run Locally

```bash
# Development mode (hot reload)
flutter run

# Run on specific device
flutter run -d chrome    # Web
flutter run -d <device-id>  # Physical device or emulator

# Run tests
flutter test

# Analyze code
flutter analyze
```

### Code Quality

```bash
# Format
dart format lib/ test/

# Lint
flutter analyze

# Generate launcher icons
dart run flutter_launcher_icons
```

---

## Contributing

1. Fork the repository
2. Create your feature branch (`git checkout -b feat/amazing-feature`)
3. Commit with conventional commits (`feat:`, `fix:`, `docs:`, `refactor:`)
4. Push to the branch (`git push origin feat/amazing-feature`)
5. Open a Pull Request

---

## License

Distributed under the MIT License. See `LICENSE` for more information.

---

## Contact

**KUBANA Friend Herve** — [hervekubana.dev](https://hervekubana.dev)

Project Link: [https://github.com/hervekubanadev/trade-w-friend](https://github.com/hervekubanadev/trade-w-friend)

---

<div align="center">
  <sub>Built with ❤️ for Rwandan small businesses | Kigali, Rwanda</sub>
  <br>
  <sub>Part of the African fintech infrastructure revolution 🇷🇼</sub>
</div>
