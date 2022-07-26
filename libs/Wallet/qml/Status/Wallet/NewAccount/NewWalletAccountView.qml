import QtQuick
import QtQuick.Layouts
import QtQuick.Controls

import Status.Wallet
import Status.Onboarding
import Status.Containers

Item {
    id: root

    // Using the type NewWalletAccountController generates "/bin/sh: line 1: 12832 Segmentation fault: 11  qmlcachegen --resource-path /Status/Wallet/qml/Status/Wallet/NewAccount/NewWalletAccountView.qml"
    required property var controller

    signal accountCreated()
    signal cancel()

    implicitWidth: mainLayout.implicitWidth
    implicitHeight: mainLayout.implicitHeight

    QtObject {
        id: d

        property bool errorRetrievingDerivationAddresses: false

        function updateDerivedAddresses() {
            errorRetrievingDerivationAddresses = !root.controller.retrieveAndUpdateDerivedAddresses(passwordInput.text, derivedFromCombo.currentValue)
        }
    }

    Component.onCompleted: d.updateDerivedAddresses()

    ColumnLayout {
        id: mainLayout

        anchors.fill: parent

        Label {
            text: "Name"

            Layout.margins: 5
        }
        TempTextInput {
            id: nameInput

            text: "Test Account"

            Layout.fillWidth: true
            Layout.margins: 5
        }

        Label {
            text: "Password"
            Layout.margins: 5
        }
        TempTextInput {
            id: passwordInput

            text: "1234567890"

            Layout.fillWidth: true
            Layout.margins: 5

            onTextChanged: d.updateDerivedAddresses()
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

        Label {
            text: "Derivation Path"
            Layout.margins: 5
        }
        TempTextInput {
            id: pathInput
            text: root.controller.derivationPath
            onTextChanged: root.controller.derivationPath = text

            Layout.fillWidth: true
            Layout.margins: 5
        }

        Label {
            text: "Account"
            Layout.margins: 5
        }

        ColumnLayout {
            Layout.margins: 5

            Label {
                id: derivationPathsError
                text: qsTr("<Check password and path!>")
                visible: d.errorRetrievingDerivationAddresses
            }

            ColumnLayout {
                ComboBox {
                    id: derivedAddressCombo

                    visible: !root.controller.customDerivationPath && !d.errorRetrievingDerivationAddresses

                    model: root.controller.currentDerivedAddressModel
                    textRole: "derivedAddress.address"
                    valueRole: "derivedAddress"
                    onCurrentValueChanged: root.controller.selectedDerivedAddress = currentValue

                    currentIndex: root.controller.derivedAddressIndex

                    Layout.fillWidth: true
                    Layout.margins: 5

                    clip: true

                    delegate: ItemDelegate {
                            width: derivedAddressCombo.width
                            enabled: !derivedAddress.alreadyCreated
                            contentItem: Text {
                                text: derivedAddress.address
                                color: derivedAddress.alreadyCreated
                                        ? "blue"
                                        : (derivedAddress === root.controller.selectedDerivedAddress) ? "green" : "black"
                                font: derivedAddressCombo.font
                                elide: Text.ElideRight
                                verticalAlignment: Text.AlignVCenter
                            }
                            highlighted: derivedAddressCombo.highlightedIndex === index

                            required property DerivedWalletAddress derivedAddress
                            required property int index
                    }
                }
                Label {
                    text: qsTr("Custom Derivation Path")
                    visible: root.controller.customDerivationPath
                }
            }
        }

        Label {
            text: "Origin"
            Layout.margins: 5
        }

        ComboBox {
            id: derivedFromCombo

            model: root.controller.mainAccountsModel
            textRole: "account.name"
            valueRole: "account"

            currentIndex: 0

            Layout.fillWidth: true
            Layout.margins: 5

            delegate: ItemDelegate {
                    width: derivedFromCombo.width
                    contentItem: Text {
                        text: account.name
                        color: account.color
                        font: derivedFromCombo.font
                        elide: Text.ElideRight
                        verticalAlignment: Text.AlignVCenter
                    }
                    highlighted: derivedFromCombo.highlightedIndex === index

                    required property WalletAccount account
                    required property int index
            }
        }

        RowLayout {
            Button {
                text: qsTr("Create")

                enabled: nameInput.text.length > 5 && passwordInput.text.length > 5
                         && pathInput.text.length > 0

                onClicked: root.controller.createAccountAsync(passwordInput.text, nameInput.text,
                                                         colorCombo.currentValue, pathInput.text,
                                                         derivedFromCombo.currentValue);
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
