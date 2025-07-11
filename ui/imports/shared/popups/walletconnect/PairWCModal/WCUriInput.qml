import QtQuick
import QtQml
import QtQuick.Controls
import QtQuick.Layouts

import StatusQ.Core
import StatusQ.Popups
import StatusQ.Controls
import StatusQ.Components
import StatusQ.Core.Theme

import AppLayouts.Wallet.services.dapps.types

ColumnLayout {
    id: root

    readonly property bool valid: input.valid && input.text.length > 0
    readonly property alias text: input.text
    property alias pending: input.pending
    property int errorState: Pairing.errors.notChecked

    StatusBaseInput {
        id: input

        Component.onCompleted: {
            forceActiveFocus()
        }

        Layout.fillWidth: true
        Layout.preferredHeight: 132

        placeholderText: qsTr("Paste URI")
        verticalAlignment: TextInput.AlignTop

        valid: {
            let uri = input.text

            errorText.text = ""
            if(uri.length === 0) {
                return true
            }

            if(root.errorState === Pairing.errors.tooCool) {
                errorText.text = qsTr("WalletConnect URI too cool")
            } else if(root.errorState === Pairing.errors.invalidUri) {
                errorText.text = qsTr("WalletConnect URI invalid")
            } else if(root.errorState === Pairing.errors.alreadyUsed) {
                errorText.text = qsTr("WalletConnect URI already used")
            } else if(root.errorState === Pairing.errors.expired) {
                errorText.text = qsTr("WalletConnect URI has expired")
            } else if(root.errorState === Pairing.errors.unsupportedNetwork) {
                errorText.text = qsTr("dApp is requesting to connect on an unsupported network")
            } else if(root.errorState === Pairing.errors.unknownError) {
                errorText.text = qsTr("Unexpected error occurred. Try again.")
            }

            if (errorText.text.length > 0) {
                return false
            }

            return true
        }

        rightComponent: Item {
            width: pasteButton.implicitWidth
            height: pasteButton.implicitHeight

            readonly property bool showIcon: input.valid && input.text.length > 0

            StatusLoadingIndicator {
                anchors.centerIn: parent
                color: Theme.palette.blue
                visible: showIcon && input.pending
            }

            StatusIcon {
                anchors.centerIn: parent

                icon: "tiny/tiny-checkmark"
                color: Theme.palette.green
                visible: showIcon && !input.pending
            }

            StatusButton {
                id: pasteButton

                text: qsTr("Paste")

                size: StatusBaseButton.Size.Small

                visible: !showIcon

                borderWidth: enabled ? 1 : 0
                borderColor: textColor

                enabled: input.edit.canPaste

                onClicked: {
                    input.edit.paste()
                    input.edit.focus = true
                }
            }
        }

        multiline: true
    }

    StatusBaseText {
        id: errorText

        visible: !input.valid && input.text.length !== 0

        Layout.alignment: Qt.AlignRight

        color: Theme.palette.dangerColor1
    }
}
