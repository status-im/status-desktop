import QtQuick 2.13
import QtQuick.Controls 2.13
import QtQuick.Layouts 1.13
import QtQuick.Dialogs 1.3

import utils 1.0
import shared.controls 1.0

import StatusQ.Core 0.1
import StatusQ.Core.Theme 0.1
import StatusQ.Popups 0.1
import StatusQ.Controls 0.1

import shared.views 1.0
import shared.panels 1.0

StatusModal {
    property var store
    property string commandTitle: "Send"
    property string finalButtonLabel: "Request address"
    property var sendChatCommand: function () {}
    property bool isRequested: false

    id: root
    anchors.centerIn: parent
    header.title: root.commandTitle
    height: 504

    property alias selectRecipient: selectRecipient

    contentItem: Item {
        width: root.width
        height: childrenRect.height
        TransactionStackView {
            id: stack
            anchors.top: parent.top
            anchors.topMargin: 16
            anchors.leftMargin: Style.current.padding
            anchors.rightMargin: Style.current.padding

            onGroupActivated: {
                root.header.title = group.headerText
                btnNext.text = group.footerText
            }
            TransactionFormGroup {
                id: group1
                headerText: root.commandTitle
                //% "Continue"
                footerText: qsTrId("continue")

                StatusAccountSelector {
                    id: selectFromAccount
                    accounts: root.store.walletModelInst.accountsView.accounts
                    selectedAccount: {
                        const currAcc = root.store.walletModelInst.accountsView.currentAccount
                        if (currAcc.walletType !== Constants.watchWalletType) {
                            return currAcc
                        }
                        return null
                    }
                    currency: root.store.walletModelInst.balanceView.defaultCurrency
                    width: stack.width
                    label: {
                        return root.isRequested ? 
                            //% "Receive on account"
                            qsTrId("receive-on-account") : 
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

                StatusBaseText {
                    id: addressRequiredInfo
                    anchors.right: selectRecipient.right
                    anchors.bottom: selectRecipient.top
                    anchors.bottomMargin: -Style.current.padding
                    //% "Address request required"
                    text: qsTrId("address-request-required")
                    color: Theme.palette.dangerColor1
                    visible: addressRequiredValidator.isWarn
                }

                RecipientSelector {
                    id: selectRecipient
                    accounts: root.store.walletModelInst.accountsView.accounts
                    contacts: root.store.addedContacts
                    label: root.isRequested ?
                      //% "From"
                      qsTrId("from") :
                      //% "To"
                      qsTrId("to")
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
                    defaultCurrency: root.store.walletModelInst.balanceView.defaultCurrency
                    getFiatValue: root.store.walletModelInst.balanceView.getFiatValue
                    getCryptoValue: root.store.walletModelInst.balanceView.getCryptoValue
                    validateBalance: !root.isRequested
                    width: stack.width
                }
            }
            TransactionFormGroup {
                id: group3
                headerText: root.isRequested ?
                    //% "Preview"
                    qsTrId("preview") :
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
                    currency: walletModel.balanceView.defaultCurrency
                }

                AddressRequiredValidator {
                    id: addressRequiredValidator
                    anchors.bottom: parent.bottom
                    anchors.bottomMargin: Style.current.padding
                }
            }
        }
    }

    leftButtons: [
        StatusRoundButton {
            visible: !stack.isFirstGroup
            icon.name: "arrow-right"
            icon.width: 20
            icon.height: 16
            rotation: 180
            onClicked: {
                stack.back()
            }
        }
    ]

    rightButtons: [
        StatusButton {
            id: btnNext
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
    ]
}

/*##^##
Designer {
    D{i:0;autoSize:true;height:480;width:640}
}
##^##*/

