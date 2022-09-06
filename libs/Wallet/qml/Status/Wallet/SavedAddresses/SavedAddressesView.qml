import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

import Status.Wallet
import Status.Containers

Item {
    id: root

    required property SavedAddressesController savedAddressesController

    ListView {
        id: list
        anchors.fill: parent
        model: SavedAddressesController.savedAddresses

        delegate: RowLayout {
            width: list.width
            spacing: 0

            Label {
                text: savedAddress.address
                Layout.fillWidth: true
            }

            Label {
                text: savedAddress.name
                Layout.fillWidth: true
            }
        }
    }

    RoundButton {
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.bottom: parent.bottom
        text: "+"
        onClicked: addView.open()

        AddSavedAddressesView {
            id: addView
            y: parent.height - height
            savedAddressesController: root.savedAddressesController
        }
    }
}
