import QtQuick 2.13
import QtQuick.Controls 2.13
import "../../imports"
import "../../shared"
import "../../shared/status"

Rectangle {
    property string username: "Jotaro Kujo"
    property string address: "0x123345677890987654321123456"
    property url identicon: "data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAADIAAAAyCAYAAAAeP4ixAAAAg0lEQVR4nOzXwQmAMBAFURV7sQybsgybsgyr0QYUlE1g+Mw7ioQMe9lMQwhDaAyhMYTGEJqYkPnrj/t5XE/ft2UdW1yken7MRAyhMYTGEBpDaAyhKe9JbzvSX9WdLWYihtAYQuMLkcYQGkPUScxEDKExhMYQGkNoDKExhMYQmjsAAP//ZfIUZgXTZXQAAAAASUVORK5CYII="
    property var onAccountSelect: function() {}
    property var isSelected: function() {}
    property bool selected: {
        return isSelected(index, address)
    }
    property bool isHovered: false

    id: root
    height: 64
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

    StatusImageIdenticon {
        id: accountImage
        anchors.left: parent.left
        anchors.leftMargin: Style.current.padding
        anchors.verticalCenter: parent.verticalCenter
        source: identicon
    }
    StyledText {
        id: usernameText
        text: username
        elide: Text.ElideRight
        anchors.right: parent.right
        anchors.rightMargin: Style.current.padding + radio.width
        font.pixelSize: 17
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
        anchors.bottomMargin: 0
        anchors.left: usernameText.left
        anchors.leftMargin: 0
        font.pixelSize: 15
        color: Style.current.secondaryText
    }

    StatusRadioButton {
        id: radio
        anchors.right: parent.right
        anchors.rightMargin: Style.current.padding
        anchors.verticalCenter: parent.verticalCenter
        checked: root.selected
        isHovered: root.isHovered
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

/*##^##
Designer {
    D{i:0;formeditorColor:"#ffffff";height:64;width:450}
}
##^##*/
