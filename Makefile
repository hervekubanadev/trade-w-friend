.PHONY: analyze test build-apk build-web build-ios clean format setup

analyze:
	flutter analyze

test:
	flutter test

test-coverage:
	flutter test --coverage

build-apk:
	flutter build apk --release

build-appbundle:
	flutter build appbundle --release

build-web:
	flutter build web --release

build-ios:
	flutter build ios --release

build-macos:
	flutter build macos --release

clean:
	flutter clean
	rm -rf coverage/

format:
	dart format lib/ test/

setup:
	flutter pub get
	cp -n .env.example .env || true
	dart run flutter_launcher_icons
