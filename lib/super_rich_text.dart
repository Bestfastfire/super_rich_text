import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

enum MarkerType { function, sameFunction, text, url }

typedef OnErrorType = void Function(int index, Object msg);

class MarkerText {
  /// Marker to identify in text, ex: *MY TEXT*, marker is "*"
  final String marker;

  /// Text Style
  final TextStyle style;

  /// Type of Marker
  final MarkerType type;

  /// Urls, only required case type is
  final List<String>? urls;

  /// List of functions case type is "function" or "sameFunction"
  final List<Function>? functions;

  /// On error occurred when called any functions above
  final OnErrorType? onError;

  const MarkerText._internal(
      {this.urls,
      required this.marker,
      required this.style,
      required this.type,
      this.onError,
      this.functions});

  factory MarkerText({required String marker, required TextStyle style}) {
    return MarkerText._internal(
        type: MarkerType.text, marker: marker, style: style);
  }

  factory MarkerText.withUrl(
      {required String marker,
      required List<String> urls,
      TextStyle style= const TextStyle(fontWeight: FontWeight.bold, color: Colors.blue),
      OnErrorType? onError}) {
    return MarkerText._internal(
      style:
          style,
      type: MarkerType.url,
      onError: onError,
      marker: marker,
      urls: urls,
    );
  }

  factory MarkerText.withFunction(
      {required String marker,
      required List<Function> functions,
      required TextStyle style,
      OnErrorType? onError}) {
    return MarkerText._internal(
        type: MarkerType.function,
        functions: functions,
        onError: onError,
        marker: marker,
        style: style);
  }

  factory MarkerText.withSameFunction(
      {required String marker,
      required Function function,
      required TextStyle style,
      Function(Object msg)? onError}) {
    return MarkerText._internal(
        type: MarkerType.sameFunction,
        functions: [function],
        onError: (i, msg) => onError!(msg),
        marker: marker,
        style: style);
  }
}

// ignore: must_be_immutable
class SuperRichText extends StatelessWidget {
  /// List of global markers
  static final List<MarkerText> globalMarkerTexts = [
    MarkerText(marker: '*', style: TextStyle(fontWeight: FontWeight.bold)),
    MarkerText(marker: '/', style: TextStyle(fontStyle: FontStyle.italic))
  ];

  /// The text to display in this widget.
  final String text;
  final TextStyle? style;

  /// {@macro flutter.painting.textPainter.strutStyle}
  final StrutStyle? strutStyle;

  /// How the text should be aligned horizontally.
  final TextAlign textAlign;

  /// The directionality of the text.
  ///
  /// This decides how [textAlign] values like [TextAlign.start] and
  /// [TextAlign.end] are interpreted.
  ///
  /// This is also used to disambiguate how to render bidirectional text. For
  /// example, if the [text] is an English phrase followed by a Hebrew phrase,
  /// in a [TextDirection.ltr] context the English phrase will be on the left
  /// and the Hebrew phrase to its right, while in a [TextDirection.rtl]
  /// context, the English phrase will be on the right and the Hebrew phrase on
  /// its left.
  ///
  /// Defaults to the ambient [Directionality], if any. If there is no ambient
  /// [Directionality], then this must not be null.
  final TextDirection? textDirection;

  /// Used to select a font when the same Unicode character can
  /// be rendered differently, depending on the locale.
  ///
  /// It's rarely necessary to set this property. By default its value
  /// is inherited from the enclosing app with `Localizations.localeOf(context)`.
  ///
  /// See [RenderParagraph.locale] for more information.
  final Locale? locale;

  /// Whether the text should break at soft line breaks.
  ///
  /// If false, the glyphs in the text will be positioned as if there was unlimited horizontal space.
  final bool softWrap;

  /// How visual overflow should be handled.
  final TextOverflow overflow;

  /// The number of font pixels for each logical pixel.
  ///
  /// For example, if the text scale factor is 1.5, text will be 50% larger than
  /// the specified font size.
  final double textScaleFactor;

  /// An optional maximum number of lines for the text to span, wrapping if necessary.
  /// If the text exceeds the given number of lines, it will be truncated according
  /// to [overflow].
  ///
  /// If this is 1, text will not wrap. Otherwise, text will be wrapped at the
  /// edge of the box.
  final int? maxLines;

  /// {@macro flutter.widgets.text.DefaultTextStyle.textWidthBasis}
  final TextWidthBasis textWidthBasis;

  /// Markers to only this widget
  final List<MarkerText> othersMarkers;

  /// Pass false case don't to want use global markers
  final bool useGlobalMarkers;

  final List<MarkerType> _typeWithTap = [
    MarkerType.url,
    MarkerType.function,
    MarkerType.sameFunction
  ];
  Map<String, TextSpan> texts = {};
  String toSplit = '';

  SuperRichText(
      {required this.text,
      Key? key,
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
      {required RegExpMatch regex, required MarkerText marker, int? index}) {
    return TextSpan(
        text: regex.group(0)!.replaceAll(marker.marker, ''),
        style: marker.style,
        recognizer: _typeWithTap.contains(marker.type)
            ? (TapGestureRecognizer()
              ..onTap = () async {
                switch (marker.type) {
                  case MarkerType.function:
                    try {
                      await marker.functions![index!]();
                    } catch (msg) {
                      // ignore: unnecessary_statements
                      marker.onError != null
                          ? marker.onError!(index!, msg)
                          // ignore: unnecessary_statements
                          : null;
                    }
                    break;

                  case MarkerType.sameFunction:
                    try {
                      await marker.functions![0]();
                    } catch (msg) {
                      // ignore: unnecessary_statements
                      marker.onError != null
                          ? marker.onError!(0, msg)
                          // ignore: unnecessary_statements
                          : null;
                    }
                    break;

                  case MarkerType.url:
                    try {
                      if (await canLaunch(marker.urls![index!])) {
                        launch(marker.urls![index]);
                      } else {
                        throw 'cant launch';
                      }
                    } catch (msg) {
                      // ignore: unnecessary_statements
                      marker.onError != null
                          ? marker.onError!(index!, msg)
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
      {required List<RegExpMatch> found, String? pattern, MarkerText? marker}) {
    if (found.length > 0) {
      int index = 0;
      toSplit += '$pattern|';

      found.forEach((f) => texts[f.group(0)!] =
          getTextSpan(regex: f, index: index++, marker: marker!));
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
            .toList() as List<String>
        : [];

    int i = 0;
    final List<TextSpan> finalList = [];
    normalTexts.forEach((v) {
      finalList.add(TextSpan(text: v));

      try {
        finalList.add(texts[inSequence[i++]]!);
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
