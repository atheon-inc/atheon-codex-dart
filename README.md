# Codex: Dart & Flutter SDK for Atheon

The Atheon Codex Dart library provides convenient access to the Atheon Gateway Ad Service from Dart and Flutter environments. The library includes type definitions, works across all platforms (Mobile, Web, Desktop, Server), and offers idiomatic async/await APIs.

## Installation

Run this command:

With Dart:

```sh
dart pub add atheon_codex
```

With Flutter:

```sh
flutter pub add atheon_codex
```

This will add a line like this to your package's `pubspec.yaml` (and run an implicit `dart pub get`):

```yaml
dependencies:
  atheon_codex: ^0.1.0
```

## Usage

```dart
import 'package:atheon_codex/codex.dart';
import 'dart:io' show Platform;

Future<void> main() async {
  // Initialize client
  final client = AtheonCodexClient(
    AtheonCodexClientOptions(
      apiKey: Platform.environment['ATHEON_CODEX_API_KEY'] ?? 'YOUR_API_KEY',
    ),
  );

  String? content;

  try {
    // Create payload
    final payload = AtheonUnitFetchAndIntegrateModel(
      query: "Your user prompt/ad query goes here.",
      baseContent: "insert the llm response generated from your application as the base content",
      includeAdUnits: true,
      // useUserIntentAsFilter: false,
    );

    // Fetch and Integrate atheon unit
    final response = await client.fetchAndIntegrateAtheonUnit(payload);
    
    // Parse response
    if (response != null && response['response_data'] != null) {
      content = response['response_data']['integrated_content'];
    }
  } catch (e) {
    print("Error fetching and integrating atheon unit: $e");
  } finally {
    client.close();
  }

  print("Content with Atheon Unit: $content");
}
```

> **Note:** _You can enable monetization through [Atheon Gateway Dashboard](https://gateway.atheon.ad) under project settings._

While you can provide an `apiKey` keyword argument directly, we recommend using [flutter_dotenv](https://pub.dev/packages/flutter_dotenv) (for Flutter) or [dotenv](https://pub.dev/packages/dotenv) (for Dart server/CLI) to read `ATHEON_CODEX_API_KEY="My Eon API Key"` from your `.env` file so that your API Key is not stored in source control.

## License

This SDK is licensed under the **Apache License 2.0**. See [LICENSE](LICENSE) for details.
