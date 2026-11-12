# Aroel — client

The Flutter client. It lives in `mobile/` because the server lives in `backend/`.

## What is here

The auth module of milestone M1, on top of the Warm Paper design system:

- the three-step onboarding (`US-104`), every step skippable;
- sign-in and sign-up with email, Apple and Google (`US-101`, `US-102`);
- the session: a fifteen-minute access token, a refresh token that rotates on every use
  and a family that is revoked when a token is replayed (`US-103`);
- the account screen: the address, the display name, the timezone, the password, signing
  out and deleting everything (`US-105`, `US-106`).

The day record — the rating, the tags, the gratitude lines and the writing — is milestone
M2 and is not here yet. `lib/features/today/today_screen.dart` is the shell it will sit
in.

## Running it

```
flutter pub get
dart run build_runner build
dart format lib test
flutter run
```

`build_runner` writes the drift, freezed and json_serializable code. The generated files
are committed, so a plain `flutter pub get` is enough to build; run the generator after
changing a table, a model or a DTO, and let `dart format` have the last word over what it
writes.

### Where the server is

The client talks to `/v1` on the server. The address comes from the build:

```
flutter run --dart-define=AROEL_API_BASE_URL=https://localhost:5001/v1
```

Without it the app points at `https://10.0.2.2:5001/v1`, which is the host machine as
seen from the Android emulator.

### The identity providers

Apple and Google need their own identifiers, and the app says plainly when they are
missing rather than failing at the tap:

```
flutter run \
  --dart-define=AROEL_GOOGLE_CLIENT_ID=... \
  --dart-define=AROEL_GOOGLE_SERVER_CLIENT_ID=... \
  --dart-define=AROEL_APPLE_SERVICE_ID=...
```

## The rules the code keeps

- The account is optional. Local-only is the default, and no screen waits for an account.
- Signing up adopts the journal already on the device: the client sends the identifier it
  writes its rows under, and not one row is re-keyed.
- Identifiers are `uuid7` the device makes itself, and they keep their order.
- Tokens live in the keychain, never in the database.
- Writing never waits for the network.

## The layers

```
lib/app       the router, the theme, the bootstrap and the wiring
lib/core      the models, the ports, the shared state and the rules that hold
lib/data      drift, dio, the keychain and the adapters that implement the ports
lib/features  the screens: auth, settings, today
lib/ui        the design system: the palette, the type roles and the widgets
```

The arrows only point one way. `core` knows nothing below it; `data` knows `core`; the
features know `core` and `ui`; the app knows everything and wires it at launch.

## Tests

```
flutter analyze
flutter test
```

The tests are the regression net for the invariants above: `test/data` holds the account
rules, `test/features` holds the screens, `test/ui` holds the rating control.
