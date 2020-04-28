import 'package:flutter/material.dart';
import 'package:super_rich_text/super_rich_text.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: Main(),
    );
  }
}

class Main extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    //To add global markers
    SuperRichText.globalMarkerTexts.add(
        MarkerText(marker: '|', style: TextStyle(color: Colors.deepPurple)));

    return Scaffold(
      body: Center(
          child: SuperRichText(
        text:
            'Text in *bold* and /italic/ with color ooOrangeoo and color rrRedrr, '
            'llLink1ll llLink2ll, <f>Function1<f> - <f>Function2<f> <sf>Same Fun<sf> '
            'and repeat <sf>Same Fun<sf>',
        style: TextStyle(color: Colors.black87, fontSize: 22),
        othersMarkers: [
          MarkerText(
              marker: 'oo', style: TextStyle(color: Colors.orangeAccent)),
          MarkerText(marker: 'rr', style: TextStyle(color: Colors.redAccent)),
          MarkerText.withUrl(
              marker: 'll',
              urls: ['https://www.google.com', 'https://www.facebook.com']),
          MarkerText.withFunction(
              marker: '<f>',
              functions: [() => print('function 1'), () => print('function 2')],
              onError: (i, msg) => print('$i -> $msg'),
              style: TextStyle(color: Colors.greenAccent)),
          MarkerText.withSameFunction(
              marker: '<sf>',
              function: () => print('function'),
              onError: (msg) => print('$msg'),
              style: TextStyle(color: Colors.purple))
        ],
      )),
    );
  }
}
