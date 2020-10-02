import QtQuick 2.13
import "../../../shared"
import "../../../imports"

ModalPopup {
    id: popup

    property var request: ({
                           "type": "web3-send-async-read-only",
                           "messageId": 13,
                           "payload": {
                             "jsonrpc": "2.0",
                             "id": 19,
                             "method": "eth_sendTransaction",
                             "params": [{
                               "to": "0x2127edab5d08b1e11adf7ae4bae16c2b33fdf74a",
                               "value": "0x9184e72a000",
                               "from": "0x2dcb8515ea98701614919cb82d30876780936a76"
                             }]
                           },
                           "hostname": "ciqhsxa6udhk6tho3smjn4kloo5tb2ly4scv5yrbxgsx6wutijucqdq.infura.status.im",
                           "title": "DAPP"
                         })
    property string fromAccount: request.payload.params[0].from
    property string toAccount: request.payload.params[0].to
    property string value: {
        // TODO get decimals
        let val = utilsModel.wei2Token(request.payload.params[0].value, 18)
        return val
    }

    function postMessage(isAllowed) {
        request.isAllowed = isAllowed;
        provider.web3Response(web3Provider.postMessage(JSON.stringify(request)));
    }

    onClosed: {
        popup.destroy();
    }

    title: qsTr("Confirm transaction")
    height: 600

    property string passwordValidationError: ""
    property bool loading: false

    function validate() {
        if (passwordInput.text === "") {
            //% "You need to enter a password"
            passwordValidationError = qsTrId("you-need-to-enter-a-password")
        } else if (passwordInput.text.length < 4) {
            //% "Password needs to be 4 characters or more"
            passwordValidationError = qsTrId("password-needs-to-be-4-characters-or-more")
        } else {
            passwordValidationError = ""
        }
        return passwordValidationError === ""
    }

    onOpened: {
        passwordInput.text = ""
        passwordInput.forceActiveFocus(Qt.MouseFocusReason)
    }

    Column {
        spacing: Style.current.smallPadding
        width: parent.width

        TextWithLabel {
            label: qsTr("From")
            text: fromAccount
        }

        TextWithLabel {
            label: qsTr("To")
            text: toAccount
        }

        TextWithLabel {
            label: qsTr("Value")
            text: popup.value
        }

        Input {
            id: passwordInput
            //% "Enter your password…"
            placeholderText: qsTrId("enter-your-password…")
            //% "Password"
            label: qsTrId("password")
            textField.echoMode: TextInput.Password
            validationError: popup.passwordValidationError
        }

        GasSelector {
            id: gasSelector
            slowestGasPrice: parseFloat(walletModel.safeLowGasPrice)
            fastestGasPrice: parseFloat(walletModel.fastestGasPrice)
            getGasEthValue: walletModel.getGasEthValue
            getFiatValue: walletModel.getFiatValue
            defaultCurrency: walletModel.defaultCurrency
            width: parent.width
            reset: function() {
                slowestGasPrice = Qt.binding(function(){ return parseFloat(walletModel.safeLowGasPrice) })
                fastestGasPrice = Qt.binding(function(){ return parseFloat(walletModel.fastestGasPrice) })
            }
            property var estimateGas: Backpressure.debounce(gasSelector, 600, function() {
                if (!(fromAccount &&
                    toAccount &&
                      // TODO support asset
//                    txtAmount.selectedAsset && txtAmount.selectedAsset.address &&
                    popup.value)) return

                let gasEstimate = JSON.parse(walletModel.estimateGas(
                    fromAccount,
                    toAccount,
                    // TODO support other assets
                    Constants.zeroAddress,
                    popup.value))

                if (!gasEstimate.success) {
                    //% "Error estimating gas: %1"
                    console.warn(qsTrId("error-estimating-gas---1").arg(gasEstimate.error.message))
                    return
                }
                selectedGasLimit = gasEstimate.result
            })
        }
        // TODO find where to get the assets
//        GasValidator {
//            id: gasValidator
//            selectedAccount: request.payload.params[0].from
//            selectedAmount: parseFloat(txtAmount.selectedAmount)
//            selectedAsset: txtAmount.selectedAsset
//            selectedGasEthValue: gasSelector.selectedGasEthValue
//            reset: function() {
//                selectedAccount = Qt.binding(function() { return selectFromAccount.selectedAccount })
//                selectedAmount = Qt.binding(function() { return parseFloat(txtAmount.selectedAmount) })
//                selectedAsset = Qt.binding(function() { return txtAmount.selectedAsset })
//                selectedGasEthValue = Qt.binding(function() { return gasSelector.selectedGasEthValue })
//            }
//        }
    }

    footer: Item {
        anchors.fill: parent

        StyledButton {
            anchors.top: parent.top
            anchors.left: parent.left
            anchors.leftMargin: Style.current.padding
            label: qsTr("Cancel")
            disabled: loading
            onClicked: {
                // Do we need to send back an error?
                popup.close()
            }
        }

        StyledButton {
            anchors.top: parent.top
            anchors.right: parent.right
            anchors.rightMargin: Style.current.padding
            label: loading ?
            //% "Loading..."
            qsTrId("loading") :
            qsTr("Confirm")

            disabled: loading || passwordInput.text === ""

            onClicked : {
                loading = true
                if (!validate()) {
                    return loading = false
                }

                request.payload.selectedGasLimit = gasSelector.selectedGasLimit
                request.payload.selectedGasPrice = gasSelector.selectedGasPrice
                request.payload.password = passwordInput.text
                request.payload.params[0].value = popup.value
                provider.web3Response(web3Provider.postMessage(JSON.stringify(request)));
                loading = false

                popup.close();
            }
        }
    }
}
