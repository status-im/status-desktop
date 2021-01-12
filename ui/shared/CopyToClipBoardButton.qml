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
    property bool showTooltip: false
    property string textTooltip: ""

    Image {
        width: 20
        height: 20
        sourceSize.width: width
        sourceSize.height: height
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
            parent.color = Style.current.grey
        }
        onPressed: {
            parent.color = Style.current.grey
            parent.showTooltip = true
        }
        onReleased: {
            parent.color = Style.current.grey
        }
        onClicked: {
            if (textToCopy) {
                chatsModel.copyToClipboard(textToCopy)
            }
            onClick()
        }
    }

    ToolTip {
        id: toolTip
        text: parent.textTooltip
        parent: copyToClipboardButton
    }

    Timer {
        id:showTimer
        interval: 500
        running: parent.showTooltip && !toolTip.visible
        onTriggered: {
            toolTip.visible = true;
        }
    }

    Timer {
        id:hideTimer
        interval: 1500
        running: toolTip.visible
        onTriggered: {
            toolTip.visible = false;
            parent.showTooltip = false;
        }
    }
}


