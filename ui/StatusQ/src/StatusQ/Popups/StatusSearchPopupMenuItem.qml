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

    property StatusAssetSettings assetSettings: StatusAssetSettings {
        height: 16
        width: 16
        isLetterIdenticon: (name.toString() === "")
        color: (name === "channel") ? Theme.palette.directColor1 : "transparent"
        letterSize: charactersLen > 1 ? 8 : 11
        imgIsIdenticon: false
    }

    property alias ringSettings: identicon.ringSettings

    background: Rectangle {
        color: root.hovered ? Theme.palette.statusPopupMenu.hoverBackgroundColor : "transparent"
    }

    contentItem: RowLayout {
        anchors.left: parent.left
        anchors.leftMargin: 12
        Item {
            Layout.preferredWidth: root.assetSettings.width
            Layout.preferredHeight: root.assetSettings.height
            Layout.alignment: Qt.AlignVCenter
            StatusSmartIdenticon {
                id: identicon
                anchors.centerIn: parent
                asset: root.assetSettings
                name: root.text
                ringSettings: root.ringSettings
            }
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
