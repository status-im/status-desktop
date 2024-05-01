import QtQuick 2.15
import QtQml 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

import StatusQ.Core 0.1
import StatusQ.Popups 0.1
import StatusQ.Controls 0.1
import StatusQ.Core.Theme 0.1

ColumnLayout {
    id: root

    readonly property bool valid: input.valid && input.text.length > 0
    readonly property alias text: input.text

    StatusBaseInput {
        id: input

        Layout.fillWidth: true
        Layout.preferredHeight: 132

        placeholderText: qsTr("Paste URI")

        verticalAlignment: TextInput.AlignTop

        valid: {
            let uri = input.text

            if(uri.length === 0) {
                errorText.text = ""
                return true
            }

            if(containsOnlyEmoji(uri)) {
                errorText.text = qsTr("WalletConnect URI too cool")
                return false
            } else if(!validURI(uri)) {
                errorText.text = qsTr("WalletConnect URI invalid")
                return false
            } else if(wcUriAlreadyUsed(uri)) {
                errorText.text = qsTr("WalletConnect URI already used")
                return false
            } else if(wcUriExpired(uri)) {
                errorText.text = qsTr("WalletConnect URI has expired")
                return false
            }

            errorText.text = ""
            return true
        }

        function validURI(uri) {
            var regex = /^wc:[0-9a-fA-F-]*@([1-9][0-9]*)(\?([a-zA-Z-]+=[^&]+)(&[a-zA-Z-]+=[^&]+)*)?$/
            return regex.test(uri)
        }

        function containsOnlyEmoji(uri) {
            var emojiRegex = new RegExp("[\\u203C-\\u3299\\u1F000-\\u1F644]");
            return !emojiRegex.test(uri);
        }

        function wcUriAlreadyUsed(uri) {
            // TODO: Check if URI is already used
            return false
        }

        function wcUriExpired(uri) {
            // TODO: Check if URI is expired
            return false
        }

        rightComponent: Item {
            width: pasteButton.implicitWidth
            height: pasteButton.implicitHeight

            readonly property bool showIcon: input.valid && input.text.length > 0

            StatusIcon {
                anchors.centerIn: parent

                icon: "tiny/tiny-checkmark"
                color: Theme.palette.green
                visible: showIcon
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
