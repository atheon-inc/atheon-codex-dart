# Atheon Codex Dart & Flutter Monorepo

This repository contains the official Dart SDK and Flutter UI widgets for interacting with the [Atheon Gateway Service](https://gateway.atheon.ad).

## Packages

| Package | Description |
| :--- | :--- |
| [**atheon_codex**](./packages/atheon_codex) | Core Dart SDK for API integration. |
| [**atheon_ui**](./packages/atheon_ui) | Flutter UI components and automated ad injection. |

## Monorepo Structure

This project is organized using a package-based monorepo structure:
- `/packages/atheon_codex`: The logic-only Dart wrapper for the Atheon API.
- `/packages/atheon_ui`: Flutter-specific widgets, injection engines, and telemetry.

## Publishing

Packages are published independently to [pub.dev](https://pub.dev) via GitHub Actions based on tag prefixes:
- Tags matching `codex-v*.*.*` trigger the **atheon_codex** release.
- Tags matching `ui-v*.*.*` trigger the **atheon_ui** release.

## License

This project is licensed under the **Apache License 2.0**. See the [LICENSE](LICENSE) file for details.
