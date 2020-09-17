import QtQuick 2.13
import QtQuick.Controls 2.13
import QtQuick.Layouts 1.13
import QtQuick.Dialogs 1.3
import "../../../../../imports"
import "../../../../../shared"
import "../../../../../shared/status"

ModalPopup {
    property string commandTitle: "Send"
    property string finalButtonLabel: "Request address"
    property var sendChatCommand: function () {}
    property bool isRequested: false

    id: root
    title: root.commandTitle
    height: 504

    property alias selectedRecipient: selectRecipient.selectedRecipient

    onClosed: {
        stack.reset()
    }

    TransactionStackView {
        id: stack
        anchors.fill: parent
        anchors.leftMargin: Style.current.padding
        anchors.rightMargin: Style.current.padding
        onGroupActivated: {
            root.title = group.headerText
            btnNext.text = group.footerText
        }
        TransactionFormGroup {
            id: group1
            headerText: root.commandTitle
            //% "Continue"
            footerText: qsTrId("continue")

            AccountSelector {
                id: selectFromAccount
                accounts: walletModel.accounts
                selectedAccount: walletModel.currentAccount
                currency: walletModel.defaultCurrency
                width: stack.width
                //% "From account"
                label: qsTrId("from-account")
                reset: function() {
                    accounts = Qt.binding(function() { return walletModel.accounts })
                    selectedAccount = Qt.binding(function() { return walletModel.currentAccount })
                }
            }
            SeparatorWithIcon {
                id: separator
                anchors.top: selectFromAccount.bottom
                anchors.topMargin: 19
            }
            RecipientSelector {
                id: selectRecipient
                accounts: walletModel.accounts
                contacts: profileModel.addedContacts
                //% "Recipient"
                label: qsTrId("recipient")
                readOnly: true
                anchors.top: separator.bottom
                anchors.topMargin: 10
                width: stack.width
                reset: function() {
                    isValid = true
                }
            }
        }
        TransactionFormGroup {
            id: group2
            headerText: root.commandTitle
            //% "Preview"
            footerText: qsTrId("preview")

            AssetAndAmountInput {
                id: txtAmount
                selectedAccount: selectFromAccount.selectedAccount
                defaultCurrency: walletModel.defaultCurrency
                getFiatValue: walletModel.getFiatValue
                getCryptoValue: walletModel.getCryptoValue
                isRequested: root.isRequested
                width: stack.width
                reset: function() {
                    selectedAccount = Qt.binding(function() { return selectFromAccount.selectedAccount })
                }
            }
        }
        TransactionFormGroup {
            id: group3
            //% "Transaction preview"
            headerText: qsTrId("transaction-preview")
            footerText: root.finalButtonLabel

            TransactionPreview {
                id: pvwTransaction
                width: stack.width
                fromAccount: selectFromAccount.selectedAccount
                toAccount: selectRecipient.selectedRecipient
                asset: txtAmount.selectedAsset
                amount: { "value": txtAmount.selectedAmount, "fiatValue": txtAmount.selectedFiatAmount }
                currency: walletModel.defaultCurrency
                reset: function() {
                    fromAccount = Qt.binding(function() { return selectFromAccount.selectedAccount })
                    toAccount = Qt.binding(function() { return selectRecipient.selectedRecipient })
                    asset = Qt.binding(function() { return txtAmount.selectedAsset })
                    amount = Qt.binding(function() { return { "value": txtAmount.selectedAmount, "fiatValue": txtAmount.selectedFiatAmount } })
                }
            }

            SVGImage {
                width: 16
                height: 16
                source: "../../../../img/warning.svg"
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.bottom: warningText.top
                anchors.bottomMargin: 4
            }

            StyledText {
                id: warningText
                //% "You need to request the recipient’s address first.\nAssets won’t be sent yet."
                text: qsTrId("you-need-to-request-the-recipient-s-address-first--nassets-won-t-be-sent-yet-")
                color: Style.current.danger
                horizontalAlignment: Text.AlignHCenter
                wrapMode: Text.WordWrap
                anchors.right: parent.right
                anchors.left: parent.left
                anchors.bottom: parent.bottom

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
        StatusButton {
            id: btnNext
            anchors.right: parent.right
            //% "Next"
            text: qsTrId("next")
            enabled: stack.currentGroup.isValid && !stack.currentGroup.isPending
            onClicked: {
                const validity = stack.currentGroup.validate()
                if (validity.isValid && !validity.isPending) {
                    if (stack.isLastGroup) {
                        return root.sendChatCommand(selectFromAccount.selectedAccount.address,
                                                    txtAmount.selectedAmount,
                                                    txtAmount.selectedAsset.address,
                                                    txtAmount.selectedAsset.decimals)
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

