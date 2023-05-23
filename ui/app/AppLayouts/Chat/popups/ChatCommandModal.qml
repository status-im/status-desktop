import QtQuick 2.13
import QtQuick.Controls 2.13
import QtQuick.Layouts 1.13

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
    property var contactsStore

    property string commandTitle: qsTr("Send")
    property string finalButtonLabel: qsTr("Request address")
    property var sendChatCommand: function () {}
    property bool isRequested: false

    id: root
    anchors.centerIn: parent
    headerSettings.title: root.commandTitle
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
                root.headerSettings.title = group.headerText
                btnNext.text = group.footerText
            }
            TransactionFormGroup {
                id: group1
                headerText: root.commandTitle
                footerText: qsTr("Continue")

                StatusAccountSelector {
                    id: selectFromAccount
                    accounts: root.store.accounts
                    selectedAccount: {
                        const currAcc = root.store.currentAccount
                        if (currAcc.walletType !== Constants.watchWalletType) {
                            return currAcc
                        }
                        return null
                    }
                    currency: root.store.currentCurrency
                    width: stack.width
                    label: {
                        return root.isRequested ?
                            qsTr("Receive on account") :
                            qsTr("From account")
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
                    text: qsTr("Address request required")
                    color: Theme.palette.dangerColor1
                    visible: addressRequiredValidator.isWarn
                }

                RecipientSelector {
                    id: selectRecipient
                    accounts: root.store.accounts
                    contactsStore: root.contactsStore
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
                footerText: qsTr("Preview")

                AssetAndAmountInput {
                    id: txtAmount
                    selectedAccount: selectFromAccount.selectedAccount
                    currentCurrency: root.store.currentCurrency
                    getFiatValue: root.store.getFiatValue
                    // Not Refactored Yet
//                    getCryptoValue: root.store.walletModelInst.balanceView.getCryptoValue
                    validateBalance: !root.isRequested
                    width: stack.width
                }
            }
            TransactionFormGroup {
                id: group3
                headerText: root.isRequested ?
                    qsTr("Preview") :
                    qsTr("Transaction preview")
                footerText: root.finalButtonLabel

                TransactionPreview {
                    id: pvwTransaction
                    width: stack.width
                    fromAccount: root.isRequested ? selectRecipient.selectedRecipient : selectFromAccount.selectedAccount
                    toAccount: root.isRequested ? selectFromAccount.selectedAccount : selectRecipient.selectedRecipient
                    asset: txtAmount.selectedAsset
                    amount: { "value": txtAmount.selectedAmount, "fiatValue": txtAmount.selectedFiatAmount }
                    toWarn: addressRequiredValidator.isWarn
                    currency: root.store.currentCurrency
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
        StatusBackButton {
            visible: !stack.isFirstGroup
            onClicked: {
                stack.back()
            }
        }
    ]

    rightButtons: [
        StatusButton {
            id: btnNext
            text: qsTr("Next")
            enabled: stack.currentGroup.isValid && !stack.currentGroup.isPending
            onClicked: {
                const validity = stack.currentGroup.validate()
                if (validity.isValid && !validity.isPending) {
                    if (stack.isLastGroup) {
                        root.sendChatCommand(selectFromAccount.selectedAccount.address,
                                                    txtAmount.selectedAmount,
                                                    txtAmount.selectedAsset.symbol,
                                                    txtAmount.selectedAsset.decimals)
                        return root.close()
                    }
                    stack.next()
                }
            }
        }
    ]
}

