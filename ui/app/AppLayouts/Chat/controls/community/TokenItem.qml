import QtQuick 2.13
import QtQuick.Layouts 1.14
import QtQuick.Controls 2.12

import StatusQ.Core 0.1
import StatusQ.Core.Theme 0.1
import StatusQ.Controls 0.1
import StatusQ.Components 0.1

Control {
    id: root

    property string key
    property string name
    property string shortName
    property url iconSource
    property var subItems

    signal itemClicked(string key, string name, string shortName,  url iconSource, var subItems)

    leftPadding: 6 // by design
    implicitHeight: 45 // by design
    spacing: 8 // by design
    background: Rectangle {
        color: mouseArea.containsMouse ? Theme.palette.baseColor4 : "transparent"

        MouseArea {
            id: mouseArea
            anchors.fill: parent
            cursorShape: root.enabled ? Qt.PointingHandCursor : Qt.ArrowCursor
            hoverEnabled: true
            onClicked: root.itemClicked(root.key,
                                        root.name,
                                        root.shortName,
                                        root.iconSource,
                                        root.subItems)
        }
    }
    contentItem: RowLayout {
        spacing: root.spacing

        StatusRoundedImage {
            Layout.alignment: Qt.AlignVCenter
            image.source: root.iconSource
            visible: root.iconSource.toString() !== ""
            Layout.preferredWidth: 32
            Layout.preferredHeight: Layout.preferredWidth
        }

        ColumnLayout {
            Layout.fillWidth: true
            Layout.alignment: Qt.AlignVCenter
            spacing: 0

            StatusBaseText {
                Layout.fillWidth: true
                text: root.name
                color: Theme.palette.directColor1
                font.pixelSize: 13
                elide: Text.ElideRight
            }

            StatusBaseText {
                visible: !!root.shortName
                Layout.fillWidth: true
                text: !!root.shortName ? root.shortName : ""
                color: Theme.palette.baseColor1
                font.pixelSize: 12
                elide: Text.ElideRight
            }
        }

        StatusIcon {
            icon: "tiny/chevron-right"
            visible: !!root.subItems && root.subItems.count > 0
            Layout.alignment: Qt.AlignVCenter
            Layout.rightMargin: 16
            color: Theme.palette.baseColor1
            width: 16
            height: 16
        }
    }
}
