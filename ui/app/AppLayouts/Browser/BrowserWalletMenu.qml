import QtQuick 2.13
import QtQuick.Controls 2.13
import QtGraphicalEffects 1.13
import "../../../shared"
import "../../../shared/status"
import "../../../imports"

Popup {
    id: popup
    modal: false

    closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutside
    parent: Overlay.overlay
    width: 360
    height: 480
    background: Rectangle {
        id: bgPopup
        color: Style.current.background
        radius: Style.current.radius
        layer.enabled: true
        layer.effect: DropShadow{
            width: bgPopup.width
            height: bgPopup.height
            x: bgPopup.x
            y: bgPopup.y + 10
            visible: bgPopup.visible
            source: bgPopup
            horizontalOffset: 0
            verticalOffset: 5
            radius: 10
            samples: 15
            color: "#22000000"
        }
    }
    padding: Style.current.padding

    Item {
        id: walletHeader
        width: parent.width
        height: networkText.height

        Rectangle {
            id: networkColorCircle
            width: 8
            height: 8
            radius: width / 2
            color: Style.current.green
            anchors.verticalCenter: parent.verticalCenter
        }

        StyledText {
            id: networkText
            text: "Mainnet"
            font.pixelSize: 15
            anchors.verticalCenter: parent.verticalCenter
            anchors.left: networkColorCircle.right
            anchors.leftMargin: Style.current.halfPadding
        }

        StyledText {
            id: disconectBtn
            text: "Disconnect"
            font.pixelSize: 15
            anchors.verticalCenter: parent.verticalCenter
            anchors.right: parent.right
            color: Style.current.danger

            MouseArea {
                cursorShape: Qt.PointingHandCursor
                anchors.fill: parent
                onClicked: console.log('Disconnect')

            }
        }
    }
}
