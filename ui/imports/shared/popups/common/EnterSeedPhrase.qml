import QtQuick 2.14
import QtQuick.Controls 2.14
import QtQuick.Layouts 1.14

import StatusQ.Core 0.1
import StatusQ.Core.Theme 0.1
import StatusQ.Controls 0.1
import StatusQ.Controls.Validators 0.1
import StatusQ.Components 0.1
import StatusQ.Popups 0.1

import utils 1.0
import shared.panels 1.0 as SharedPanels

Item {
    id: root

    property BasePopupStore store

    Column {
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.margins: Style.current.padding
        spacing: Style.current.padding


        StatusBaseText {
            width: parent.width
            text: root.store.isAddAccountPopup? qsTr("Enter seed phrase") : qsTr("Enter private key for %1 keypair").arg(root.store.selectedKeypair.name)
            font.pixelSize: Constants.addAccountPopup.labelFontSize1
            elide: Text.ElideRight
        }

        SharedPanels.EnterSeedPhrase {
            id: enterSeedPhrase
            width: parent.width

            isSeedPhraseValid: function(mnemonic) {
                return root.store.validSeedPhrase(mnemonic)
            }

            onSeedPhraseUpdated: {
                if (valid) {
                    root.store.changeSeedPhrase(seedPhrase)
                }
                root.store.enteredSeedPhraseIsValid = valid
                if (!enterSeedPhrase.isSeedPhraseValid(seedPhrase)) {
                    let err = qsTr("The entered seed phrase is already added")
                    if (!root.store.isAddAccountPopup) {
                        err = qsTr("This is not the correct seed  phrase for %1 key").arg(root.store.selectedKeypair.name)
                    }
                    enterSeedPhrase.setWrongSeedPhraseMessage(err)
                }
            }

            onSubmitSeedPhrase: {
                root.store.submitPopup()
            }
        }

        StatusModalDivider {
            width: parent.width
            visible: root.store.isAddAccountPopup && root.store.enteredSeedPhraseIsValid
        }

        Column {
            width: parent.width
            spacing: Style.current.halfPadding
            visible: root.store.isAddAccountPopup && root.store.enteredSeedPhraseIsValid

            StatusInput {
                objectName: "AddAccountPopup-ImportedSeedPhraseKeyName"
                width: parent.width
                label: qsTr("Key name")
                charLimit: Constants.addAccountPopup.keyPairNameMaxLength
                placeholderText: qsTr("Enter a name")
                text: root.store.isAddAccountPopup? root.store.addAccountModule.newKeyPairName : ""

                onTextChanged: {
                    if (!root.store.isAddAccountPopup) {
                        return
                    }
                    if (text.trim() == "") {
                        root.store.addAccountModule.newKeyPairName = ""
                        return
                    }
                    root.store.addAccountModule.newKeyPairName = text
                }

                onKeyPressed: {
                    root.store.submitPopup(event)
                }
            }

            StatusBaseText {
                text: qsTr("For your future reference. This is only visible to you.")
                font.pixelSize: Constants.addAccountPopup.labelFontSize2
                color: Theme.palette.baseColor1
            }
        }
    }
}
