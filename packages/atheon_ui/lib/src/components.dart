import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:atheon_ui/ui.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:http/http.dart' as http;
import 'package:uuid/uuid.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:visibility_detector/visibility_detector.dart';
import 'package:package_info_plus/package_info_plus.dart';

class AtheonData extends InheritedWidget {
  final String publisherKey;
  final String appId;
  final String origin;
  final http.Client client;

  const AtheonData({
    super.key,
    required this.publisherKey,
    required this.appId,
    required this.origin,
    required this.client,
    required super.child,
  });

  @override
  bool updateShouldNotify(AtheonData oldWidget) {
    return oldWidget.publisherKey != publisherKey ||
        oldWidget.appId != appId ||
        oldWidget.origin != origin ||
        oldWidget.client != client;
  }
}

class Atheon extends StatefulWidget {
  final String publisherKey;

  final String? appId;
  final Widget child;

  const Atheon({
    super.key,
    required this.publisherKey,
    this.appId,
    required this.child,
  });

  static AtheonData? of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<AtheonData>();
  }

  @override
  State<Atheon> createState() => _AtheonState();
}

class _AtheonState extends State<Atheon> {
  late final http.Client _httpClient;

  String _resolvedAppId = "pending-detection";
  late String _derivedOrigin;

  @override
  void initState() {
    super.initState();

    _httpClient = http.Client();
    _derivedOrigin = _constructOrigin(_resolvedAppId);
    _fetchPackageInfo();
  }

  @override
  void dispose() {
    _httpClient.close();
    super.dispose();
  }

  Future<void> _fetchPackageInfo() async {
    String appId;

    if (widget.appId != null) {
      appId = widget.appId!;
    } else {
      try {
        final info = await PackageInfo.fromPlatform();
        appId = info.packageName;
      } catch (e) {
        AtheonLogger.error(
          "Failed to detect Package Name. Using default name.",
          e,
        );
        appId = "unknown-app";
      }
    }

    if (!mounted) return;

    _derivedOrigin = _constructOrigin(_resolvedAppId);

    if (appId != _resolvedAppId) {
      setState(() {
        _resolvedAppId = appId;
        _derivedOrigin = _constructOrigin(appId);
      });
    }
  }

  String _constructOrigin(String appId) {
    String prefix = "desktop";
    if (kIsWeb) {
      prefix = "web";
    } else {
      switch (defaultTargetPlatform) {
        case TargetPlatform.android:
          prefix = "android";
          break;
        case TargetPlatform.iOS:
          prefix = "ios";
          break;
        case TargetPlatform.macOS:
        case TargetPlatform.windows:
        case TargetPlatform.linux:
        case TargetPlatform.fuchsia:
          prefix = "desktop";
          break;
      }
    }
    return "$prefix-atheon://$appId";
  }

  @override
  Widget build(BuildContext context) {
    return AtheonData(
      publisherKey: widget.publisherKey,
      appId: _resolvedAppId,
      origin: _derivedOrigin,
      client: _httpClient,
      child: widget.child,
    );
  }
}

class AtheonAdChip extends StatelessWidget {
  final String text;
  final VoidCallback onTap;
  final TextStyle? style;

  const AtheonAdChip({
    super.key,
    required this.text,
    required this.onTap,
    this.style,
  });

  @override
  Widget build(BuildContext context) {
    final len = text.length;
    final partLen = (len / 3).floor();
    final remainder = len % 3;

    final p1End = partLen + (remainder == 2 ? 1 : 0);
    final p2End = p1End + partLen + (remainder >= 1 ? 1 : 0);

    final p1 = text.substring(0, p1End);
    final p2 = text.substring(p1End, p2End);
    final p3 = text.substring(p2End);

    final baseStyle = style ?? DefaultTextStyle.of(context).style;
    final linkStyle = baseStyle.copyWith(fontWeight: FontWeight.w500);

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final armColor = isDark ? "white" : "black";
    final uid = "grad_${text.hashCode}_${Random().nextInt(10000)}";

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: Text.rich(
          TextSpan(
            children: [
              WidgetSpan(
                alignment: PlaceholderAlignment.middle,
                child: Padding(
                  padding: const EdgeInsets.only(right: 4.0),
                  child: SvgPicture.string(
                    _getSvgContent(armColor, uid),
                    width: 13,
                    height: 13,
                  ),
                ),
              ),
              TextSpan(
                text: p1,
                style: linkStyle.copyWith(color: const Color(0xFF067FF3)),
              ),
              TextSpan(
                text: p2,
                style: linkStyle.copyWith(color: const Color(0xFFF9800C)),
              ),
              TextSpan(
                text: p3,
                style: linkStyle.copyWith(color: const Color(0xFF07B682)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  static String _getSvgContent(String armColor, String uid) {
    return '''
<svg width="15" height="15" viewBox="0 0 24 24" fill="none" xmlns="http://www.w3.org/2000/svg">
  <path d="M0.227 20.705a5.444 5.444 0 0 0 4.745-2.858l4.48-8.13L7.67 6.613.03 20.368a.227.227 0 0 0 .198.337z" fill="#067ff3"/>
  <path d="M16.003 13.074l-2.747 1.361 1.944 3.39a5.697 5.682-.012 0 0 4.935 2.869.19.19 0 0 0 .165-.286z" fill="#07b682"/>
  <path d="M7.99 14.555L6.2 17.872a.03.03 0 0 0 .04.042l17.744-8.798a.03.03 0 0 0-.022-.055l-11.67 3.765-3.851 1.344a.819.819 0 0 0-.451.385z" fill="url(#$uid)"/>
  <path d="M10.011 3.3a.683.681-.012 0 0-.733.339L8.19 5.603l4.137 7.212 2.964-.956-4.825-8.234a.683.681-.012 0 0-.455-.324z" fill="$armColor"/>
  <defs>
    <linearGradient id="$uid" x1="0" y1="0" x2="24" y2="0" gradientUnits="userSpaceOnUse">
      <stop stop-color="#f7cd1b"/>
      <stop offset="1" stop-color="#f9800c"/>
    </linearGradient>
  </defs>
</svg>
''';
  }
}

typedef AtheonContentBuilder =
    Widget Function(
      BuildContext context,
      String tokenizedContent,
      List<AtheonConfig> ads,
      Function(String url) onAdClick,
    );

class AtheonContainer extends StatefulWidget {
  final String content;
  final dynamic dataAtheon;
  final AtheonContentBuilder builder;

  static final ValueNotifier<bool> _globalTamperSignal = ValueNotifier(false);
  static bool _tamperEventSent = false;
  static void reportTamper() {
    if (!_globalTamperSignal.value) {
      _globalTamperSignal.value = true;
    }
  }

  const AtheonContainer({
    super.key,
    required this.content,
    required this.dataAtheon,
    required this.builder,
  });

  @override
  State<AtheonContainer> createState() => _AtheonContainerState();
}

class _AtheonContainerState extends State<AtheonContainer> {
  List<AtheonConfig> _data = [];
  String _processedContent = "";

  final Set<int> _firedClicks = {};
  final Set<int> _firedImpressions = {};

  bool _initialized = false;
  Timer? _reRenderTimer;
  bool _isConfigLocked = false;
  Timer? _dwellTimer;

  Map<String, String>? _clientInfo;

  String? _publisherKey;
  String? _originHeader;
  http.Client? _client;

  late final Key _visibilityKey;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    final config = Atheon.of(context);

    if (config != null) {
      _publisherKey = config.publisherKey;
      _originHeader = config.origin;
      _client = config.client;
    } else {
      AtheonLogger.warn(
        "AtheonContainer missing Atheon ancestor. Tracking requests will fail.",
      );
    }
  }

  @override
  void initState() {
    super.initState();

    if (_initialized) return;
    _initialized = true;

    _visibilityKey = Key('atheon-container-${const Uuid().v4()}');

    AtheonContainer._globalTamperSignal.addListener(_handleGlobalTamper);

    _getClientInfo().then((info) {
      if (mounted) {
        setState(() => _clientInfo = info);
        if (AtheonContainer._globalTamperSignal.value) {
          _handleGlobalTamper();
        }
        _checkImpressions();
      }
    });

    _loadAtheonData();
    _injectAdDecoration();
  }

  @override
  void dispose() {
    _dwellTimer?.cancel();
    _reRenderTimer?.cancel();
    AtheonContainer._globalTamperSignal.removeListener(_handleGlobalTamper);
    super.dispose();
  }

  void _handleGlobalTamper() {
    if (!AtheonContainer._globalTamperSignal.value) return;
    if (_clientInfo == null) return;
    if (AtheonContainer._tamperEventSent) return;

    // Claim the lock immediately
    AtheonContainer._tamperEventSent = true;

    _fireEvent(AtheonConstants.EVENT_TYPE['TAMPER']!, null);
  }

  @override
  void didUpdateWidget(AtheonContainer oldWidget) {
    super.didUpdateWidget(oldWidget);

    try {
      final rawData = jsonEncode(widget.dataAtheon);
      final oldRaw = jsonEncode(oldWidget.dataAtheon);

      // 1. Reload config if data changed
      if (rawData != oldRaw) {
        _loadAtheonData();
        _injectAdDecoration();
      }
      // 2. Re-inject if content changed (Debounced)
      else if (widget.content != oldWidget.content) {
        if (_reRenderTimer != null) _reRenderTimer!.cancel();
        _reRenderTimer = Timer(const Duration(milliseconds: 50), () {
          if (mounted) _injectAdDecoration();
        });
      }
    } catch (e) {
      AtheonLogger.error("Update failed", e);
    }
  }

  String _getSessionId() {
    return const Uuid().v4();
  }

  Future<Map<String, String>> _getClientInfo() async {
    final deviceInfo = DeviceInfoPlugin();
    String browser = "Unknown";
    String os = "Unknown";
    String device = "Unknown";

    try {
      if (kIsWeb) {
        final info = await deviceInfo.webBrowserInfo;
        browser = info.browserName.name;
        os = info.platform ?? "Web";
        device = "web";
      } else {
        switch (defaultTargetPlatform) {
          case TargetPlatform.android:
            final info = await deviceInfo.androidInfo;
            os = "Android ${info.version.release}";
            device = "mobile";
            browser = "Flutter App (Android)";
            break;
          case TargetPlatform.iOS:
            final info = await deviceInfo.iosInfo;
            os = "iOS ${info.systemVersion}";
            device = "mobile";
            browser = "Flutter App (iOS)";
            break;
          case TargetPlatform.macOS:
            final info = await deviceInfo.macOsInfo;
            os = "macOS ${info.osRelease}";
            device = "desktop";
            break;
          case TargetPlatform.windows:
            final info = await deviceInfo.windowsInfo;
            if (info.buildNumber >= 22000) {
              os = "Windows 11";
            } else {
              os = "Windows 10";
            }
            device = "desktop";
            break;
          case TargetPlatform.linux:
            final info = await deviceInfo.linuxInfo;
            os = "Linux ${info.name}";
            device = "desktop";
            break;
          default:
            os = "Unknown";
            device = "unknown";
            break;
        }
      }
    } catch (e) {
      AtheonLogger.error("Device Info Error", e);
    }

    return {
      'browser': browser,
      'device': device,
      'engine': 'Flutter',
      'os': os,
      'session_id': _getSessionId(),
    };
  }

  void _loadAtheonData() {
    final newData = AtheonConfig.loadAtheonData(widget.dataAtheon);

    // Prevent config overwrites if locking logic is needed
    if (!_isConfigLocked && newData.isNotEmpty) {
      _isConfigLocked = true;
    }
    _data = newData;
  }

  void _injectAdDecoration() {
    final tokenized = AtheonContentInjector.injectAdTokens(
      widget.content,
      _data,
    );

    if (mounted) {
      setState(() {
        _processedContent = tokenized;
      });
    }
  }

  void _handleClick(String url) {
    try {
      final adIndex = _data.indexWhere(
        (config) => config.adMeta?.clickUrl == url,
      );
      if (adIndex != -1) {
        if (!_firedClicks.contains(adIndex)) {
          _firedClicks.add(adIndex);
          _fireEvent(AtheonConstants.EVENT_TYPE['CLICK']!, _data[adIndex]);
        }
      }
    } catch (e) {
      AtheonLogger.error("Click handler failed", e);
    }
  }

  void _onVisibilityChanged(VisibilityInfo info) {
    final isIntersecting = info.visibleFraction > 0.1;
    if (!isIntersecting) {
      _dwellTimer?.cancel();
      _dwellTimer = null;
    } else {
      // Dwell time check: user must see content for 350ms to count as impression
      _dwellTimer ??= Timer(const Duration(milliseconds: 350), () {
        if (mounted) {
          _checkImpressions();
          _dwellTimer = null;
        }
      });
    }
  }

  void _checkImpressions() {
    if (_clientInfo == null) return;

    try {
      for (int idx = 0; idx < _data.length; idx++) {
        final config = _data[idx];
        if (_firedImpressions.contains(idx)) continue;

        // Fires for both visible Ad Chips AND Invisible Trackers (null adMeta)
        _fireEvent(AtheonConstants.EVENT_TYPE['IMPRESSION']!, config);
        _firedImpressions.add(idx);
      }
    } catch (e) {
      AtheonLogger.error("Impression check failed", e);
    }
  }

  void _fireEvent(
    String eventType,
    AtheonConfig? config, [
    Map<String, dynamic> extra = const {},
  ]) {
    _sendTrackEvent({
      'type': eventType,
      'track_fingerprint': config?.trackFingerprint ?? "unknown",
      ..._clientInfo ?? {},
      ...extra,
    });
  }

  Future<void> _sendTrackEvent(Map<String, dynamic> payload) async {
    if (_publisherKey == null || _client == null) {
      return;
    }

    try {
      final headers = {
        "Content-Type": "application/json",
        "X-Atheon-Publisher-Key": _publisherKey!,
      };
      if (_originHeader != null) headers["X-Atheon-Origin"] = _originHeader!;

      debugPrint('Headers data: $headers');
      debugPrint('Payload data: $payload');

      await _client!.post(
        Uri.parse("https://api.atheon.ad/v1/track-events/"),
        headers: headers,
        body: jsonEncode(payload),
      );
    } catch (err) {
      AtheonLogger.error('Track event failed', err);
    }
  }

  @override
  Widget build(BuildContext context) {
    try {
      return VisibilityDetector(
        key: _visibilityKey,
        onVisibilityChanged: _onVisibilityChanged,
        child: widget.builder(context, _processedContent, _data, _handleClick),
      );
    } catch (e) {
      AtheonLogger.error("Render failed", e);
      return Text(widget.content);
    }
  }
}
