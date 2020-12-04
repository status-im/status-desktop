import QtQuick 2.13
import QtQuick.Controls 2.13
import QtQuick.Layouts 1.13
import QtGraphicalEffects 1.13
import "../imports"

Popup {
    id: qrCodePopup
    Overlay.modal: Rectangle {
        color: "#60000000"
    }
    parent: Overlay.overlay
    x: Math.round(((parent ? parent.width : 0) - width) / 2)
    y: Math.round(((parent ? parent.height : 0) - height) / 2)
    width: 320
    height: 320
    modal: true
    closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutside
    background: Rectangle {
        color: Style.current.background
        radius: 8
    }
    Rectangle {
        id: closeButton
        height: 32
        width: 32
        anchors.top: parent.top
        anchors.right: parent.right
        property bool hovered: false
        color: hovered ? Style.current.backgroundHover : Style.current.transparent
        radius: 8
        SVGImage {
            id: closeModalImg
            source: "./img/close.svg"
            anchors.verticalCenter: parent.verticalCenter
            anchors.horizontalCenter: parent.horizontalCenter
            width: 11
            height: 11
        }
        ColorOverlay {
            anchors.fill: closeModalImg
            source: closeModalImg
            color: Style.current.textColor
        }
        MouseArea {
            id: closeModalMouseArea
            cursorShape: Qt.PointingHandCursor
            anchors.fill: parent
            hoverEnabled: true
            onExited: {
                closeButton.hovered = false
            }
            onEntered: {
                closeButton.hovered = true
            }
            onClicked: {
                qrCodePopup.close()
            }
        }
    }

}
