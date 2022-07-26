import QtQuick
import QtQuick.Layouts
import QtQuick.Controls

import Status.Wallet

import Status.Onboarding

import Status.Containers

Item {
    id: root

    required property NewWalletAccountController controller

    signal accountCreated()
    signal cancel()

    implicitWidth: mainLayout.implicitWidth
    implicitHeight: mainLayout.implicitHeight

    ColumnLayout {
        id: mainLayout

        anchors.fill: parent

        Label {
            text: "Name"
            Layout.margins: 5
        }
        TempTextInput {
            id: nameInput

            text: "Test Watch Account"

            Layout.fillWidth: true
            Layout.margins: 5
        }
        Label {
            text: "Address"
            Layout.margins: 5
        }
        TempTextInput {
            id: addressInput

            text: "0xdb5ac1a559b02e12f29fc0ec0e37be8e046def49"

            Layout.fillWidth: true
            Layout.margins: 5
        }

        Label {
            text: "Color"
            Layout.margins: 5
        }

        TmpColorComboBox {
            id: colorCombo

            Layout.fillWidth: true
            Layout.margins: 5
        }

        RowLayout {
            Button {
                text: qsTr("Add Watch Only Account")

                enabled: nameInput.text.length > 5 && addressInput.text.length > 22 && addressInput.text.startsWith("0x")

                onClicked: controller.addWatchOnlyAccountAsync(addressInput.text, nameInput.text,
                                                         colorCombo.currentValue);
                Layout.margins: 5
            }
            Button {
                text: qsTr("V")
                onClicked: root.cancel()
                Layout.margins: 5
            }
        }
    }
}
