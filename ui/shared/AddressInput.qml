import QtQuick 2.13
import QtQuick.Controls 2.13
import QtQuick.Layouts 1.13
import QtGraphicalEffects 1.13
import "../imports"
import "../shared"

Item {
    id: root
    property string validationError: "Error"
    //% "ENS Username not found"
    property string ensAsyncValidationError: qsTrId("ens-username-not-found")
    property alias label: inpAddress.label
    property alias text: inpAddress.text
    property string selectedAddress
    property var isValid: false
    property alias isPending: ensResolver.isPending
    property alias readOnly: inpAddress.readOnly
    property bool isResolvedAddress: false

    height: inpAddress.height

    onSelectedAddressChanged: validate()
    onTextChanged: {
        metrics.text = text
        root.isResolvedAddress = false
        if (Utils.isValidAddress(text)) {
            root.selectedAddress = text
        } else {
            root.selectedAddress = ""
            root.validate()
        }
        ensResolver.resolveEns(text)
    }

    function resetInternal() {
        selectedAddress = ""
        inpAddress.resetInternal()
        metrics.text = ""
        isValid = false
        isPending = false
        isResolvedAddress = false
    }

    function validate() {
        let isValidEns = Utils.isValidEns(text)
        let isValidAddress = Utils.isValidAddress(selectedAddress)
        let isValid = (isValidEns && !isResolvedAddress) || isPending || isValidAddress
        inpAddress.validationError = ""
        if (!isValid){ 
            inpAddress.validationError = isResolvedAddress ? ensAsyncValidationError : validationError
        }
        root.isValid = isValid
        return isValid
    }

    Input {
        id: inpAddress
        //% "eg. 0x1234 or ENS"
        placeholderText: qsTrId("eg--0x1234-or-ens")
        customHeight: 56
        validationErrorAlignment: TextEdit.AlignRight
        validationErrorTopMargin: 8
        textField.onFocusChanged: {
            let isValid = true
            if (text !== "" && Utils.isValidAddress(metrics.text)) {
                if (textField.focus) {
                    text = metrics.text
                } else {
                    text = metrics.elidedText
                }
            }
        }
        textField.rightPadding: 73
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
            visible: !root.readOnly
            //% "Paste"
            label: qsTrId("paste")
            onClicked: {
                if (inpAddress.textField.canPaste) {
                    inpAddress.textField.paste()
                }
            }
        }
    }

    EnsResolver {
        id: ensResolver
        anchors.top: inpAddress.bottom
        anchors.right: inpAddress.right
        anchors.topMargin: Style.current.halfPadding
        debounceDelay: root.readOnly ? 0 : 600
        onResolved: {
            root.isResolvedAddress = true
            root.selectedAddress = resolvedAddress
            root.validate()
        }
        onIsPendingChanged: {
            if (isPending) {
                root.selectedAddress = ""
            }
        }
    }
}



/*##^##
Designer {
    D{i:0;autoSize:true;height:480;width:640}
}
##^##*/
