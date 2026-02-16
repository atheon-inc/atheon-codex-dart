import 'package:flutter/material.dart';

import 'package:atheon_ui/ui.dart';

import 'package:flutter_markdown_plus/flutter_markdown_plus.dart';
import 'package:markdown/markdown.dart' as md;

class AtheonMarkdownSyntax extends md.InlineSyntax {
  AtheonMarkdownSyntax() : super(r'\{\{ATHEON_AD_UNIT:(\d+)\|(.*?)\}\}');

  @override
  bool onMatch(md.InlineParser parser, Match match) {
    final adIndexStr = match[1];
    final adText = match[2];

    if (adIndexStr == null || adText == null) return false;

    final element = md.Element.text('atheon_ad_unit', adText);
    element.attributes['id'] = adIndexStr;
    parser.addNode(element);
    return true;
  }
}

class AtheonMarkdownBuilder extends MarkdownElementBuilder {
  final List<AtheonConfig> ads;
  final Function(String url) onAdClick;

  AtheonMarkdownBuilder({required this.ads, required this.onAdClick});

  @override
  Widget? visitElementAfter(md.Element element, TextStyle? preferredStyle) {
    final id = int.tryParse(element.attributes['id'] ?? '');
    if (id == null || id < 0 || id >= ads.length) return null;

    final config = ads[id];
    final url = config.adMeta?.clickUrl;
    if (url == null) return null;

    return AtheonAdChip(
      text: element.textContent,
      onTap: () => onAdClick(url),
      style: preferredStyle,
    );
  }
}
