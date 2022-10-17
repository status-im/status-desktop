import QtQuick 2.14
import StatusQ.Core 0.1
import StatusQ.Components 0.1
import StatusQ.Core.Theme 0.1
import StatusQ.Core.Utils 0.1

Rectangle {
    id: root

    property string emoji
    property string name
    property bool removable: false
    property bool highlighted: false

    signal clicked()

    implicitHeight: 32
    implicitWidth: row.width + 20
    radius: height / 2
    border.color: Theme.palette.baseColor2
    border.width: 1
    color: root.highlighted || mouseArea.containsMouse ? Theme.palette.primaryColor2 : "transparent"

    MouseArea {
        id: mouseArea
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: root.clicked()
    }

    Row {
        id: row
        anchors.centerIn: parent

        StatusEmoji {
            width: 18
            height: 18
            emojiId: root.emoji != "" ? Emoji.iconHex(root.emoji) : ""
            anchors.verticalCenter: parent.verticalCenter
        }

        Item {
            width: 5
            height: width
        }

        StatusBaseText {
            anchors.verticalCenter: parent.verticalCenter
            font.pixelSize: 15
            font.weight: Font.DemiBold
            font.capitalization: Font.AllLowercase
            color: root.enabled ? Theme.palette.primaryColor1 : Theme.palette.baseColor1
            text: root.name
        }

        StatusIcon {
            visible: removable
            color: root.enabled ? Theme.palette.primaryColor1 : Theme.palette.baseColor1
            icon: "close"
        }
    }
}
