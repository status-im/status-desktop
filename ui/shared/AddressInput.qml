import QtQuick 2.13
import QtQuick.Controls 2.13
import QtQuick.Layouts 1.13
import QtGraphicalEffects 1.13
import "../imports"
import "../shared"

Item {
    id: root
    property string validationError: "Error"
    property string ensAsyncValidationError: qsTr("ENS Username not found")
    property alias label: inpAddress.label
    property string selectedAddress
    property var isValid: false
    property bool isPending: false

    height: inpAddress.height

    function resetInternal() {
        selectedAddress = ""
        inpAddress.resetInternal()
        metrics.text = ""
        isValid = false
    }

    function validate(inputValue) {
        if (!inputValue) inputValue = selectedAddress
        let isValid =
            (inputValue && inputValue.startsWith("0x") && Utils.isValidAddress(inputValue) || Utils.isValidEns(inputValue))
        inpAddress.validationError = isValid ? "" : validationError
        root.isValid = isValid
        return isValid
    }

    property var validateAsync: Backpressure.debounce(inpAddress, 300, function (inputValue) {
        root.isPending = true
        var name = inputValue.startsWith("@") ? inputValue.substring(1) : inputValue
        walletModel.resolveENS(name)
    });


    Connections {
        target: walletModel
        onEnsWasResolved: {
            root.isPending = false
            if (resolvedPubKey === ""){
                inpAddress.validationError = root.ensAsyncValidationError
                root.isValid = false
            } else {
                root.isValid = true
                root.selectedAddress = resolvedPubKey
                inpAddress.validationError = ""
            }
        }
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
            if (text !== "") {
                isValid = root.validate(metrics.text)
            }
            if (!isValid) {
                return
            }
            if (textField.focus) {
                text = metrics.text
            } else if (Utils.isValidAddress(metrics.text)) {
                text = metrics.elidedText
            }
        }
        textField.rightPadding: 73
        onTextEdited: {
            metrics.text = text
            const isValid = root.validate(inputValue)
            if (isValid) {
              if (Utils.isValidAddress(inputValue)) {
                root.selectedAddress = inputValue
              } else {
                Qt.callLater(root.validateAsync, inputValue)
              }
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
            //% "Paste"
            label: qsTrId("paste")
            onClicked: {
                if (inpAddress.textField.canPaste) {
                    inpAddress.textField.paste()
                }
            }
        }
    }

    Loader {
        sourceComponent: loadingIndicator
        anchors.top: inpAddress.bottom
        anchors.right: inpAddress.right
        anchors.topMargin: Style.current.halfPadding
        active: root.isPending
    }

    Component {
        id: loadingIndicator
        LoadingImage {
            width: 12
            height: 12
        }
    }
}



/*##^##
Designer {
    D{i:0;autoSize:true;height:480;width:640}
}
##^##*/
