<div align="center">
  <h1>TradeWFriend · Kiosk POS</h1>
  <p><strong>Full-screen kiosk business management system for Rwandan SMBs</strong></p>
  <p>
    <img src="https://img.shields.io/badge/Flutter-02569B" alt="Flutter">
    <img src="https://img.shields.io/badge/Supabase-FF4438" alt="Supabase">
    <img src="https://img.shields.io/badge/Riverpod-7B1FA2" alt="Riverpod">
    <img src="https://img.shields.io/badge/Dart-0175C2" alt="Dart">
    <img src="https://img.shields.io/badge/Platform-Android_iOS_Web-6DB33F" alt="Multi-platform">
  </p>
</div>

---

## Overview

TradeWFriend is a Flutter-based kiosk management system designed for small retail businesses in Rwanda. It operates as a full-screen, PIN-protected kiosk app that provides inventory tracking, point-of-sale, debt management, and sales analytics — all optimized for tablet-based storefront kiosks.

---

## Architecture

```
┌─────────────────────────────────────────────────┐
│              Flutter + Riverpod                   │
│  ┌──────────┐ ┌──────┐ ┌────────┐ ┌─────────┐   │
│  │ Auth     │ │Sales │ │Inventory│ │  Debts   │   │
│  └────┬─────┘ └──┬───┘ └───┬────┘ └────┬────┘   │
│       │          │         │           │         │
│    ┌──┴──────────┴─────────┴───────────┴──┐      │
│    │       Supabase Client                 │      │
│    └────────────────┬──────────────────────┘      │
└─────────────────────┼────────────────────────────┘
                      │
              ┌───────┴───────┐
              │   Supabase     │
              │ PostgreSQL + DB│
              └───────────────┘
```

### Tech Stack

| Layer | Technology |
|-------|-----------|
| **Frontend** | Flutter 3.x, Dart 3.12+ |
| **State Management** | Riverpod (StateNotifier + FutureProvider) |
| **Routing** | GoRouter |
| **Backend** | Supabase (PostgreSQL) |
| **Charts** | fl_chart |
| **Local Storage** | SharedPreferences |
| **Security** | SHA-256 PIN hashing |
| **Targets** | Android, iOS, Linux, macOS, Web, Windows |

---

## Features

### 🔐 PIN-Based Authentication
- Phone + 6-digit PIN sign-in/registration
- SHA-256 hashed PINs for security (matches existing React implementation)
- Persistent session management

### 📊 Dashboard
- Revenue, debt, inventory value, and today's revenue KPI cards
- Quick-access workspace grid (3x2 layout)
- Real-time data from Supabase

### 📦 Inventory Management
- Product listing with search
- Stock status badges (In Stock / Low Stock / Out of Stock)
- Add products via bottom sheet or full-page form
- Cost price tracking

### 💳 Sales Recording
- Product search and selection with quantity
- Optional sale price override
- Automatic profit calculation

### 📈 Sales Reports
- Total revenue display
- 7-day bar chart visualization
- Daily breakdown of sales vs. unpaid amounts

### 👥 Client Management
- Add and manage customer profiles
- Outstanding debt balances
- Payment recording against debts

### 💰 Debt & Ledgers
- Comprehensive debt overview
- Individual customer ledger tracking
- Payment history

### 🔒 Kiosk Mode
- Full-screen immersive mode (hides system UI)
- 6-digit admin PIN lock/unlock
- Back-button interception to lock screen

### ⚙️ Settings
- Business profile management
- Theme toggle (Light / Dark / System)
- Factory reset option

---

## Getting Started

### Prerequisites

- [Flutter SDK](https://flutter.dev) 3.x
- [Supabase](https://supabase.com) project

### Setup

```bash
# Clone the repository
git clone https://github.com/hervekubanadev/trade-w-friend.git
cd trade-w-friend

# Install dependencies
flutter pub get

# Configure Supabase
# Update Supabase URL and anon key in lib/main.dart

# Run the app
flutter run
```

### Supabase Configuration

Update the Supabase connection details in `lib/main.dart`:

```dart
await Supabase.initialize(
  url: 'https://your-project.supabase.co',
  anonKey: 'your-anon-key',
);
```

### Database Tables

Create the following tables in your Supabase project:

- **employees** — Phone-based auth with PIN hash
- **inventory_items** — Product catalog with pricing
- **sales** — Transaction records
- **customers** — Client profiles
- **debt_payments** — Payment tracking
- **app_settings** — Business configuration and daily counters

---

## Project Structure

```
lib/
├── main.dart                    # App entry, Supabase init
├── core/
│   ├── theme.dart               # AppTheme (light/dark), AppColors
│   ├── router.dart              # GoRouter configuration
│   ├── kiosk_manager.dart       # Kiosk mode singleton
│   └── providers.dart           # Global Riverpod providers
├── features/
│   ├── auth/                    # Authentication (domain/data/application/presentation)
│   ├── dashboard/               # Dashboard KPI cards and workspace grid
│   ├── inventory/               # Inventory CRUD
│   ├── sales/                   # Sales recording and reports
│   ├── clients/                 # Customer management
│   ├── debts/                   # Debt tracking and ledgers
│   ├── kiosk/                   # Kiosk mode settings and lock screen
│   └── settings/                # Business profile and app settings
└── shared/
    ├── widgets/                 # Reusable components (NumPad, GlassCard, etc.)
    └── utils/                   # Utility functions
```

### Architecture Pattern

Feature-first organization with clean architecture layers:
- **domain/** — Data models
- **data/** — Repository implementations (Supabase queries)
- **application/** — State notifiers (Riverpod)
- **presentation/** — UI screens and widgets

---

## Roadmap

- [x] PIN-based authentication
- [x] Inventory management
- [x] Sales recording with profit tracking
- [x] Client management and debt tracking
- [x] Kiosk mode with admin lock
- [x] Dark/light theme support
- [ ] Offline-first with local caching
- [ ] Payment gateway integration (mobile money)
- [ ] Barcode scanning
- [ ] Multi-business support
- [ ] Receipt printing
- [ ] Inventory categories and bulk operations

---

## License

Distributed under the MIT License. See `LICENSE` for more information.

---

## Contact

**KUBANA Friend Herve** - [hervekubana.dev](https://hervekubana.dev)

Project Link: [https://github.com/hervekubanadev/trade-w-friend](https://github.com/hervekubanadev/trade-w-friend)

---

<div align="center">
  <sub>Built with ❤️ for Rwandan small businesses | Kigali, Rwanda</sub>
</div>
