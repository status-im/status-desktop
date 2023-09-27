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
            initalAngleRad: 0
            ringPxSize: 1.5
            ringSpecModel: [ {colorId: 0; segmentLength: 1},
                             {colorId: 5; segmentLength: 1},
                             {colorId: 1; segmentLength: 1},
                             {colorId: 1; segmentLength: 4},
                             {colorId: 2; segmentLength: 3} ]
            distinctiveColors: ["#000000", "#726F6F", "#C4C4C4",
                                "#E7E7E7", "#FFFFFF", "#00FF00" ]
        }
   \endqml

   For a list of components available see StatusQ.
*/
QtObject {
    id: statusIdenticonRingSettings

    /*!
       \qmlproperty var StatusIdenticonRingSettings::ringSpecModel
       This is a REQUIRED property that contains a ListModel or array of objects that describes each ring segment color and length.

       Examples:
       \qml
            ringSpecModel: ListModel {ListElement{colorId: 0; segmentLength: 1} ListElement{colorId: 1; segmentLength: 2}}
       \endqml

       \qml
            ringSpecModel: [{colorId: 0, segmentLength: 1}, {colorId: 1, segmentLength: 2}]
       \endqml
    */
    property var ringSpecModel

    /*!
       \qmlproperty var StatusIdenticonRingSettings::distinctiveColors
       This is a REQUIRED property that holds an string array of disctinctive segment colors.
    */
    property var distinctiveColors

    /*!
       \qmlproperty real StatusIdenticonRingSettings::initalAngleRad
       This property provides the initial angle, in radians, the identicon ring will start rendering the line.
       Defaults to 0.
    */
    property real initalAngleRad: 0

    /*!
       \qmlproperty real StatusIdenticonRingSettings::ringPxSize
       This property provides the pixels size of the ring line.
    */
    property real ringPxSize

    readonly property var normalizedRingSpecModel: {
        if (typeof ringSpecModel !== "string") {
            return ringSpecModel
        }

        if(!ringSpecModel) {
            return undefined
        }

         try {
            return JSON.parse(ringSpecModel)
         } catch (e) {
            console.log("StatusIdenticonRingSettings: ringSpecModel is not a valid JSON string")
            return undefined
         }
    }
}
