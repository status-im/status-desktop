import QtQuick 2.13
import QtQuick.Window 2.2
import QtQuick.Controls 2.13
import QtQuick.Layouts 1.13
import QtGraphicalEffects 1.13

import utils 1.0
import shared 1.0
import shared.views.chat 1.0

Popup {
    id: root

    property var store
    property var image
    property string url: ""

    modal: true
    Overlay.modal: Rectangle {
        color: "#40000000"
    }
    parent: Overlay.overlay
    closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutside
    x: Math.round(((parent ? parent.width : 0) - width) / 2)
    y: Math.round(((parent ? parent.height : 0) - height) / 2)
    background: Rectangle {
        color: "transparent"
    }
    padding: 0

    onOpened: {
        messageImage.source = root.image.source;
        const maxHeight = Global.applicationWindow.height - 80
        const maxWidth = Global.applicationWindow.width - 80

        if (root.image.sourceSize.width >= maxWidth || root.image.sourceSize.height >= maxHeight) {
            this.width = maxWidth
            this.height = maxHeight
        } else {
            this.width = image.sourceSize.width
            this.height = image.sourceSize.height
        }
    }

    contentItem: AnimatedImage {
        id: messageImage
        asynchronous: true
        fillMode: Image.PreserveAspectFit
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.verticalCenter: parent.verticalCenter
        mipmap: true
        smooth: false

        onStatusChanged: playing = (status == AnimatedImage.Ready)
        MouseArea {
            anchors.fill: parent
            acceptedButtons: Qt.LeftButton | Qt.RightButton
            onClicked: {
                if (mouse.button === Qt.LeftButton)
                    root.close()
                if (mouse.button === Qt.RightButton)
                    Global.openMenu(imageContextMenu,
                                    messageImage,
                                    { imageSource: messageImage.source, url: root.url})
            }
        }
    }

    Component {
        id: imageContextMenu

        ImageContextMenu {
            onClosed: {
                destroy()
            }
        }
    }
}
