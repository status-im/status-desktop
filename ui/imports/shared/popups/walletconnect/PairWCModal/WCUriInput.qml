import QtQuick 2.15
import QtQml 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

import StatusQ.Core 0.1
import StatusQ.Popups 0.1
import StatusQ.Controls 0.1
import StatusQ.Components 0.1
import StatusQ.Core.Theme 0.1

import AppLayouts.Wallet.services.dapps.types 1.0

ColumnLayout {
    id: root

    readonly property bool valid: input.valid && input.text.length > 0
    readonly property alias text: input.text
    property alias pending: input.pending
    property int errorState: Pairing.uriErrors.notChecked

    StatusBaseInput {
        id: input

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

            if(root.errorState === Pairing.uriErrors.tooCool) {
                errorText.text = qsTr("WalletConnect URI too cool")
            } else if(root.errorState === Pairing.uriErrors.invalidUri) {
                errorText.text = qsTr("WalletConnect URI invalid")
            } else if(root.errorState === Pairing.uriErrors.alreadyUsed) {
                errorText.text = qsTr("WalletConnect URI already used")
            } else if(root.errorState === Pairing.uriErrors.expired) {
                errorText.text = qsTr("WalletConnect URI has expired")
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
