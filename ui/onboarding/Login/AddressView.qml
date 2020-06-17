import QtQuick 2.13
import QtQuick.Controls 2.13
import "../../imports"
import "../../shared"

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

    id: addressViewDelegate
    height: 64
    anchors.right: parent.right
    anchors.left: parent.left
    border.width: 0
    color: selected || isHovered ? Theme.grey : Theme.transparent
    radius: Theme.radius

    RoundImage {
        id: accountImage
        anchors.left: parent.left
        anchors.leftMargin: Theme.padding
        anchors.verticalCenter: parent.verticalCenter
        source: identicon
    }
    Text {
        id: usernameText
        text: username
        elide: Text.ElideRight
        anchors.right: parent.right
        anchors.rightMargin: Theme.padding
        font.pixelSize: 17
        anchors.top: accountImage.top
        anchors.left: accountImage.right
        anchors.leftMargin: Theme.padding
    }

    Text {
        id: addressText
        width: 108
        text: address
        elide: Text.ElideMiddle
        anchors.bottom: accountImage.bottom
        anchors.bottomMargin: 0
        anchors.left: usernameText.left
        anchors.leftMargin: 0
        font.pixelSize: 15
        color: Theme.darkGrey
    }

    MouseArea {
        hoverEnabled: true
        anchors.fill: parent
        cursorShape: Qt.PointingHandCursor
        onClicked: {
            onAccountSelect(index)
        }
        onEntered: {
            addressViewDelegate.isHovered = true
        }
        onExited: {
            addressViewDelegate.isHovered = false
        }
    }
}

/*##^##
Designer {
    D{i:0;formeditorColor:"#ffffff";height:64;width:450}
}
##^##*/
