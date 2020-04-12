# Super Rich Text
Check it out at [Pub.Dev](https://pub.dev/packages/super_rich_text)

The easiest way to style custom text snippets

![ezgif com-video-to-gif-3](https://user-images.githubusercontent.com/22732544/69406013-d50f2000-0cdf-11ea-9573-788064e9ce3d.gif)

## Defaults

In standard markers the "*" is set to bold and "/" to italics as in the example:

    SuperRichText(
      text: 'Text in *bold* and /italic/'
    )
 
## Others Markers
    
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

## Override Global Markers
    
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

## Global Markers
      
The markers in the "othersMarkers" parameter are only for the widget in question, but you can also distinguish global markers:

    SuperRichText.globalMarkerTexts.add(MarkerText(
        marker: '|',
        style: TextStyle(
          color: Colors.deepPurple
        )
      )
    );

## Links   
    
It is also possible to insert functions or links directly into the text:

    MarkerText.withUrl(
      marker: 'll',
      urls: [
        'https://www.google.com',
        'https://www.facebook.com'
      ],
      style: TextStyle(
        fontSize: 36,
        color: Colors.orangeAccent
      )
    )
    
In this case, the link list should be in exactly the same sequence as the links within the text, having as base text: "this text has llLink1ll and llLink2ll", the example above would set *Link1* as 'https://www.google.com' and *Link2* as 'https://www.facebook.com'.
Another point is that it already has a bold style and blue text by default.

## Functions

With functions, the sequence is also the same, but the call should look like this:

    MarkerText.withFunction(
      marker: 'ff',
      functions: [
        () => print('function 1'),
        () => print('function 2')
      ],
      style: TextStyle(
        color: Colors.greenAccent
      )
    )

## Help Maintenance

I've been maintaining quite many repos these days and burning out slowly. If you could help me cheer up, buying me a cup of coffee will make my life really happy and get much energy out of it.

<a href="https://www.buymeacoffee.com/RtrHv1C" target="_blank"><img src="https://www.buymeacoffee.com/assets/img/custom_images/purple_img.png" alt="Buy Me A Coffee" style="height: auto !important;width: auto !important;" ></a>