import QtQuick 2.13
import QtQuick.Controls 2.13
import QtQuick.Layouts 1.13
import QtGraphicalEffects 1.13
import "../imports"

Item {
    property string balanceErrorMessage: qsTr("Insufficient balance")
    property string greaterThan0ErrorMessage: qsTr("Must be greater than 0")
    //% "This needs to be a number"
    property string invalidInputErrorMessage: qsTrId("this-needs-to-be-a-number")
    property string noInputErrorMessage: qsTr("Please enter an amount")
    property string defaultCurrency: "USD"
    property alias selectedFiatAmount: txtFiatBalance.text
    property alias selectedAmount: inputAmount.text
    property var selectedAccount
    property alias selectedAsset: selectAsset.selectedAsset
    property var getFiatValue: function () {}
    property var getCryptoValue: function () {}
    property bool isDirty: false

    id: root

    height: inputAmount.height + (inputAmount.validationError ? -16 - inputAmount.validationErrorTopMargin : 0) + txtFiatBalance.height + txtFiatBalance.anchors.topMargin
    anchors.right: parent.right
    anchors.left: parent.left

    function validate(checkDirty) {
        let isValid = true
        let error = ""
        const hasTyped = checkDirty ? isDirty : true
        const balance = parseFloat(txtBalance.text || "0.00")
        const input = parseFloat(inputAmount.text || "0.00")
        const noInput = inputAmount.text === ""
        if (noInput && hasTyped) {
            error = noInputErrorMessage
            isValid = false
        } else if (isNaN(inputAmount.text)) {
            error = invalidInputErrorMessage
            isValid = false
        } else if (input === 0.00 && hasTyped) {
            error = greaterThan0ErrorMessage
            isValid = false
        } else if (input > balance && !noInput) {
            error = balanceErrorMessage
            isValid = false
        }
        if (!isValid) {
            inputAmount.validationError = error
            txtBalanceDesc.color = Style.current.danger
            txtBalance.color = Style.current.danger
        } else {
            inputAmount.validationError = ""
            txtBalanceDesc.color = Style.current.secondaryText
            txtBalance.color = Qt.binding(function() { return txtBalance.hovered ? Style.current.textColor : Style.current.secondaryText })
        }
        return isValid
    }

    onSelectedAccountChanged: {
        if (!selectAsset.selectedAsset) {
            return
        }
        txtBalance.text = Utils.stripTrailingZeros(selectAsset.selectedAsset.value)
    }

    Item {
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
            onTextChanged: {
                root.validate(true)
            }

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
                    inputAmount.text = selectAsset.selectedAsset.value
                    txtFiatBalance.text = root.getFiatValue(inputAmount.text, selectAsset.selectedAsset.symbol, root.defaultCurrency)
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
        Keys.onReleased: {
            root.isDirty = true
            let amount = inputAmount.text.trim()

            if (isNaN(amount)) {
                return
            }
            if (amount === "") {
                txtFiatBalance.text = "0.00"
            } else {
                txtFiatBalance.text = root.getFiatValue(amount, selectAsset.selectedAsset.symbol, root.defaultCurrency)
            }
        }
        onTextChanged: {
            root.validate(true)
        }
    }

    AssetSelector {
        id: selectAsset
        assets: root.selectedAccount.assets
        width: 86
        height: 28
        anchors.top: inputAmount.top
        anchors.topMargin: Style.current.bigPadding + 14
        anchors.right: parent.right
        anchors.rightMargin: Style.current.smallPadding
        onSelectedAssetChanged: {
            txtBalance.text = Utils.stripTrailingZeros(selectAsset.selectedAsset.value)
            if (inputAmount.text === "" || isNan(inputAmount.text)) {
                return
            }
            txtFiatBalance.text = root.getFiatValue(inputAmount.text, selectAsset.selectedAsset.symbol, root.defaultCurrency)
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
                inputAmount.text = root.getCryptoValue(balance, root.defaultCurrency, selectAsset.selectedAsset.symbol)
            }
        }

        StyledText {
            id: txtFiatSymbol
            text: root.defaultCurrency.toUpperCase()
            font.weight: Font.Medium
            font.pixelSize: 12
            color: Style.current.secondaryText
            anchors.top: parent.top
            anchors.left: txtFiatBalance.right
            anchors.leftMargin: 2
        }
    }
}
