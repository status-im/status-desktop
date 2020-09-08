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

    property var selectedRecipient
    onSelectedRecipientChanged: {
        selectRecipient.selectedRecipient = this.selectedRecipient
        selectRecipient.readOnly = !!this.selectedRecipient && !!this.selectedRecipient.address
    }

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
            btnNext.label = group.footerText
        }
        TransactionFormGroup {
            id: group1
            headerText: root.commandTitle
            footerText: qsTr("Continue")

            AccountSelector {
                id: selectFromAccount
                accounts: walletModel.accounts
                selectedAccount: walletModel.currentAccount
                currency: walletModel.defaultCurrency
                width: stack.width
                label: qsTr("From account")
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
                label: qsTr("Recipient")
                readOnly: true
                selectedRecipient: root.selectedRecipient
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
            footerText: qsTr("Preview")

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
            headerText: qsTr("Transaction preview")
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
                text: qsTr("You need to request the recipient’s address first.\nAssets won’t be sent yet.")
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
        StyledButton {
            id: btnNext
            anchors.right: parent.right
            label: qsTr("Next")
            disabled: !stack.currentGroup.isValid
            onClicked: {
                const isValid = stack.currentGroup.validate()

                if (stack.currentGroup.validate()) {
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

