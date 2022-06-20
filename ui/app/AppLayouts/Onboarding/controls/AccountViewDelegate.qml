import QtQuick 2.13
import QtQuick.Controls 2.13

import utils 1.0

import shared 1.0
import shared.panels 1.0
import shared.status 1.0
import shared.controls.chat 1.0

import StatusQ.Controls 0.1 as StatusQControls
import StatusQ.Components 0.1

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

    height: Style.dp(64)
    anchors.right: parent.right
    anchors.left: parent.left
    border.width: 0
    color: getBgColor()
    radius: Style.current.radius

    function getBgColor() {
        if (selected) return Style.current.secondaryBackground
        if (isHovered) return Style.current.backgroundHover
        return Style.current.transparent
    }

    UserImage {
        id: accountImage

        anchors.left: parent.left
        anchors.leftMargin: Style.current.padding
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
        anchors.rightMargin: Style.current.padding + radio.width
        font.pixelSize: Style.dp(17)
        anchors.top: accountImage.top
        anchors.left: accountImage.right
        anchors.leftMargin: Style.current.padding
    }

    StyledText {
        id: addressText
        width: 108
        text: address
        font.family: Style.current.fontHexRegular.name
        elide: Text.ElideMiddle
        anchors.bottom: accountImage.bottom
        anchors.left: usernameText.left
        font.pixelSize: Style.current.primaryTextFontSize
        color: Style.current.secondaryText
    }

    StatusQControls.StatusRadioButton {
        id: radio
        anchors.right: parent.right
        anchors.rightMargin: Style.current.padding
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
