import QtQuick 2.13
import QtQuick.Controls 2.13
import "../imports"

Rectangle {
    id: copyToClipboardButton
    height: 32
    width: 32
    radius: 8
    property var onClick: function() {}

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
            parent.color = Theme.white
        }
        onEntered:{
            parent.color = Theme.grey
        }
        onClicked: onClick()
    }
}


