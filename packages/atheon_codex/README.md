# Atheon Codex: Core Dart SDK

The `atheon_codex` library provides low-level access to the Atheon Gateway Ad Service. It is platform-agnostic and works across Mobile, Web, Desktop, and Server environments.

## Installation

```sh
dart pub add atheon_codex
```

## Usage

```dart
import 'package:atheon_codex/codex.dart';

Future<void> main() async {
  final client = AtheonCodexClient(
    AtheonCodexClientOptions(apiKey: 'YOUR_API_KEY'),
  );

  try {
    final payload = AtheonUnitFetchAndIntegrateModel(
      query: "User prompt here",
      baseContent: "Generated LLM response",
      includeAdUnits: true,
    );

    final response = await client.fetchAndIntegrateAtheonUnit(payload);
    print("Integrated Content: ${response['response_data']['integrated_content']}");
  } finally {
    client.close();
  }
}
```

> Note: For Flutter applications requiring UI components and automated tracking, use [atheon_ui](https://pub.dev/packages/atheon_ui).
