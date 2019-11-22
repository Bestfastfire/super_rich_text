library super_rich_text;

import 'package:flutter/material.dart';

class MarkerText {
  final String marker;
  final TextStyle style;

  const MarkerText({@required this.marker, @required this.style});
}

class SuperRichText extends StatelessWidget {
  static final List<MarkerText> globalMarkerTexts = [
    MarkerText(marker: '*', style: TextStyle(fontWeight: FontWeight.bold)),
    MarkerText(marker: '/', style: TextStyle(fontStyle: FontStyle.italic))
  ];
  final String text;
  final TextStyle style;
  final StrutStyle strutStyle;
  final TextAlign textAlign;
  final TextDirection textDirection;
  final Locale locale;
  final bool softWrap;
  final TextOverflow overflow;
  final double textScaleFactor;
  final int maxLines;
  final TextWidthBasis textWidthBasis;
  final List<MarkerText> othersMarkers;
  final bool useGlobalMarkers;

  SuperRichText(
      {@required this.text,
      Key key,
      this.style,
      this.strutStyle,
      this.textAlign = TextAlign.start,
      this.textDirection,
      this.locale,
      this.softWrap = true,
      this.overflow = TextOverflow.clip,
      this.textScaleFactor = 1.0,
      this.maxLines,
      this.textWidthBasis = TextWidthBasis.parent,
      this.useGlobalMarkers = true,
      this.othersMarkers = const []})
      : assert(
          text != null,
          'A non-null String must be provided to a Text widget.',
        ),
        super(key: key);

  @override
  Widget build(BuildContext context) {
    final List<MarkerText> allMarkers = [];
    allMarkers.addAll(othersMarkers);
    Map<String, TextSpan> texts = {};
    String toSplit = '';

    if (useGlobalMarkers) {
      allMarkers.addAll(globalMarkerTexts);
    }

    allMarkers.forEach((v) {
      final String m = v.marker;
      final String pattern = "\\$m.*?\\$m";
      final String pattern2 = "$m.*?$m";

      final List<RegExpMatch> found = RegExp(pattern).allMatches(text).toList();

      if (found.length > 0) {
        toSplit += '$pattern|';

        found.forEach((f) => texts[f.group(0)] =
            TextSpan(text: f.group(0).replaceAll(m, ''), style: v.style));
      } else {
        final List<RegExpMatch> found =
            RegExp(pattern2).allMatches(text).toList();
        if (found.length > 0) {
          toSplit += '$pattern2|';

          found.forEach((f) => texts[f.group(0)] =
              TextSpan(text: f.group(0).replaceAll(m, ''), style: v.style));
        }
      }
    });

    try {
      toSplit = toSplit.substring(0, toSplit.length - 1);
    } catch (msg) {
      //ignored

    }

    final List<String> normalTexts =
        toSplit != '' ? text.split(RegExp(toSplit)) : [text];

    final List<String> inSequence = toSplit != ''
        ? RegExp(toSplit)
            .allMatches(text)
            .toList()
            .map((v) => v.group(0))
            .toList()
        : [];

    int i = 0;
    final List<TextSpan> finalList = [];
    normalTexts.forEach((v) {
      finalList.add(TextSpan(text: v));

      try {
        finalList.add(texts[inSequence[i++]]);
      } catch (msg) {
        //ignored

      }
    });

    return RichText(
        key: key,
        locale: locale,
        maxLines: maxLines,
        overflow: overflow,
        softWrap: softWrap,
        textAlign: textAlign,
        strutStyle: strutStyle,
        textDirection: textDirection,
        textWidthBasis: textWidthBasis,
        textScaleFactor: textScaleFactor,
        text: TextSpan(
            children: finalList,
            style: style ?? DefaultTextStyle.of(context).style));
  }
}
