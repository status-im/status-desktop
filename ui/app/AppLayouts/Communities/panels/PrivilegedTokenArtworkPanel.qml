import QtQuick 2.15
import QtQuick.Controls 2.1
import QtGraphicalEffects 1.0

import StatusQ.Core 0.1
import StatusQ.Core.Theme 0.1
import StatusQ.Controls 0.1

import utils 1.0

Control {
    id: root

    required property bool isOwner

    property bool showTag: false
    property int size: PrivilegedTokenArtworkPanel.Size.Small

    property alias artwork: image.source
    property alias color: icon.color

    QtObject {
        id: d

        readonly property int imageSize: size === PrivilegedTokenArtworkPanel.Size.Small ? 80 : 186
        readonly property int bgSize: size === PrivilegedTokenArtworkPanel.Size.Small ? 120 : 280
        readonly property int iconSize: size === PrivilegedTokenArtworkPanel.Size.Small ? 16 : 38
        readonly property int iconMargins: size === PrivilegedTokenArtworkPanel.Size.Small ? 8 : 16
    }

    enum Size {
        Small,
        Large
    }

    implicitWidth: d.bgSize
    implicitHeight: implicitWidth

    background: Rectangle {
        color: "transparent"
        radius: 8
        border.color: Theme.palette.baseColor2
    }

    contentItem: Item {
        StatusTagItem {
            visible: root.showTag
            anchors.top: parent.top
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.topMargin: -height/2
            height: 20
            text: qsTr("Included")
            font.pixelSize: 11
            font.bold: true
            isReadonly: true
            background: Rectangle {
                color: Theme.palette.primaryColor1
                radius: 38
            }
        }

        Image {
            id: image

            anchors.centerIn: parent
            width: d.imageSize
            height: width
            fillMode: Image.PreserveAspectFit
            layer.enabled: true
            layer.effect: OpacityMask {
                maskSource: Rectangle {
                    width: image.width
                    height: width
                    radius: width / 2
                }
            }
        }

        StatusIcon {
            id: icon

            anchors.right: parent.right
            anchors.bottom: parent.bottom
            anchors.margins: d.iconMargins
            width: d.iconSize
            height: width
            icon: root.isOwner ? "crown" : "token-sale"
        }
    }
}
