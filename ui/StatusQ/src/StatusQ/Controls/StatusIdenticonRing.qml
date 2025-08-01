import QtQuick
import QtQuick.Layouts

import StatusQ.Core
/*!
   \qmltype StatusIdenticonRing
   \inherits Item
   \inqmlmodule StatusQ.Controls
   \since StatusQ.Controls 0.1
   \brief It provides lines wrapped into a ring around another component like avatars.

   The \c StatusIdenticonRing item displays lines wrapped into a ring. The line is rendered clockwise.

   N segments and M distinctive colors compose identicon lines.

   Example of how the component looks like:
   \image status_identicon_ring.png

   Example of how to use it:

   \qml
        StatusIdenticonRing {
            anchors.fill: parent
            settings: StatusIdenticonRingSettings {
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
        }
   \endqml

   For a list of components available see StatusQ.
*/
Item {
    id: root

    /*!
       \qmlproperty StatusIdenticonRingSettings StatusIdenticonRing::settings
       This property holds a set of settings for building the ring.
    */
    property StatusIdenticonRingSettings settings: StatusIdenticonRingSettings {
        initalAngleRad: 0
        ringPxSize: 1.5
    }

    visible: settings && typeof settings.normalizedRingSpecModel !== "undefined"

    Loader {
        anchors.fill: parent

        active: root.visible

        sourceComponent: Canvas {
            function printArcSegment(context, xPos, yPos, radius, color, startAngle, arcAngleLen, lineWidth) {
                context.beginPath()
                context.arc(xPos, yPos, radius, startAngle, startAngle + arcAngleLen, false/*anticlockwise*/)
                context.strokeStyle = color
                context.lineWidth = lineWidth
                context.stroke()
            }

            function getSegmentsCount() {
                if (typeof settings.normalizedRingSpecModel.rowCount !== "undefined") {
                    return settings.normalizedRingSpecModel.rowCount()
                }
                if (typeof settings.normalizedRingSpecModel.count !== "undefined") {
                    return settings.normalizedRingSpecModel.count
                }
                return settings.normalizedRingSpecModel.length
            }

            function getSegment(i) {
                if (typeof settings.normalizedRingSpecModel.rowCount !== "undefined") {
                    return abstactItemModelWrapper.itemAt(i)
                }
                if (typeof settings.normalizedRingSpecModel.count !== "undefined") {
                    return settings.normalizedRingSpecModel.get(i)
                }
                return settings.normalizedRingSpecModel[i]
            }

            function totalRingUnits() {
                var units = 0
                for (let i=0; i < getSegmentsCount(); i++) {
                    const segment = getSegment(i)
                    units += segment.segmentLength
                }
                return Math.max(1, units)
            }

            Repeater {
                id: abstactItemModelWrapper
                model: typeof settings.normalizedRingSpecModel.rowCount !== "undefined" ? settings.normalizedRingSpecModel : null
                delegate: Item {
                    readonly property int segmentLength: model.segmentLength
                    readonly property int colorId: model.colorId
                }
            }

            onPaint: {
                const context = getContext("2d")
                const radius = (height  - settings.ringPxSize) / 2
                const xPos = width / 2
                const yPos = height / 2
                const unitRadLen = 2 * Math.PI / totalRingUnits()
                const segmentsCount = getSegmentsCount()
                let arcPos = settings.initalAngleRad
                context.reset()

                if(settings.normalizedRingSpecModel) {
                    for (let i=0; i < segmentsCount; i++) {
                        const segment = getSegment(i)
                        printArcSegment(context,
                                        xPos,
                                        yPos,
                                        radius,
                                        settings.distinctiveColors[segment.colorId],
                                        arcPos,
                                        segment.segmentLength * unitRadLen,
                                        settings.ringPxSize)
                        arcPos += segment.segmentLength * unitRadLen
                    }
                }
            }

            Connections {
                target: root.settings
                function onNormalizedRingSpecModelChanged() {
                    requestPaint()
                }
            }
        }
    }
}
