# Architecture

## Overview

TradeWFriend follows a **feature-first, clean architecture** pattern optimized for Flutter's widget-tree paradigm. Each feature is self-contained with its own domain models, data access, state management, and presentation layer.

---

## Principles

1. **Feature encapsulation** — Each feature folder owns its complete slice of functionality
2. **Unidirectional data flow** — UI → Event → Notifier → Repository → Supabase
3. **Dependency injection** — All dependencies wired through Riverpod providers
4. **Immutable state** — StateNotifier emits new state objects; no mutation
5. **Repository pattern** — Data sources abstracted behind repository interfaces

---

## Layer Architecture

### 1. Presentation Layer (`presentation/`)

Flutter widgets and screens. StatelessWidgets read state via `ref.watch()`, emit events via `ref.read()`.

```
presentation/
├── auth_screen.dart
├── dashboard_screen.dart
├── kiosk_lock_screen.dart
└── widgets/           # Feature-specific widgets (e.g., KpiCard, StockBadge)
```

**Rules:**
- No direct Supabase calls in widgets
- No business logic outside notifiers
- Widgets rebuild only when watched provider emits a new state

### 2. Application Layer (`application/`)

Riverpod StateNotifiers that orchestrate business logic.

```
application/
├── auth_notifier.dart
├── dashboard_notifier.dart
├── inventory_notifier.dart
├── sales_notifier.dart
└── debt_notifier.dart
```

**Responsibilities:**
- Transform repository data into display-ready state
- Handle loading, error, and empty states
- Coordinate between multiple repositories (e.g., sale record → inventory decrement)

### 3. Data Layer (`data/`)

Repository classes wrapping Supabase queries.

```
data/
├── auth_repository.dart
├── dashboard_repository.dart
├── inventory_repository.dart
├── sales_repository.dart
├── client_repository.dart
└── debt_repository.dart
```

**Responsibilities:**
- Execute Supabase `from().select()/insert()/update()/delete()` calls
- Map JSON responses to domain models via `fromMap()`
- Handle Supabase errors gracefully (return `[]` or fallback defaults)

### 4. Domain Layer (`domain/`)

Immutable data models with serialization.

```
domain/
├── auth_profile.dart
├── inventory_item.dart
├── sale_item.dart
├── daily_report.dart
├── client.dart
├── customer_ledger.dart
└── dashboard_stats.dart
```

**Characteristics:**
- No dependency on Flutter or Supabase
- Pure Dart classes with `fromMap()` factory constructors
- Computed properties for derived data (e.g., `remainingDebt`, `totalProfit`)

---

## State Management (Riverpod)

### Provider Hierarchy

```
supabaseClientProvider (Provider<SupabaseClient>)
    │
    ├── authRepositoryProvider (Provider<AuthRepository>)
    │       └── currentProfileProvider (StateProvider<AuthProfile?>)
    │
    ├── inventoryRepositoryProvider (Provider<InventoryRepository>)
    │       └── inventoryListProvider (FutureProvider<List<InventoryItem>>)
    │
    ├── salesRepositoryProvider (Provider<SalesRepository>)
    │       └── salesListProvider (FutureProvider<List<SaleItem>>)
    │
    ├── dashboardRepositoryProvider (Provider<DashboardRepository>)
    │       └── dashboardStatsProvider (FutureProvider<DashboardStats>)
    │
    ├── clientRepositoryProvider (Provider<ClientRepository>)
    │
    └── debtRepositoryProvider (Provider<DebtRepository>)
```

### Data Flow

```
┌──────────┐     ┌──────────────┐     ┌────────────┐     ┌──────────┐
│  Widget   │────>│  Notifier    │────>│ Repository  │────>│Supabase  │
│ (ref.read)│     │ (Action)     │     │ (Query)     │     │ (DB)     │
└──────────┘     └──────────────┘     └────────────┘     └──────────┘
      ▲                  │                                       │
      │                  │                                       │
      └──────────────────┴───────────────────────────────────────┘
                  (ref.watch → rebuild)
```

---

## Routing (GoRouter)

```
/auth                  → AuthScreen (initial)
/dashboard             → DashboardScreen (post-auth)
/inventory             → InventoryScreen
/inventory/add         → AddProductScreen
/reports               → SalesReportScreen
/sales/new             → RecordSaleScreen
/debts                 → DebtsScreen
/clients               → ClientsScreen
/settings              → SettingsScreen
/kiosk-settings        → KioskSettingsScreen
```

Route guards redirect unauthenticated users to `/auth`. Kiosk mode interceptor locks all routes when kiosk is locked.

---

## Kiosk Mode

```
┌─────────────────────────────────────────────┐
│  KioskManager (Singleton)                    │
│  │                                           │
│  ├── init()       → Restore state from prefs │
│  ├── enable()     → immersiveSticky + lock   │
│  ├── disable()    → edgeToEdge + unlock      │
│  ├── lock()       → _locked = true           │
│  ├── unlock()     → _locked = false          │
│  └── verifyPin()  → SHA-256 compare          │
└─────────────────────────────────────────────┘
```

The `KioskManager` is a singleton initialized in `main.dart` before app startup. It persists state via `SharedPreferences` and hooks into `SystemChrome` for immersive mode.

---

## Security Architecture

### PIN Flow

```
User Input (phone + 6-digit PIN)
        │
        ▼
normalizePhone(phone) → "0788xxxxxx"
        │
        ▼
hash = SHA-256("0788xxxxxx:123456")
        │
        ▼
supabase.from('employees')
    .select('pin_hash')
    .eq('phone', normalizedPhone)
    .single()
        │
        ▼
Compare hash === stored.pin_hash
```

### Kiosk PIN Flow (local)

```
User sets admin PIN
        │
        ▼
SHA-256(pin) → stored in SharedPreferences
        │
        ▼
On lock/unlock: hash input → compare → allow/disallow
```

---

## Performance Considerations

- **Riverpod auto-dispose**: Providers clean up when no longer watched
- **Lazy Supabase queries**: Data fetched only when screen is active
- **Immutable state**: `==` operator override enables efficient rebuild detection
- **const constructors**: Widgets prefer `const` for minimal rebuild cost
- **List views**: `ListView.builder` for inventory/product lists (lazy rendering)

---

## Testing Strategy

```
test/
├── widget_test.dart            # Basic widget smoke test
├── features/
│   ├── auth/
│   │   ├── auth_repository_test.dart
│   │   └── auth_notifier_test.dart
│   ├── inventory/
│   │   ├── inventory_repository_test.dart
│   │   └── inventory_notifier_test.dart
│   └── ...
└── shared/
    └── utils/
        └── hash_utils_test.dart
```

- **Unit tests**: Repository and domain model tests (fast, no Flutter)
- **Widget tests**: Screen rendering with mocked providers
- **Integration tests**: Full flow (auth → dashboard → sale) with test Supabase
