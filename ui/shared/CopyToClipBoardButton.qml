import QtQuick 2.13
import QtQuick.Controls 2.13
import "../imports"

Rectangle {
    id: copyToClipboardButton
    height: 32
    width: 32
    radius: 8
    color: Style.current.transparent
    property var onClick: function() {}
    property string textToCopy: ""

    SVGImage {
        width: 20
        height: 20
        source: "./img/copy-to-clipboard-icon.svg"
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.verticalCenter: parent.verticalCenter
    }

    MouseArea {
        cursorShape: Qt.PointingHandCursor
        anchors.fill: parent
        hoverEnabled: true
        onExited: {
            parent.color = Style.current.transparent
        }
        onEntered:{
            parent.color = Style.current.lightGrey
        }
        onPressed: {
            parent.color = Style.current.grey
        }
        onReleased: {
            parent.color = Style.current.transparent
        }
        onClicked: {
            if (textToCopy) {
                chatsModel.copyToClipboard(textToCopy)
            }
            onClick()
        }
    }
}


