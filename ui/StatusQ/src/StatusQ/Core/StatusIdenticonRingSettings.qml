import QtQuick 2.13
import StatusQ.Core 0.1

/*!
   \qmltype StatusIdenticonRingSettings
   \inherits QtObject
   \inqmlmodule StatusQ.Core
   \since StatusQ.Core 0.1
   \brief It describes identicon ring settings.

   The \c StatusIdenticonRingSettings object is not a graphical component just an object to encapsulate identicon ring settings.

   Example of how to use it:

   \qml
        StatusIdenticonRingSettings {
            totalRingUnits: 25
            initalAngleRad: 0
            ringPxSize: 1.5
            ringSpecModel: [ ListElement {colorId: 0; segmentLength: 1},
                             ListElement {colorId: 28; segmentLength: 1},
                             ListElement {colorId: 31; segmentLength: 1},
                             ListElement {colorId: 22; segmentLength: 4},
                             ListElement {colorId: 28; segmentLength: 3},
                             ListElement {colorId: 27; segmentLength: 5},
                             ListElement {colorId: 7; segmentLength: 5},
                             ListElement {colorId: 13; segmentLength: 1},
                             ListElement {colorId: 25; segmentLength: 4}]
            distinctiveColors: ["#000000", "#726F6F", "#C4C4C4",
                                "#E7E7E7", "#FFFFFF", "#00FF00",
                                "#009800", "#B8FFBB", "#FFC413",
                                "#9F5947", "#FFFF00", "#A8AC00",
                                "#FFFFB0", "#FF5733", "#FF0000",
                                "#9A0000", "#FF9D9D", "#FF0099",
                                "#C80078", "#FF00FF", "#900090",
                                "#FFB0FF", "#9E00FF", "#0000FF",
                                "#000086", "#9B81FF", "#3FAEF9",
                                "#9A6600", "#00FFFF", "#008694",
                                "#C2FFFF", "#00F0B6"]
        }
   \endqml

   For a list of components available see StatusQ.
*/
QtObject {
    id: statusIdenticonRingSettings

    /*!
       \qmlproperty ListModel StatusIdenticonRingSettings::ringSpecModel
       This is a REQUIRED property that contains a ListModel object that describes each ring segment color and length.
       Example of use: [ListElement {colorId: 0; segmentLength: 1}, ...]
    */
    property ListModel ringSpecModel

    /*!
       \qmlproperty var StatusIdenticonRingSettings::distinctiveColors
       This is a REQUIRED property that holds an string array of disctinctive segment colors.
    */
    property var distinctiveColors

    /*!
       \qmlproperty real StatusIdenticonRingSettings::totalRingUnits
       This property provides the total number of units the identicon ring is composed by.
    */
    property real totalRingUnits

    /*!
       \qmlproperty real StatusIdenticonRingSettings::initalAngleRad
       This property provides the initial angle, in radians, the identicon ring will start rendering the line.
    */
    property real initalAngleRad

    /*!
       \qmlproperty real StatusIdenticonRingSettings::ringPxSize
       This property provides the pixels size of the ring line.
    */
    property real ringPxSize
}
