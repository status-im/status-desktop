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
    property var selectedGasLimit
    property var selectedGasPrice

    id: root

    //% "Send"
    title: qsTrId("command-button-send")
    height: 504

    property MessageDialog sendingError: MessageDialog {
        id: sendingError
        title: qsTr("Error sending the transaction")
        icon: StandardIcon.Critical
        standardButtons: StandardButton.Ok
    }
    property MessageDialog sendingSuccess: MessageDialog {
        id: sendingSuccess
        //% "Success sending the transaction"
        title: qsTrId("success-sending-the-transaction")
        icon: StandardIcon.NoIcon
        standardButtons: StandardButton.Ok
        onAccepted: {
            root.close()
        }
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
            if (response.error.includes("could not decrypt key with given password")){
                transactionSigner.validationError = qsTr("Wrong password")
                return
            }
            sendingError.text = response.error
            return sendingError.open()
        }

        sendingSuccess.text = qsTr("Transaction sent to the blockchain. You can watch the progress on Etherscan: %2/%1").arg(response.result).arg(walletModel.etherscanLink)
        sendingSuccess.open()
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
            headerText: qsTr("Send")
            footerText: qsTr("Preview")

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
            }
        }
        TransactionFormGroup {
            id: group2
            headerText: qsTr("Transaction preview")
            footerText: qsTr("Sign with password")

            TransactionPreview {
                id: pvwTransaction
                width: stack.width
                fromAccount: root.selectedAccount
                gas: {
                    const value = walletModel.getGasEthValue(gasSelector.selectedGasPrice, gasSelector.selectedGasLimit)
                    const fiatValue = walletModel.getFiatValue(value, "ETH", walletModel.defaultCurrency)
                    return { value, "symbol": "ETH", fiatValue }
                }
                toAccount: root.selectedRecipient
                asset: root.selectedAsset
                amount: { "value": root.selectedAmount, "fiatValue": root.selectedFiatAmount }
                currency: walletModel.defaultCurrency
                reset: function() {}
            }
        }
        TransactionFormGroup {
            id: group3
            headerText: qsTr("Sign with password")
            footerText: qsTr("Send %1 %2").arg(root.selectedAmount).arg(!!root.selectedAsset ? root.selectedAsset.symbol : "")

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
                color: btnBack.disabled ? Style.current.grey :
                        btnBack.hovered ? Qt.darker(btnBack.btnColor, 1.1) : btnBack.btnColor

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
            label: qsTr("Next")
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

