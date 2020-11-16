import QtQuick 2.13
import QtQuick.Window 2.2
import QtQuick.Controls 2.13
import QtQuick.Layouts 1.13
import QtGraphicalEffects 1.13
import "../../imports"
import "../../shared"

Popup {
    id: root
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
        messageImage.source = image;

        let maxHeight = applicationWindow.height - 80
        let maxWidth = applicationWindow.width - 80

        if (messageImage.sourceSize.width >= maxWidth || messageImage.sourceSize.height >= maxHeight) {
            this.width = maxWidth
            this.height = maxHeight
        } else {
            this.width = messageImage.sourceSize.width
            this.height = messageImage.sourceSize.height
        }
    }

    function openPopup(image) {
        setPopupData(image);
        root.open();
    }

    contentItem: Image {
        id: messageImage
        asynchronous: true
        fillMode: Image.PreserveAspectFit
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.verticalCenter: parent.verticalCenter
        mipmap: true
        smooth: false
    }
}
