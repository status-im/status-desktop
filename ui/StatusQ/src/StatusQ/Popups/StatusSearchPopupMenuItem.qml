import QtQuick 2.14
import QtQuick.Controls 2.14
import QtQuick.Layouts 1.12
import StatusQ.Components 0.1
import StatusQ.Core 0.1
import StatusQ.Core.Theme 0.1

MenuItem {
    id: root
    implicitHeight: 38

    property string value: ""

    property StatusImageSettings image: StatusImageSettings {
        height: 16
        width: 16
        isIdenticon: false
    }
    property StatusIconSettings iconSettings: StatusIconSettings {
        height: 16
        width: 16
        isLetterIdenticon: (root.image.source.toString() === ""
                            && root.iconSettings.name.toString() === "")
        background: StatusIconBackgroundSettings {}
        color: "transparent"
    }

    background: Rectangle {
        color: root.hovered ? Theme.palette.statusPopupMenu.hoverBackgroundColor : "transparent"
    }

    contentItem: RowLayout {
        anchors.left: parent.left
        anchors.leftMargin: 12
        StatusIcon {
            Layout.preferredWidth: visible ? root.iconSettings.width : 0
            Layout.preferredHeight: visible ? root.iconSettings.height : 0
            Layout.alignment: Qt.AlignVCenter
            visible: !!root.iconSettings.name && !root.image.source.toString()
            icon:  root.iconSettings.name
            color: (icon === "channel")? Theme.palette.directColor1 : root.iconSettings.color
        }
        StatusRoundedImage {
            Layout.preferredWidth: visible ? root.image.width : 0
            Layout.preferredHeight: visible ? root.image.height : 0
            Layout.alignment: Qt.AlignVCenter
            visible: root.image.source.toString() !== ""
            image.source: root.image.source
            border.width: root.image.isIdenticon ? 1 : 0
            border.color: Theme.palette.directColor7
        }
        StatusLetterIdenticon {
            Layout.preferredWidth: visible ? root.iconSettings.width : 0
            Layout.preferredHeight: visible ? root.iconSettings.height : 0
            visible: root.iconSettings.isLetterIdenticon && !root.iconSettings.name && !root.image.source.toString()
            color: root.iconSettings.color
            name: root.text
            letterSize: 11
        }
        StatusBaseText {
            Layout.fillWidth: true
            Layout.alignment: Qt.AlignVCenter
            text: root.text
            color: Theme.palette.directColor1
            font.pixelSize: 13
            elide: Text.ElideRight
        }
        Item {
            Layout.fillWidth: true
        }
    }
    MouseArea {
        id: sensor
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onPressed: mouse.accepted = false
    }
}
