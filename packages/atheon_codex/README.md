## Legacy Notice – February 2026

This snapshot (`legacy-archive-1`) preserves the original **Ads in LLM** codebase prior to our strategic refocus in February 2026.

### The Strategic Pivot

After a year in the market, we successfully validated our core technology and saw promising early traction. However, **we** realized that widespread user readiness for ad-integrated AI experiences is still evolving. During this period, we observed that our users were primarily utilizing **Atheon** as an analytics suite to understand AI traffic patterns.

To meet this immediate market demand, we have shifted our primary focus to **Analytics for AI Traffic**. This allows us to provide high-value tooling for developers today, while maintaining the underlying architecture to re-enable **the** ad-tech as the ecosystem matures.

### What This Means

* **Status:** This is a permanent, read-only snapshot of the codebase as of February 2026.
* **Purpose:** Preserved for historical reference, audit trails, and future retrieval of ad-serving logic.
* **Active Development:** All current work on the Atheon Analytics platform is located on the `main` branch.

*We are incredibly proud of the groundwork established here; it remains the technical foundation for everything we are building next.*

---

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
