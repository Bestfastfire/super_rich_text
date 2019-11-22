# Super Rich Text
Check it out at [Pub.Dev](https://pub.dev/packages/super_rich_text)

The easiest way to style custom text snippets

![ezgif com-video-to-gif-3](https://user-images.githubusercontent.com/22732544/69406013-d50f2000-0cdf-11ea-9573-788064e9ce3d.gif)

In standard markers the "*" is set to bold and "/" to italics as in the example:

    SuperRichText(
      text: 'Text in *bold* and /italic/'
    )
    
But you can change and set your own by passing a list of other labels:

    SuperRichText(
      text: 'Text in *bold* and /italic/ with color llOrangell and color rrRedrr',
      style: TextStyle(
        color: Colors.black87,
        fontSize: 22
      ),
      othersMarkers: [
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
    )
    
Or even override "*" and "/" by setting global styles not to be used:

    SuperRichText(
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
        )...
      ],
    )
    
The markers in the "othersMarkers" parameter are only for the widget in question, but you can also distinguish global markers:

    SuperRichText.globalMarkerTexts.add(MarkerText(
        marker: '|',
        style: TextStyle(
          color: Colors.deepPurple
        )
      )
    );