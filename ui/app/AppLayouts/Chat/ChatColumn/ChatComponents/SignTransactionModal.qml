import QtQuick 2.13
import QtQuick.Controls 2.13
import QtQuick.Layouts 1.13
import QtQuick.Dialogs 1.3
import "../../../../../imports"
import "../../../../../shared"
import "../../../../../shared/status"

ModalPopup {
    property var selectedAccount
    property var selectedRecipient
    property var selectedAsset
    property var selectedAmount
    property var selectedFiatAmount

    id: root

    //% "Send"
    title: qsTrId("command-button-send")
    height: 504

    property MessageDialog sendingError: MessageDialog {
        id: sendingError
        //% "Error sending the transaction"
        title: qsTrId("error-sending-the-transaction")
        icon: StandardIcon.Critical
        standardButtons: StandardButton.Ok
    }

    onClosed: {
        stack.reset()
    }

    function sendTransaction() {
        let responseStr = walletModel.sendTransaction(root.selectedAccount.address,
                                                 root.selectedRecipient.address,
                                                 root.selectedAsset.address,
                                                 root.selectedAmount,
                                                 gasSelector.selectedGasLimit,
                                                 gasSelector.selectedGasPrice,
                                                 transactionSigner.enteredPassword)
        let response = JSON.parse(responseStr)

        if (response.error) {
            if (response.result.includes("could not decrypt key with given password")){
                //% "Wrong password"
                transactionSigner.validationError = qsTrId("wrong-password")
                return
            }
            sendingError.text = response.result
            return sendingError.open()
        }
        root.close()
    }

    TransactionStackView {
        id: stack
        anchors.fill: parent
        anchors.leftMargin: Style.current.padding
        anchors.rightMargin: Style.current.padding
        onGroupActivated: {
            root.title = group.headerText
            btnNext.label = group.footerText
        }
        TransactionFormGroup {
            id: group1
            //% "Send"
            headerText: qsTrId("command-button-send")
            //% "Preview"
            footerText: qsTrId("preview")

            GasSelector {
                id: gasSelector
                anchors.topMargin: Style.current.bigPadding
                slowestGasPrice: parseFloat(walletModel.safeLowGasPrice)
                fastestGasPrice: parseFloat(walletModel.fastestGasPrice)
                getGasEthValue: walletModel.getGasEthValue
                getFiatValue: walletModel.getFiatValue
                defaultCurrency: walletModel.defaultCurrency
                width: stack.width
                reset: function() {
                    slowestGasPrice = Qt.binding(function(){ return parseFloat(walletModel.safeLowGasPrice) })
                    fastestGasPrice = Qt.binding(function(){ return parseFloat(walletModel.fastestGasPrice) })
                }

                function estimateGas() {
                    if (!(root.selectedAccount && root.selectedAccount.address &&
                        root.selectedRecipient && root.selectedRecipient.address &&
                        root.selectedAsset && root.selectedAsset.address &&
                        root.selectedAmount)) return

                    let gasEstimate = JSON.parse(walletModel.estimateGas(
                        root.selectedAccount.address,
                        root.selectedRecipient.address,
                        root.selectedAsset.address,
                        root.selectedAmount))

                    if (!gasEstimate.success) {
                        //% "Error estimating gas: %1"
                        console.warn(qsTrId("error-estimating-gas---1").arg(gasEstimate.error.message))
                        return
                    }
                    selectedGasLimit = gasEstimate.result
                }
            }
            GasValidator {
                id: gasValidator
                anchors.bottom: parent.bottom
                anchors.bottomMargin: 8
                selectedAccount: root.selectedAccount
                selectedAmount: parseFloat(root.selectedAmount)
                selectedAsset: root.selectedAsset
                selectedGasEthValue: gasSelector.selectedGasEthValue
                reset: function() {
                    selectedGasEthValue = Qt.binding(function() { return gasSelector.selectedGasEthValue })
                }
            }
        }
        TransactionFormGroup {
            id: group2
            //% "Transaction preview"
            headerText: qsTrId("transaction-preview")
            //% "Sign with password"
            footerText: qsTrId("sign-with-password")

            TransactionPreview {
                id: pvwTransaction
                width: stack.width
                fromAccount: root.selectedAccount
                gas: {
                    "value": gasSelector.selectedGasEthValue,
                    "symbol": "ETH",
                    "fiatValue": gasSelector.selectedGasFiatValue
                }
                toAccount: root.selectedRecipient
                asset: root.selectedAsset
                amount: { "value": root.selectedAmount, "fiatValue": root.selectedFiatAmount }
                currency: walletModel.defaultCurrency
                reset: function() {
                    gas = Qt.binding(function() {
                        return {
                            "value": gasSelector.selectedGasEthValue,
                            "symbol": "ETH",
                            "fiatValue": gasSelector.selectedGasFiatValue
                        }
                    })
                }
            }
        }
        TransactionFormGroup {
            id: group3
            //% "Sign with password"
            headerText: qsTrId("sign-with-password")
            //% "Send %1 %2"
            footerText: qsTrId("send--1--2").arg(root.selectedAmount).arg(!!root.selectedAsset ? root.selectedAsset.symbol : "")

            TransactionSigner {
                id: transactionSigner
                width: stack.width
                signingPhrase: walletModel.signingPhrase
                reset: function() {
                    signingPhrase = Qt.binding(function() { return walletModel.signingPhrase })
                }
            }
        }
    }

    footer: Item {
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.right: parent.right
        StyledButton {
            id: btnBack
            anchors.left: parent.left
            width: 44
            height: 44
            visible: !stack.isFirstGroup
            label: ""
            background: Rectangle {
                anchors.fill: parent
                border.width: 0
                radius: width / 2
                color: btnBack.hovered ? Qt.darker(btnBack.btnColor, 1.1) : btnBack.btnColor

                SVGImage {
                    width: 20.42
                    height: 15.75
                    anchors.horizontalCenter: parent.horizontalCenter
                    anchors.verticalCenter: parent.verticalCenter
                    fillMode: Image.PreserveAspectFit
                    source: "../../../../img/arrow-right.svg"
                    rotation: 180
                }
            }
            onClicked: {
                stack.back()
            }
        }
        StyledButton {
            id: btnNext
            anchors.right: parent.right
            //% "Next"
            label: qsTrId("next")
            disabled: !stack.currentGroup.isValid
            onClicked: {
                const isValid = stack.currentGroup.validate()

                if (stack.currentGroup.validate()) {
                    if (stack.isLastGroup) {
                        return root.sendTransaction()
                    }
                    stack.next()
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

