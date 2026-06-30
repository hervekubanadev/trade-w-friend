# Contributing to TradeWFriend

## Flutter Setup

```bash
# Install Flutter SDK (channel stable, 3.x)
# https://docs.flutter.dev/get-started/install

# Verify installation
flutter doctor

# Clone and install
git clone https://github.com/hervekubanadev/trade-w-friend.git
cd trade-w-friend

# Install dependencies
flutter pub get

# Copy environment config
cp .env.example .env
# Edit .env with your Supabase credentials
```

## Code Style

- Follow the [Dart style guide](https://dart.dev/guides/language/effective-dart/style)
- Use `dart format` before committing: `dart format lib/ test/`
- Prefer `const` constructors where possible
- Use Riverpod idioms: `ref.watch` for reactivity, `ref.read` for one-shot actions
- Keep feature code encapsulated — each feature owns its domain/data/application/presentation layers
- Name files with snake_case, classes with PascalCase
- Use relative imports within feature boundaries; package: imports for cross-feature references

## Commit Convention

Use [Conventional Commits](https://www.conventionalcommits.org/):

```
feat: add barcode scanning to inventory
fix: correct debt payment calculation overflow
docs: update API.md with new endpoint
refactor: extract KpiCard to shared widgets
chore: upgrade supabase_flutter to 2.8.1
```

## Testing

```bash
# Run all tests
flutter test

# Run with coverage
flutter test --coverage

# Run a specific test file
flutter test test/features/auth/auth_repository_test.dart
```

- Write unit tests for repositories and notifiers
- Use `MockSupabaseClient` from `supabase_flutter` test utilities
- Prefer pure Dart unit tests over widget tests for business logic
- Widget tests should use `ProviderScope` overrides for Riverpod providers

## Pull Request Workflow

1. Fork the repo and create a branch from `main`
2. Make your changes with conventional commit messages
3. Ensure `flutter analyze` passes with zero issues
4. Ensure `flutter test` passes and coverage is maintained
5. Update docs if public APIs change
6. Open a PR against `main` with a clear description

## Review Process

- At least one maintainer approval is required
- All CI checks must pass (analyze, test, build)
- New features should include tests
- Bug fixes should include a regression test
