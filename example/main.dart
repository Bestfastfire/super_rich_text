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
    SuperRichText.globalMarkerTexts.add(MarkerText(
        marker: '|',
        style: TextStyle(
          color: Colors.deepPurple
        )
      )
    );

    return Scaffold(
      body: Center(
        child: SuperRichText(
          text: 'Text in *bold* and /italic/ with color llOrangell and color rrRedrr',
          useGlobalMarkers: false, // set false
          style: TextStyle(
            color: Colors.black87,
            fontSize: 22
          ),
          othersMarkers: [
            MarkerText(
                marker: '*',
                style: TextStyle(
                    color: Colors.orangeAccent
                )
            ),
            MarkerText(
              marker: 'll',
              style: TextStyle(
                color: Colors.orangeAccent
              )
            ),
            MarkerText(
              marker: 'rr',
              style: TextStyle(
                  color: Colors.redAccent
              )
            ),
          ],
        ),
      ),
    );
  }
}