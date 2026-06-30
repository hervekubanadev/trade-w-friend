# Security Policy

## PIN Hashing

TradeWFriend uses SHA-256 with phone-number salting for employee authentication:

```dart
String hashPin(String pin, String phone) {
  final raw = '$phone:$pin';         // e.g. "0788123456:123456"
  final bytes = utf8.encode(raw);
  final digest = sha256.convert(bytes);
  return digest.toString();
}
```

- PINs are **never stored in plaintext** — only the SHA-256 hash is persisted
- The phone number acts as a unique salt, preventing rainbow-table precomputation
- Hash verification happens server-side via Supabase `employees.pin_hash`
- Offline verification is supported for kiosk admin unlock
- Minimum PIN length: 6 digits

## Kiosk Security Model

The kiosk mode provides a locked-down retail terminal:

- **Immersive mode**: `SystemUiMode.immersiveSticky` hides system navigation bars — users cannot exit the app without the admin PIN
- **Back-button interception**: Android back navigation routes through the kiosk lock screen, preventing unauthorized exit
- **Admin PIN unlock**: A separate 6-digit SHA-256 hashed PIN stored in `SharedPreferences` controls kiosk lock/unlock
- **Orientation lock**: Portrait-up locked during kiosk mode
- **Session persistence**: Auth tokens survive app restart so the kiosk resumes without re-authentication

## Data Protection

- **Supabase Row-Level Security (RLS)**: All queries are scoped per business via `employee_phone` session context
- **No secrets in source**: API keys are injected via `.env` (excluded from version control)
- **Minimal local storage**: Only kiosk PIN hash and theme preference stored in `SharedPreferences` — all business data lives in Supabase
- **Network security**: All Supabase traffic uses TLS; API calls authenticated with anon key (restricted by RLS)

## Reporting a Vulnerability

Contact the maintainers directly at the project repository. Do not file public issues for security vulnerabilities.
