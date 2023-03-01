import QtQuick 2.14
import QtQuick.Layouts 1.14
import QtQuick.Controls 2.14

import StatusQ.Core.Theme 0.1

/*!
   \qmltype StatusDotsLoadingIndicator
   \inherits Control
   \inqmlmodule StatusQ.Components
   \since StatusQ.Components 0.1
   \brief It is a 3 dots loading animation.

   The \c StatusDotsLoadingIndicator displays 3 dots blinking animation.

   Example of how the control looks like:
   \image status_dots_loading_indicator.png

   Example of how to use it:

   \qml
        StatusDotsLoadingIndicator {
            dotsDiameter: 5
            duration: 1000
            dotsColor: "orange"
        }
   \endqml

   For a list of components available see StatusQ.
*/
Control {
    id: root

    /*!
       \qmlproperty string StatusDotsLoadingIndicator::dotsDiameter
       This property holds the diameter of the dots.
    */
    property double dotsDiameter: 4.5

    /*!
       \qmlproperty string StatusDotsLoadingIndicator::duration
       This property holds the duration of the animation.
    */
    property int duration: 1500

    /*!
       \qmlproperty string StatusDotsLoadingIndicator::dotsColor
       This property holds the color of the dots.
    */
    property color dotsColor: Theme.palette.baseColor1

    QtObject {
        id: d

        readonly property double opacity1: 1
        readonly property double opacity2: 0.6
        readonly property double opacity3: 0.2
    }

    spacing: 2

    component DotItem: Rectangle{
        id: dotItem

        property double maxOpacity

        width: root.dotsDiameter
        height: width
        radius: width / 2
        color: root.dotsColor

        SequentialAnimation {
            id: blinkingAnimation

            loops: Animation.Infinite
            running: visible
            NumberAnimation { target: dotItem; property: "opacity"; to: 0; duration: root.duration;}
            NumberAnimation { target: dotItem; property: "opacity"; to: dotItem.maxOpacity; duration: root.duration;}
        }

        Component.onCompleted: blinkingAnimation.start()
    }

    contentItem: RowLayout {
        spacing: root.spacing

        DotItem { id: firstDot; maxOpacity: d.opacity1}
        DotItem { id: secondDot; maxOpacity: d.opacity2}
        DotItem { id: thirdDot; maxOpacity: d.opacity3}
    }
}
