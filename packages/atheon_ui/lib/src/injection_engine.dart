import 'dart:math';

import 'package:atheon_ui/ui.dart';

class AtheonTextPart {
  final String text;
  final AtheonConfig? config;

  AtheonTextPart(this.text, {this.config});

  bool get isAd => config?.adMeta != null;
}

class _MatchCandidate {
  final int partIndex;
  final int matchIndex;
  final String matchedText;
  final int globalCandidateIndex;

  _MatchCandidate(
    this.partIndex,
    this.matchIndex,
    this.matchedText,
    this.globalCandidateIndex,
  );
}

class AtheonContentInjector {
  static List<AtheonTextPart> injectAdDecoration(
    String content,
    List<AtheonConfig> configs,
  ) {
    try {
      List<AtheonTextPart> parts = [AtheonTextPart(content)];

      for (int adIndex = 0; adIndex < configs.length; adIndex++) {
        final adConfig = configs[adIndex];
        final adMeta = adConfig.adMeta;

        // Skip text decoration if ad_meta is null.
        if (adMeta == null) continue;

        final escapedKeyword = RegExp.escape(adMeta.keyword);
        final flexiblePattern = escapedKeyword.replaceAll(
          RegExp(r'\s+'),
          r'\s+',
        );
        final regex = RegExp(
          r'\b' + flexiblePattern + r'\b',
          caseSensitive: false,
        );

        List<_MatchCandidate> candidates = [];
        int globalCounter = 0;

        for (int i = 0; i < parts.length; i++) {
          final part = parts[i];
          if (part.isAd) continue;

          final matches = regex.allMatches(part.text);
          for (final match in matches) {
            candidates.add(
              _MatchCandidate(i, match.start, match.group(0)!, globalCounter++),
            );
          }
        }

        if (candidates.isEmpty) continue;

        Set<int> indicesToInject = {};
        final totalMatches = candidates.length;

        if (adMeta.keywordStartIdx != null || adMeta.keywordEndIdx != null) {
          final start = adMeta.keywordStartIdx ?? 0;
          final end = adMeta.keywordEndIdx ?? (totalMatches - 1);
          for (int i = start; i <= end; i++) {
            if (i >= 0 && i < totalMatches) indicesToInject.add(i);
          }
        } else if (adMeta.injectionMode == 'first') {
          indicesToInject.add(0);
        } else if (adMeta.injectionMode == 'random') {
          if (totalMatches > 0) {
            indicesToInject.add(Random().nextInt(totalMatches));
          }
        } else {
          for (int i = 0; i < totalMatches; i++) indicesToInject.add(i);
        }

        List<AtheonTextPart> newParts = [];
        int currentCandidateIdx = 0;

        for (int i = 0; i < parts.length; i++) {
          final originalPart = parts[i];

          if (originalPart.isAd) {
            newParts.add(originalPart);
            continue;
          }

          List<_MatchCandidate> partCandidates = [];
          while (currentCandidateIdx < candidates.length &&
              candidates[currentCandidateIdx].partIndex == i) {
            partCandidates.add(candidates[currentCandidateIdx]);
            currentCandidateIdx++;
          }

          if (partCandidates.isEmpty) {
            newParts.add(originalPart);
            continue;
          }

          String text = originalPart.text;
          int cursor = 0;

          for (var candidate in partCandidates) {
            if (indicesToInject.contains(candidate.globalCandidateIndex)) {
              if (candidate.matchIndex > cursor) {
                newParts.add(
                  AtheonTextPart(text.substring(cursor, candidate.matchIndex)),
                );
              }
              newParts.add(
                AtheonTextPart(candidate.matchedText, config: adConfig),
              );
              cursor = candidate.matchIndex + candidate.matchedText.length;
            }
          }

          if (cursor < text.length) {
            newParts.add(AtheonTextPart(text.substring(cursor)));
          }
        }
        parts = newParts;
      }
      return parts;
    } catch (e) {
      AtheonLogger.error("Injection failed", e);
      return [AtheonTextPart(content)];
    }
  }

  static String injectAdTokens(String content, List<AtheonConfig> configs) {
    final parts = injectAdDecoration(content, configs);
    final buffer = StringBuffer();

    for (var part in parts) {
      if (part.isAd) {
        final index = configs.indexOf(part.config!);
        buffer.write('{{ATHEON_AD_UNIT:$index|${part.text}}}');
      } else {
        buffer.write(part.text);
      }
    }
    return buffer.toString();
  }
}
