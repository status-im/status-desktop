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

    property alias selectRecipient: selectRecipient

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
                label: {
                    return root.isRequested ? 
                        qsTr("Receive on account") : 
                        //% "From account"
                        qsTrId("from-account")
                }
            }
            SeparatorWithIcon {
                id: separator
                anchors.top: selectFromAccount.bottom
                anchors.topMargin: 19
                icon.rotation: root.isRequested ? -90 : 90
            }

            StyledText {
                id: addressRequiredInfo
                anchors.right: selectRecipient.right
                anchors.bottom: selectRecipient.top
                anchors.bottomMargin: -Style.current.padding
                text: qsTr("Address request required")
                color: Style.current.danger
                visible: addressRequiredValidator.isWarn
            }

            RecipientSelector {
                id: selectRecipient
                accounts: walletModel.accounts
                contacts: profileModel.contacts.addedContacts
                label: root.isRequested ?
                  qsTr("From") :
                  qsTr("To")
                anchors.top: separator.bottom
                anchors.topMargin: 10
                width: stack.width
                onSelectedRecipientChanged: {
                    addressRequiredValidator.address = root.isRequested ? selectFromAccount.selectedAccount.address : selectRecipient.selectedRecipient.address
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
                validateBalance: !root.isRequested
                width: stack.width
            }
        }
        TransactionFormGroup {
            id: group3
            headerText: root.isRequested ?
                qsTr("Preview") :
                //% "Transaction preview"
                qsTrId("transaction-preview")
            footerText: root.finalButtonLabel

            TransactionPreview {
                id: pvwTransaction
                width: stack.width
                fromAccount: root.isRequested ? selectRecipient.selectedRecipient : selectFromAccount.selectedAccount
                toAccount: root.isRequested ? selectFromAccount.selectedAccount : selectRecipient.selectedRecipient
                asset: txtAmount.selectedAsset
                amount: { "value": txtAmount.selectedAmount, "fiatValue": txtAmount.selectedFiatAmount }
                toWarn: addressRequiredValidator.isWarn
                currency: walletModel.defaultCurrency
            }

            AddressRequiredValidator {
                id: addressRequiredValidator
                anchors.bottom: parent.bottom
                anchors.bottomMargin: Style.current.padding
            }
        }
    }

    footer: Item {
        width: parent.width
        height: btnNext.height

        StatusRoundButton {
            id: btnBack
            anchors.left: parent.left
            visible: !stack.isFirstGroup
            icon.name: "arrow-right"
            icon.width: 20
            icon.height: 16
            rotation: 180
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

