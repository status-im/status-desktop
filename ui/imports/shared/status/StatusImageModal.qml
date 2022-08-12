import QtQuick 2.13
import QtQuick.Window 2.2
import QtQuick.Controls 2.13
import QtQuick.Layouts 1.13
import QtGraphicalEffects 1.13

import utils 1.0
import shared 1.0

Popup {
    id: root

    signal clicked(var mouse)
    property string imageSource: messageImage.source
    property var contextMenu

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

    function setPopupData(image) {
        messageImage.source = image.source;
        const maxHeight = Global.applicationWindow.height - 80
        const maxWidth = Global.applicationWindow.width - 80


        if (image.sourceSize.width >= maxWidth || image.sourceSize.height >= maxHeight) {
            this.width = maxWidth
            this.height = maxHeight
        } else {
            this.width = image.sourceSize.width
            this.height = image.sourceSize.height
        }
    }

    function openPopup(image) {
        setPopupData(image);
        root.open();
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
                root.clicked(mouse)
            }
        }
    }
}
