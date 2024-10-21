import QtQuick 2.15
import QtQuick.Controls 2.15

import utils 1.0

import shared 1.0
import shared.panels 1.0
import shared.status 1.0
import shared.controls.chat 1.0

import StatusQ.Controls 0.1 as StatusQControls
import StatusQ.Components 0.1
import StatusQ.Core.Theme 0.1

Rectangle {
    id: root

    property string username: "Jotaro Kujo"
    property string keyUid: "0x123345677890987654321123456"
    property string address: ""
    property var colorHash
    property int colorId
    property url image: "data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAADIAAAAyCAYAAAAeP4ixAAAAg0lEQVR4nOzXwQmAMBAFURV7sQybsgybsgyr0QYUlE1g+Mw7ioQMe9lMQwhDaAyhMYTGEJqYkPnrj/t5XE/ft2UdW1yken7MRAyhMYTGEBpDaAyhKe9JbzvSX9WdLWYihtAYQuMLkcYQGkPUScxEDKExhMYQGkNoDKExhMYQmjsAAP//ZfIUZgXTZXQAAAAASUVORK5CYII="
    property var onAccountSelect: function() {}
    property var isSelected: function() {}
    property bool selected: {
        return isSelected(index, keyUid)
    }
    property bool isHovered: false

    height: 64
    anchors.right: parent.right
    anchors.left: parent.left
    border.width: 0
    color: getBgColor()
    radius: Theme.radius

    function getBgColor() {
        if (selected) return Theme.palette.secondaryBackground
        if (isHovered) return Theme.palette.backgroundHover
        return Theme.palette.transparent
    }

    UserImage {
        id: accountImage

        anchors.left: parent.left
        anchors.leftMargin: Theme.padding
        anchors.verticalCenter: parent.verticalCenter

        name: root.username
        image: root.image
        colorId: root.colorId
        colorHash: root.colorHash
    }

    StyledText {
        id: usernameText
        text: username
        elide: Text.ElideRight
        anchors.right: parent.right
        anchors.rightMargin: Theme.padding + radio.width
        font.pixelSize: 17
        anchors.top: accountImage.top
        anchors.left: accountImage.right
        anchors.leftMargin: Theme.padding
    }

    StyledText {
        id: addressText
        width: 108
        text: address
        font.family: Theme.monoFont.name
        elide: Text.ElideMiddle
        anchors.bottom: accountImage.bottom
        anchors.bottomMargin: 0
        anchors.left: usernameText.left
        anchors.leftMargin: 0
        font.pixelSize: 15
        color: Theme.palette.secondaryText
    }

    StatusQControls.StatusRadioButton {
        id: radio
        anchors.right: parent.right
        anchors.rightMargin: Theme.padding
        anchors.verticalCenter: parent.verticalCenter
        checked: root.selected
    }

    MouseArea {
        hoverEnabled: true
        anchors.fill: parent
        cursorShape: Qt.PointingHandCursor
        onClicked: {
            onAccountSelect(index)
        }
        onEntered: {
            root.isHovered = true
        }
        onExited: {
            root.isHovered = false
        }
    }
}
