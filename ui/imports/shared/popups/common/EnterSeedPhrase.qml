import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

import StatusQ.Core
import StatusQ.Core.Theme
import StatusQ.Controls
import StatusQ.Controls.Validators
import StatusQ.Components
import StatusQ.Popups

import shared
import utils
import shared.panels as SharedPanels

ColumnLayout {
    id: root

    property BasePopupStore store

    spacing: Theme.padding

    StatusBaseText {
        Layout.fillWidth: true
        Layout.topMargin: Theme.padding
        Layout.leftMargin: Theme.padding
        Layout.rightMargin: Theme.padding

        text: root.store.isAddAccountPopup? qsTr("Enter recovery phrase") : qsTr("Enter private key for %1 key pair").arg(root.store.selectedKeypair.name)
        elide: Text.ElideRight
    }

    SharedPanels.EnterSeedPhrase {
        id: enterSeedPhrase

        Layout.fillWidth: true
        Layout.leftMargin: Theme.padding
        Layout.rightMargin: Theme.padding
        Layout.bottomMargin: keyNameColumn.visible ? 0 : Theme.padding

        dictionary: BIP39_en {}

        onSeedPhraseChanged: {
            root.store.enteredSeedPhraseIsValid = false
        }

        onSeedPhraseProvided: seedPhrase => {
            const seedPhraseStr = seedPhrase.join(" ")
            const valid = root.store.validSeedPhrase(seedPhraseStr)

            if (valid)
                root.store.changeSeedPhrase(seedPhraseStr)

            root.store.enteredSeedPhraseIsValid = valid

            if (valid) {
                setError("")
                return
            }

            const err = root.store.isAddAccountPopup
                                  ? qsTr("The entered recovery phrase is already added")
                                  : qsTr("This is not the correct recovery phrase for %1 key").arg(root.store.selectedKeypair.name)
            setError(err)
        }

        onSeedPhraseAccepted: {
            root.store.submitPopup()
        }
    }

    StatusModalDivider {
        Layout.fillWidth: true
        Layout.leftMargin: Theme.padding
        Layout.rightMargin: Theme.padding

        visible: root.store.isAddAccountPopup && root.store.enteredSeedPhraseIsValid
    }

    ColumnLayout {
        id: keyNameColumn

        Layout.leftMargin: Theme.padding
        Layout.rightMargin: Theme.padding

        spacing: Theme.halfPadding
        visible: root.store.isAddAccountPopup && root.store.enteredSeedPhraseIsValid

        StatusInput {
            objectName: "AddAccountPopup-ImportedSeedPhraseKeyName"
            Layout.fillWidth: true

            label: qsTr("Key name")
            charLimit: Constants.addAccountPopup.keyPairNameMaxLength
            placeholderText: qsTr("Enter a name")
            text: root.store.isAddAccountPopup? root.store.addAccountModule.newKeyPairName : ""

            onTextChanged: {
                if (!root.store.isAddAccountPopup) {
                    return
                }
                if (text.trim() === "") {
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
            Layout.fillWidth: true
            Layout.bottomMargin: Theme.padding

            text: qsTr("For your future reference. This is only visible to you.")
            font.pixelSize: Theme.additionalTextSize
            color: Theme.palette.baseColor1
            wrapMode: Text.Wrap
        }
    }
}
