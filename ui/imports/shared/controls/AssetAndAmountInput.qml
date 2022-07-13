import QtQuick 2.13
import QtQuick.Controls 2.13
import QtQuick.Layouts 1.13
import QtGraphicalEffects 1.13

import utils 1.0
import shared.stores 1.0

import StatusQ.Controls 0.1

import "../"
import "../panels"
import "."

Item {
    id: root
    property string balanceErrorMessage: qsTr("Insufficient balance")
    property string greaterThanOrEqualTo0ErrorMessage: qsTr("Must be greater than or equal to 0")
    property string invalidInputErrorMessage: qsTr("This needs to be a number")
    property string noInputErrorMessage: qsTr("Please enter an amount")
    property string currentCurrency: "USD"
    property alias selectedFiatAmount: txtFiatBalance.text
    property alias selectedAmount: inputAmount.text
    property var selectedAccount
    property alias selectedAsset: selectAsset.selectedAsset
    property var getFiatValue: function () {}
    property var getCryptoValue: function () {}
    property bool isDirty: false
    property bool validateBalance: true
    property bool isValid: false
    property string validationError
    property var formattedInputValue

    height: inputAmount.height + (inputAmount.validationError ? -16 - inputAmount.validationErrorTopMargin : 0) + txtFiatBalance.height + txtFiatBalance.anchors.topMargin
    anchors.right: parent.right
    anchors.left: parent.left

    function validate(checkDirty) {
        let isValid = true
        let error = ""
        const hasTyped = checkDirty ? isDirty : true
        const balance = parseFloat(txtBalance.text || "0.00")
        formattedInputValue = parseFloat(inputAmount.text || "0.00")
        const noInput = inputAmount.text === ""
        if (noInput && hasTyped) {
            error = noInputErrorMessage
            isValid = false
        } else if (isNaN(inputAmount.text)) {
            error = invalidInputErrorMessage
            isValid = false
        } else if (formattedInputValue < 0.00 && hasTyped) {
            error = greaterThanOrEqualTo0ErrorMessage
            isValid = false
        } else if (validateBalance && formattedInputValue > balance && !noInput) {
            error = balanceErrorMessage
            isValid = false
        }
        if (!isValid) {
            root.validationError = error
            txtBalanceDesc.color = Style.current.danger
            txtBalance.color = Style.current.danger
        } else {
            root.validationError = ""
            txtBalanceDesc.color = Style.current.secondaryText
            txtBalance.color = Qt.binding(function() { return txtBalance.hovered ? Style.current.textColor : Style.current.secondaryText })
        }
        root.isValid = isValid
        return isValid
    }

    onSelectedAccountChanged: {
        selectAsset.assets = Qt.binding(function() {
            if (selectedAccount) {
                return selectedAccount.assets
            }
        })
        txtBalance.text = Qt.binding(function() {
            return selectAsset.selectedAsset ? Utils.stripTrailingZeros(selectAsset.selectedAsset.value) : ""
        })
    }

    Item {
        visible: root.validateBalance
        anchors.right: parent.right
        anchors.left: parent.left
        anchors.top: parent.top
        height: txtBalanceDesc.height

        StyledText {
            id: txtBalanceDesc
            text: qsTr("Balance: ")
            anchors.right: txtBalance.left
            font.weight: Font.Medium
            font.pixelSize: 13
            color: Style.current.secondaryText
        }

        StyledText {
            id: txtBalance
            property bool hovered: false
            text: selectAsset.selectedAsset ? Utils.stripTrailingZeros(selectAsset.selectedAsset.value) : "0.00"
            anchors.right: parent.right
            font.weight: Font.Medium
            font.pixelSize: 13
            color: hovered ? Style.current.textColor : Style.current.secondaryText

            MouseArea {
                cursorShape: Qt.PointingHandCursor
                anchors.fill: parent
                hoverEnabled: true
                onExited: {
                    txtBalance.hovered = false
                }
                onEntered: {
                    txtBalance.hovered = true
                }
                onClicked: {
                    inputAmount.text = Utils.stripTrailingZeros(selectAsset.selectedAsset.value)
                    txtFiatBalance.text = root.getFiatValue(inputAmount.text, selectAsset.selectedAsset.symbol, root.currentCurrency)
                }
            }
        }
    }

    Input {
        id: inputAmount
        label: qsTr("Asset & Amount")
        placeholderText: "0.00"
        anchors.top: parent.top
        customHeight: 56
        validationErrorAlignment: TextEdit.AlignRight
        validationErrorTopMargin: 8
        validationErrorColor: formattedInputValue === 0 ? Style.current.warning : Style.current.danger
        validationError: {
            if (root.validationError) {
                return root.validationError
            }
            if (formattedInputValue === 0) {
                return qsTr("The amount is 0. Proceed only if this is desired.")
            }
            return ""
        }

        Keys.onReleased: {
            let amount = inputAmount.text.trim()

            if (isNaN(amount)) {
                return
            }
            if (amount === "") {
                txtFiatBalance.text = "0.00"
            } else {
                txtFiatBalance.text = root.getFiatValue(amount, selectAsset.selectedAsset.symbol, root.currentCurrency)
            }
        }
        onTextChanged: {
            root.isDirty = true
            root.validate(true)
        }
    }

    StatusAssetSelector {
         id: selectAsset
         height: 28
         anchors.top: inputAmount.top
         anchors.topMargin: Style.current.bigPadding + 14
         anchors.right: parent.right
         anchors.rightMargin: Style.current.smallPadding
         defaultToken: Style.png("tokens/DEFAULT-TOKEN@3x")
         getCurrencyBalanceString: function (currencyBalance) {
             return Utils.toLocaleString(currencyBalance.toFixed(2), RootStore.locale, {"currency": true}) + " " + root.currentCurrency.toUpperCase()
         }
         tokenAssetSourceFn: function (symbol) {
             return symbol ? Style.png("tokens/" + symbol) : defaultToken
         }
         onSelectedAssetChanged: {
             if (!selectAsset.selectedAsset) {
                 return
             }
             txtBalance.text = Utils.stripTrailingZeros(parseFloat(selectAsset.selectedAsset.balance).toFixed(4))
             if (inputAmount.text === "" || isNaN(inputAmount.text)) {
                 return
             }
            txtFiatBalance.text = root.getFiatValue(inputAmount.text, selectAsset.selectedAsset.symbol, root.currentCurrency)
            root.validate(true)
        }
    }

    Item {
        height: txtFiatBalance.height
        anchors.left: parent.left
        anchors.top: inputAmount.bottom
        anchors.topMargin: inputAmount.validationError ? -16 : inputAmount.validationErrorTopMargin

        StyledTextField {
            id: txtFiatBalance
            anchors.left: parent.left
            anchors.top: parent.top
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
                inputAmount.text = root.getCryptoValue(balance, root.currentCurrency, selectAsset.selectedAsset.symbol)
            }
        }

        StyledText {
            id: txtFiatSymbol
            text: root.currentCurrency.toUpperCase()
            font.weight: Font.Medium
            font.pixelSize: 12
            color: Style.current.secondaryText
            anchors.top: parent.top
            anchors.left: txtFiatBalance.right
            anchors.leftMargin: 2
        }
    }
}
