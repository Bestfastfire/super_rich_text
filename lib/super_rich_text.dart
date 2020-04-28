import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

enum MarkerType { function, sameFunction, text, url }

class MarkerText {
  final String marker;
  final TextStyle style;
  final MarkerType type;
  final List<String> urls;
  final List<Function> functions;
  final Function(int index, String msg) onError;

  const MarkerText._internal(
      {this.urls,
      this.marker,
      this.style,
      this.type,
      this.onError,
      this.functions});

  factory MarkerText({@required String marker, @required TextStyle style}) {
    return MarkerText._internal(
        type: MarkerType.text, marker: marker, style: style);
  }

  factory MarkerText.withUrl(
      {@required String marker,
      @required List<String> urls,
      TextStyle style,
      Function(int index, String msg) onError}) {
    return MarkerText._internal(
      style:
          style ?? TextStyle(fontWeight: FontWeight.bold, color: Colors.blue),
      type: MarkerType.url,
      onError: onError,
      marker: marker,
      urls: urls,
    );
  }

  factory MarkerText.withFunction(
      {@required String marker,
      @required List<Function> functions,
      @required TextStyle style,
      Function(int index, String msg) onError}) {
    return MarkerText._internal(
        type: MarkerType.function,
        functions: functions,
        onError: onError,
        marker: marker,
        style: style);
  }

  factory MarkerText.withSameFunction(
      {@required String marker,
      @required Function function,
      @required TextStyle style,
      Function(String msg) onError}) {
    return MarkerText._internal(
        type: MarkerType.sameFunction,
        functions: [function],
        onError: (i, msg) => onError(msg),
        marker: marker,
        style: style);
  }
}

// ignore: must_be_immutable
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
  final List<MarkerType> _typeWithTap = [
    MarkerType.url,
    MarkerType.function,
    MarkerType.sameFunction
  ];
  Map<String, TextSpan> texts = {};
  String toSplit = '';

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

  TextSpan getTextSpan(
      {@required RegExpMatch regex, @required MarkerText marker, int index}) {
    return TextSpan(
        text: regex.group(0).replaceAll(marker.marker, ''),
        style: marker.style,
        recognizer: _typeWithTap.contains(marker.type)
            ? (TapGestureRecognizer()
              ..onTap = () async {
                switch (marker.type) {
                  case MarkerType.function:
                    try {
                      await marker.functions[index]();
                    } catch (msg) {
                      // ignore: unnecessary_statements
                      marker.onError != null
                          ? marker.onError(index, msg)
                          // ignore: unnecessary_statements
                          : null;
                    }
                    break;

                  case MarkerType.sameFunction:
                    try {
                      await marker.functions[0]();
                    } catch (msg) {
                      // ignore: unnecessary_statements
                      marker.onError != null
                          ? marker.onError(0, msg)
                          // ignore: unnecessary_statements
                          : null;
                    }
                    break;

                  case MarkerType.url:
                    try {
                      if (await canLaunch(marker.urls[index])) {
                        launch(marker.urls[index]);
                      } else {
                        throw 'cant launch';
                      }
                    } catch (msg) {
                      // ignore: unnecessary_statements
                      marker.onError != null
                          ? marker.onError(index, msg)
                          // ignore: unnecessary_statements
                          : null;
                    }
                    break;

                  default:
                    break;
                }
              })
            : null);
  }

  insertValues(
      {@required List<RegExpMatch> found, String pattern, MarkerText marker}) {
    if (found.length > 0) {
      int index = 0;
      toSplit += '$pattern|';

      found.forEach((f) => texts[f.group(0)] =
          getTextSpan(regex: f, index: index++, marker: marker));
    }
  }

  @override
  Widget build(BuildContext context) {
    final List<MarkerText> allMarkers = [];
    allMarkers.addAll(othersMarkers);

    if (useGlobalMarkers) {
      allMarkers.addAll(globalMarkerTexts);
    }

    allMarkers.forEach((v) {
      final String m = v.marker;
      final String pattern = "\\$m.*?\\$m";
      final String pattern2 = "$m.*?$m";
      final List<RegExpMatch> found = RegExp(pattern).allMatches(text).toList();

      insertValues(
          found: () {
            if (found.length > 0) {
              return found;
            }

            try {
              return RegExp(pattern2).allMatches(this.text).toList();
            } catch (msg) {
              return <RegExpMatch>[];
            }
          }(),
          pattern: found.length > 0 ? pattern : pattern2,
          marker: v);
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

    toSplit = '';
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
