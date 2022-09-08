import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

import Status.Wallet
import Status.Containers

Item {
    id: root

    required property SavedAddressesController savedAddressesController

    Component.onCompleted: savedAddressesController.refresh()

    ListView {
        id: list
        anchors.fill: parent
        model: savedAddressesController.savedAddresses

        header: RowLayout {
            width: list.width
            spacing: 0

            Label {
                text: qsTr("Address")
                horizontalAlignment: Text.AlignHCenter
                font.bold: true
                Layout.fillWidth: true
            }

            Label {
                text: qsTr("Name")
                horizontalAlignment: Text.AlignHCenter
                font.bold: true
                Layout.fillWidth: true
            }
        }

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
            x: (parent.width - width) / 2
            y: parent.height - height
            savedAddressesController: root.savedAddressesController
        }
    }
}
