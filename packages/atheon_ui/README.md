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

# Atheon UI: Flutter Components & Tracking

A specialized Flutter package for rendering Atheon Ad Units with built-in telemetry, automated keyword injection, and Markdown support.

## Features

- **Automated Injection:** Injects ad tokens into raw strings based on keyword matching.
- **Built-in Telemetry:** Automatically tracks impressions (350ms dwell-time) and clicks.
- **Platform Awareness:** Auto-generates correct `X-Atheon-Origin` headers for iOS, Android, Web, and Desktop.
- **Markdown Support:** Seamlessly integrates with `flutter_markdown_plus`.

## Getting Started

### 1. Wrap your app

Initialize the global configuration at the root of your app:

```dart
Atheon(
  publisherKey: 'your_pub_key',
  child: MyApp(),
)
```

### 2. Use the Container

Use `AtheonContainer` to display content. It handles the injection logic and tracking automatically.

```dart
AtheonContainer(
  content: "This is my content featuring a keyword.",
  dataAtheon: atheonJsonData, // The raw ad data from the API
  builder: (context, tokenizedContent, ads, onAdClick) {
    // Return your preferred renderer (Standard Text, Markdown, etc.)
    return MarkdownBody(
      data: tokenizedContent,
      builders: {
        'atheon_ad_unit': AtheonMarkdownBuilder(ads: ads, onAdClick: onAdClick),
      },
      inlineSyntaxes: [AtheonMarkdownSyntax()],
    );
  },
)
```

## Security: Tamper Detection

`AtheonUI` includes a global tamper signal. If the ad rendering logic is bypassed or modified unexpectedly, you can trigger:

```dart
AtheonContainer.reportTamper();
```

This will fire a security event to the Atheon Gateway for auditing.

## Dependencies

* `visibility_detector`: For impression tracking.
* `flutter_svg`: For rendering the Atheon Ad Chip.
* `device_info_plus`: For platform attribution.
