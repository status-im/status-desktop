import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

import StatusQ.Core
import StatusQ.Core.Theme
import StatusQ.Controls
import StatusQ.Controls.Validators

import utils

import "../stores"

Item {
    id: root

    property AddAccountStore store

    implicitHeight: layout.implicitHeight

    ColumnLayout {
        id: layout
        anchors.horizontalCenter: parent.horizontalCenter
        width: parent.width - 2 * Theme.padding
        spacing: Theme.halfPadding

        StatusInput {
            objectName: "AddAccountPopup-GeneratedSeedPhraseKeyName"
            Layout.preferredWidth: parent.width
            Layout.topMargin: Theme.padding
            label: qsTr("Key name")
            charLimit: Constants.addAccountPopup.keyPairNameMaxLength
            placeholderText: qsTr("Enter a name")
            text: root.store.addAccountModule.newKeyPairName

            onTextChanged: {
                if (text.trim() == "") {
                    root.store.addAccountModule.newKeyPairName = ""
                    return
                }
                root.store.addAccountModule.newKeyPairName = text
            }

            onKeyPressed: {
                root.store.submitPopup(event)
            }

            validators: [
                StatusMinLengthValidator {
                    errorMessage: qsTr("Key pair name must be at least %n character(s)", "", Constants.addAccountPopup.keyPairAccountNameMinLength)
                    minLength: Constants.addAccountPopup.keyPairAccountNameMinLength
                }
            ]
        }

        StatusBaseText {
            text: qsTr("For your future reference. This is only visible to you.")
            font.pixelSize: Theme.additionalTextSize
            color: Theme.palette.baseColor1
        }
    }
}
