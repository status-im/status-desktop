import QtQuick 2.15
import QtGraphicalEffects 1.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

import shared.controls 1.0

import StatusQ.Core.Theme 0.1
import StatusQ.Controls 0.1

StatusButton {
    id: root

    property int menuWidth: 312

    signal connectDapp()

    implicitHeight: 38

    size: StatusBaseButton.Size.Small

    borderColor: Theme.palette.directColor7
    normalColor: Theme.palette.transparent
    hoverColor: Theme.palette.baseColor2
    textPosition: StatusBaseButton.TextPosition.Left
    textColor: Theme.palette.baseColor1

    icon.name: "dapp"
    icon.height: 16
    icon.width: 16
    icon.color: hovered ? Theme.palette.directColor1 : Theme.palette.baseColor1

    highlighted: popup.opened

    onClicked: {
        if (popup.opened) {
            popup.close()
            return
        }
        popup.x = width - root.menuWidth - 2 * popup.padding
        popup.y = height + 4
        popup.open()
    }

    Popup {
        id: popup

        objectName: "dappsPopup"

        contentWidth: root.menuWidth
        contentHeight: list.height
        modal: false
        padding: 8
        closePolicy: Popup.CloseOnEscape | Popup.CloseOnOutsideClick | Popup.CloseOnPressOutside

        background: Rectangle {
            id: bckgContent
            color: Theme.palette.statusMenu.backgroundColor
            radius: 8
            layer.enabled: true
            layer.effect: DropShadow {
                anchors.fill: parent
                source: bckgContent
                horizontalOffset: 0
                verticalOffset: 4
                radius: 12
                samples: 25
                spread: 0.2
                color: Theme.palette.dropShadow
            }
        }

        ColumnLayout {
            id: list
            anchors.left: parent.left
            anchors.right: parent.right
            width: parent.width
            spacing: 8

            ShapeRectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: implicitHeight
                text: qsTr("Connected dApps will appear here")
            }

            StatusButton {
                Layout.fillWidth: true
                Layout.preferredHeight: implicitHeight

                text: qsTr("Connect a dApp via WalletConnect")
                onClicked: {
                    root.connectDapp()
                    popup.close()
                }
            }
        }
    }
}
