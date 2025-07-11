import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

import StatusQ.Core
import StatusQ.Core.Theme
import StatusQ.Controls
import StatusQ.Controls.Validators
import StatusQ.Components
import StatusQ.Popups

import utils
import shared.panels as SharedPanels

Item {
    id: root

    property BasePopupStore store

    Column {
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.margins: Theme.padding
        spacing: Theme.padding


        StatusBaseText {
            width: parent.width
            text: root.store.isAddAccountPopup? qsTr("Enter recovery phrase") : qsTr("Enter private key for %1 key pair").arg(root.store.selectedKeypair.name)
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
                    let err = qsTr("The entered recovery phrase is already added")
                    if (!root.store.isAddAccountPopup) {
                        err = qsTr("This is not the correct recovery phrase for %1 key").arg(root.store.selectedKeypair.name)
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
            spacing: Theme.halfPadding
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

                validators: [
                    StatusMinLengthValidator {
                        errorMessage: qsTr("Key pair name must be at least %n character(s)", "", Constants.addAccountPopup.keyPairAccountNameMinLength)
                        minLength: Constants.addAccountPopup.keyPairAccountNameMinLength
                    }
                ]

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
