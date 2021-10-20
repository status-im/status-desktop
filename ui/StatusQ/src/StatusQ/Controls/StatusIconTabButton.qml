import QtQuick 2.13
import QtQuick.Controls 2.13
import QtGraphicalEffects 1.13
import StatusQ.Core 0.1
import StatusQ.Core.Theme 0.1
import StatusQ.Components 0.1

TabButton {
    id: statusIconTabButton

    property string name: ""
    property bool highlighted: false

    implicitWidth: 40
    implicitHeight: 40

    icon.height: 24
    icon.width: 24
    icon.color: Theme.palette.baseColor1

    contentItem: Item {
        anchors.fill: parent
        StatusSmartIdenticon {
            id: identicon
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.verticalCenter: parent.verticalCenter
            image.source: statusIconTabButton.icon.source
            image.width: 28
            image.height: 28
            icon.height: statusIconTabButton.icon.height
            icon.width: statusIconTabButton.icon.width
            icon.name: statusIconTabButton.icon.name
            icon.color: (statusIconTabButton.hovered || highlighted || statusIconTabButton.checked) ? Theme.palette.primaryColor1 : statusIconTabButton.icon.color
            icon.isLetterIdenticon: statusIconTabButton.name !== "" && !statusIconTabButton.icon.source.toString()
            icon.letterSize: 15
            name: statusIconTabButton.name
        }
    }

    background: Rectangle {
        color: hovered || highlighted || ((!!icon.source.toString() || !!name) && checked) ? Theme.palette.primaryColor3 : "transparent"
        border.color: Theme.palette.primaryColor1
        border.width: (!!icon.source.toString() || !!name) && checked ? 1 : 0
        radius: statusIconTabButton.width / 2
    }

    MouseArea {
        cursorShape: Qt.PointingHandCursor
        anchors.fill: parent
        onPressed: mouse.accepted = false
    }
}

