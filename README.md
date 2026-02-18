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
