import QtQuick 2.15
import QtQuick.Layouts 1.15
import QtGraphicalEffects 1.15

import StatusQ.Controls 0.1
import StatusQ.Core 0.1
import StatusQ.Core.Theme 0.1

import utils 1.0

Rectangle {
    id: root

    property alias payloadToDisplay: contentText.text

    border.width: 1
    border.color: Theme.palette.baseColor2
    color: "transparent"
    radius: 8

    implicitHeight: d.expanded ? contentText.implicitHeight + (2 * contentText.anchors.margins) : 
                                    Math.min(contentText.implicitHeight + (2 * contentText.anchors.margins), 200)

    HoverHandler {
        id: hoverHandler
        target: root
    }

    StatusBaseText {
        id: contentText
        objectName: "textContent"

        anchors.fill: parent
        anchors.margins: 20

        text: root.payloadToDisplay
        font.pixelSize: Style.current.additionalTextSize
        lineHeightMode: Text.FixedHeight
        lineHeight: 18

        wrapMode: Text.WrapAnywhere

        StatusFlatButton {
            objectName: "expandButton"
            anchors.top: parent.top
            anchors.right: parent.right
            icon.name: d.expanded ? "collapse" : "expand"
            icon.color: hovered ? Theme.palette.directColor1 : Theme.palette.baseColor1
            hoverColor: "transparent"
            visible: d.canExpand && hoverHandler.hovered
            onClicked: {
                d.expanded = !d.expanded
            }
        }

        layer.enabled: !d.expanded && d.canExpand
        layer.effect: OpacityMask {
            maskSource: Rectangle {
                width: root.width
                height: root.height
                gradient: Gradient {
                    orientation: Gradient.Vertical
                    GradientStop { position: 0.0 }
                    GradientStop { position: (root.height - 60) / root.height }
                    GradientStop { position: 1; color: "transparent" }
                }
            }
        }
    }

    QtObject {
        id: d
        readonly property int maxContentHeight: 350
        property bool expanded: false
        property bool canExpand: contentText.implicitHeight > maxContentHeight
    }
}
