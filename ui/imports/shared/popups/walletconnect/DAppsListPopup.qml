import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQml.Models 2.15
import QtQuick.Layouts 1.15
import QtGraphicalEffects 1.15

import StatusQ.Core 0.1
import StatusQ.Core.Theme 0.1
import StatusQ.Controls 0.1
import StatusQ.Components 0.1

import shared.controls 1.0

Popup {
    id: root

    objectName: "dappsPopup"

    required property DelegateModel delegateModel

    signal pairWCDapp()

    width: 312

    modal: false
    padding: 8
    closePolicy: Popup.CloseOnEscape | Popup.CloseOnOutsideClick | Popup.CloseOnPressOutside

    background: Rectangle {
        id: backgroundContent

        color: Theme.palette.statusMenu.backgroundColor
        radius: 8
        layer.enabled: true
        layer.effect: DropShadow {
            anchors.fill: parent
            source: backgroundContent
            horizontalOffset: 0
            verticalOffset: 4
            radius: 12
            samples: 25
            spread: 0.2
            color: Theme.palette.dropShadow
        }
    }

    contentItem: ColumnLayout {
        id: mainLayout

        spacing: 8

        ShapeRectangle {
            id: listPlaceholder

            text: qsTr("Connected dApps will appear here")

            Layout.fillWidth: true
            Layout.preferredHeight: implicitHeight

            visible: listView.count === 0
        }

        Item {
            Layout.fillWidth: true
            Layout.preferredHeight: 32
            Layout.leftMargin: 8

            visible: !listPlaceholder.visible

            StatusBaseText {
                text: qsTr("Connected dApps")

                anchors.left: parent.left
                anchors.verticalCenter: parent.verticalCenter

                font.pixelSize: 12
                color: Theme.palette.baseColor1
            }
        }

        StatusListView {
            id: listView

            Layout.fillWidth: true
            Layout.preferredHeight: contentHeight
            Layout.maximumHeight: 280

            model: root.delegateModel
            visible: !listPlaceholder.visible

            ScrollBar.vertical: null
        }

        StatusButton {
            objectName: "connectDappButton"
            Layout.fillWidth: true
            Layout.preferredHeight: implicitHeight

            text: qsTr("Connect a dApp via WalletConnect")
            onClicked: {
                root.pairWCDapp()
            }
        }
    }
}
