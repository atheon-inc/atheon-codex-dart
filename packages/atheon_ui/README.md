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
