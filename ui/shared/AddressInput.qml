import QtQuick 2.13
import QtQuick.Controls 2.13
import QtQuick.Layouts 1.13
import QtGraphicalEffects 1.13
import "../imports"

Item {
    id: root
    property string validationError: "Error"
    property alias label: inpAddress.label
    property string selectedAddress

    height: inpAddress.height

    function isValidAddress(inputValue) {
        return /0x[a-fA-F0-9]{40}/.test(inputValue)
    }
    function isValidEns(inputValue) {
        // TODO: Check if the entered value resolves to an address. Long operation.
        // Issue tracked: https://github.com/status-im/nim-status-client/issues/718
        const isEmail = /(?:[a-z0-9!#$%&'*+/=?^_`{|}~-]+(?:\.[a-z0-9!#$%&'*+/=?^_`{|}~-]+)*|"(?:[\x01-\x08\x0b\x0c\x0e-\x1f\x21\x23-\x5b\x5d-\x7f]|\\[\x01-\x09\x0b\x0c\x0e-\x7f])*")@(?:(?:[a-z0-9](?:[a-z0-9-]*[a-z0-9])?\.)+[a-z0-9](?:[a-z0-9-]*[a-z0-9])?|\[(?:(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.){3}(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?|[a-z0-9-]*[a-z0-9]:(?:[\x01-\x08\x0b\x0c\x0e-\x1f\x21-\x5a\x53-\x7f]|\\[\x01-\x09\x0b\x0c\x0e-\x7f])+)\])/.test(inputValue)
        const isDomain = /(?:(?:(?<thld>[\w\-]*)(?:\.))?(?<sld>[\w\-]*))\.(?<tld>[\w\-]*)/.test(inputValue)
        return isEmail || isDomain
    }

    function validate(inputValue) {
        if (!inputValue) inputValue = selectedAddress
        let isValid =
            (inputValue && inputValue.startsWith("0x") && isValidAddress(inputValue)) ||
            isValidEns(inputValue)
        inpAddress.validationError = isValid ? "" : validationError
        return isValid
    }

    Input {
        id: inpAddress
        placeholderText: qsTr("eg. 0x1234 or ENS")
        customHeight: 56
        validationErrorAlignment: TextEdit.AlignRight
        validationErrorTopMargin: 8
        textField.onFocusChanged: {
            let isValid = true
            if (text !== "") {
                isValid = root.validate(metrics.text)
            }
            if (!isValid) {
                return
            }
            if (textField.focus) {
                text = metrics.text
            } else if (root.isValidAddress(metrics.text)) {
                text = metrics.elidedText
            }
        }
        textField.rightPadding: 73
        onTextEdited: {
            metrics.text = text
            const isValid = root.validate(inputValue)
            if (isValid) {
                root.selectedAddress = inputValue
            }
        }
        TextMetrics {
            id: metrics
            elideWidth: 97
            elide: Text.ElideMiddle
        }
        TertiaryButton {
            anchors.right: parent.right
            anchors.rightMargin: 8
            anchors.top: parent.top
            anchors.topMargin: 14
            label: qsTr("Paste")
            onClicked: {
                if (inpAddress.textField.canPaste) {
                    inpAddress.textField.paste()
                }
            }
        }
    }
}



/*##^##
Designer {
    D{i:0;autoSize:true;height:480;width:640}
}
##^##*/
