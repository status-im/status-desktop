import QtQuick 2.13
import QtQuick.Controls 2.13
import QtQuick.Layouts 1.13
import StatusQ.Controls.Validators 0.1

import utils 1.0

import StatusQ.Controls 0.1
import StatusQ.Popups 0.1
import StatusQ.Components 0.1
import StatusQ.Core 0.1
import StatusQ.Core.Theme 0.1

import "../controls"
import "../views"

Rectangle {
    id: header

    property alias accountSelector: accountSelector
    property alias recipientSelector: recipientSelector
    property alias amountToSendInput: amountToSendInput
    property alias assetSelector: assetSelector

    property var store
    property var contactsStore
    property var estimateGas: function() {}
    property bool isReady: amountToSendInput.valid && !amountToSendInput.pending && recipientSelector.isValid && !recipientSelector.isPending

    signal assetChanged()
    signal selectedAccountChanged()
    signal amountToSendChanged()

    QtObject {
        id: _internal
        property string maxFiatBalance: Utils.stripTrailingZeros(parseFloat(assetSelector.selectedAsset.totalBalance).toFixed(4))
        //% "Please enter a valid amount"
        property string sendAmountInputErrorMessage: qsTr("Please enter a valid amount")
        //% "Max:"
        property string maxString: qsTr("Max: ")
    }

    radius: 8

    color: Theme.palette.statusModal.backgroundColor
    width: parent.width
    height: headerLayout.height + Style.current.xlPadding + (!!recipientSelector.input.text && recipientSelector.input.hasValidSearchResult ? 70 : 0)

    Rectangle {
        id: border
        anchors.bottom: parent.bottom
        width: parent.width
        height: parent.radius
        color: parent.color

        StatusModalDivider {
            anchors.bottom: parent.bottom
            width: parent.width
        }
    }

    ColumnLayout {
        id: headerLayout
        spacing: 8
        width: parent.width
        anchors.top: parent.top
        anchors.leftMargin: Style.current.xlPadding
        anchors.rightMargin: Style.current.xlPadding
        anchors.topMargin: Style.current.padding
        anchors.left: parent.left
        anchors.right: parent.right

        StatusAccountSelector {
            id: accountSelector
            accounts: header.store.accounts
            selectedAccount: {
                const currAcc = header.store.currentAccount
                if (currAcc.walletType !== Constants.watchWalletType) {
                    return currAcc
                }
                return null
            }
            currency: header.store.currentCurrency
            width: parent.width
            label:  ""
            onSelectedAccountChanged: {
                assetSelector.assets = Qt.binding(function() {
                    if (selectedAccount) {
                        return selectedAccount.assets
                    }
                })
                if (isValid) { estimateGas() }
                header.selectedAccountChanged()
            }
            showAccountDetails: false
            selectField.select.height: 32
        }
        ColumnLayout {
            id: assetAndAmmountSelector
            RowLayout {
                spacing: 16
                StatusBaseText {
                    //% "Send"
                    text: qsTrId("command-button-send")
                    font.pixelSize: 15
                    color: Theme.palette.directColor1
                    Layout.alignment: Qt.AlignVCenter
                }
                StatusListItemTag {
                    //% "No balances active"
                    title: assetSelector.selectedAsset.totalBalance > 0 ? _internal.maxString + (assetSelector.selectedAsset ? _internal.maxFiatBalance : "0.00") : qsTr("No balances active")
                    closeButtonVisible: false
                    titleText.font.pixelSize: 12
                    height: 22
                }
            }
            Item {
                Layout.fillWidth: true
                Layout.preferredHeight: childrenRect.height
                AmountInputWithCursor {
                    id: amountToSendInput
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.left: parent.left
                    width: parent.width - assetSelector.width
                    input.placeholderText: "0.00" + " " + assetSelector.selectedAsset.symbol
                    errorMessageCmp.anchors.rightMargin: -100
                    validators: [
                        StatusFloatValidator{
                            id: floatValidator
                            bottom: 0
                            top: _internal.maxFiatBalance
                            errorMessage: _internal.sendAmountInputErrorMessage
                        }
                    ]
                    Keys.onReleased: {
                        let amount = amountToSendInput.text.trim()

                        if (isNaN(amount)) {
                            return
                        }
                        if (amount === "") {
                            txtFiatBalance.text = "0.00"
                        } else {
                            txtFiatBalance.text = header.store.getFiatValue(amount, assetSelector.selectedAsset.symbol, header.store.currentCurrency)
                        }
                        estimateGas()
                        header.amountToSendChanged()
                    }
                }
                StatusAssetSelector {
                    id: assetSelector
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.right: parent.right
                    defaultToken: Style.png("tokens/DEFAULT-TOKEN@3x")
                    getCurrencyBalanceString: function (currencyBalance) {
                        return Utils.toLocaleString(currencyBalance.toFixed(2), header.store.locale, {"currency": true}) + " " + header.store.currentCurrency.toUpperCase()
                    }
                    tokenAssetSourceFn: function (symbol) {
                        return symbol ? Style.png("tokens/" + symbol) : defaultToken
                    }
                    onSelectedAssetChanged: {
                        if (!assetSelector.selectedAsset) {
                            return
                        }
                        if (amountToSendInput.text === "" || isNaN(amountToSendInput.text)) {
                            return
                        }
                        txtFiatBalance.text = header.store.getFiatValue(amountToSendInput.text, assetSelector.selectedAsset.symbol, header.store.currentCurrency)
                        estimateGas()
                        header.assetChanged()
                    }
                }
            }
            RowLayout {
                StyledTextField {
                    id: txtFiatBalance
                    color: txtFiatBalance.activeFocus ? Style.current.textColor : Style.current.secondaryText
                    font.weight: Font.Medium
                    font.pixelSize: 12
                    inputMethodHints: Qt.ImhFormattedNumbersOnly
                    text: "0.00"
                    selectByMouse: true
                    background: Rectangle {
                        color: Style.current.transparent
                    }
                    padding: 0
                    Keys.onReleased: {
                        let balance = txtFiatBalance.text.trim()
                        if (balance === "" || isNaN(balance)) {
                            return
                        }
                        // To-Do Not refactored yet
                        // amountToSendInput.text = root.getCryptoValue(balance, header.store.currentCurrency, assetSelector.selectedAsset.symbol)
                    }
                }
                StatusBaseText {
                    id: currencyText
                    text: header.store.currentCurrency.toUpperCase()
                    font.pixelSize: 13
                    color: Theme.palette.directColor5
                }
            }
        }

        // To-do use standard StatusInput component once the flow for ens name resolution is clear
        RecipientSelector {
            id: recipientSelector
            accounts: header.store.accounts
            contactsStore: header.contactsStore
            //% To
            label: qsTr("To")
            Layout.fillWidth: true
            //% "Enter an ENS name or address"
            input.placeholderText: qsTr("Enter an ENS name or address")
            input.anchors.leftMargin: 0
            input.anchors.rightMargin: 0
            labelFont.pixelSize: 15
            labelFont.weight: Font.Normal
            input.height: 56
            isSelectorVisible: false
            addContactEnabled: false
            onSelectedRecipientChanged: estimateGas()
        }
    }
}

