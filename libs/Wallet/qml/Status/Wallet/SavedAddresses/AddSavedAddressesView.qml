import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

import Status.Wallet
import Status.Containers

Popup {
    id: root

    required property SavedAddressesController savedAddressesController

    width: 300

    GridLayout {
        anchors.fill: parent
        columns: 2

        Label {
            text: qsTr("Address")
            Layout.fillWidth: true
        }

        TextField {
            id: addressFiled
            Layout.fillWidth: true
        }

        Label {
            text: qsTr("Name")
            Layout.fillWidth: true
        }

        TextField {
            id: nameFiled
            Layout.fillWidth: true
        }

        Button {
            text: qsTr("Confirm")
            enabled: addressFiled.text.length && nameFiled.text.length
            onClicked: {
                savedAddressesController.saveAddress(addressFiled.text, nameFiled.text);
                addressFiled.clear();
                nameFiled.clear();
                root.close();
            }
            GridLayout.columnSpan: 2
            Layout.fillWidth: true
        }
    }
}
