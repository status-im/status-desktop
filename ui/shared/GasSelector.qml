import QtQuick 2.13
import QtQuick.Controls 2.13
import QtQuick.Layouts 1.13
import "../imports"
import "./status"
import "./"

Item {
    id: root
    width: parent.width
    height:  Style.current.smallPadding + prioritytext.height +
             (advancedMode ? advancedModeItemGroup.height : selectorButtons.height)

    property double slowestGasPrice: 0
    property double fastestGasPrice: 100
    property double stepSize: ((root.fastestGasPrice - root.slowestGasPrice) / 10).toFixed(1)
    property var getGasEthValue: function () {}
    property var getFiatValue: function () {}
    property string defaultCurrency: "USD"
    property alias selectedGasPrice: inputGasPrice.text
    property alias selectedGasLimit: inputGasLimit.text
    property double selectedGasEthValue
    property double selectedGasFiatValue
    //% "Must be greater than 0"
    property string greaterThan0ErrorMessage: qsTrId("must-be-greater-than-0")
    //% "This needs to be a number"
    property string invalidInputErrorMessage: qsTrId("this-needs-to-be-a-number")
    //% "Please enter an amount"
    property string noInputErrorMessage: qsTrId("please-enter-an-amount")
    property bool isValid: true
    readonly property string uuid: Utils.uuid()

    property bool advancedMode: false

    function updateGasEthValue() {
        // causes error on application load without this null check
        if (!inputGasPrice || !inputGasLimit) {
            return
        }
        let ethValue = root.getGasEthValue(inputGasPrice.text, inputGasLimit.text)
        let fiatValue = root.getFiatValue(ethValue, "ETH", root.defaultCurrency)

        selectedGasEthValue = ethValue
        selectedGasFiatValue = fiatValue
    }

    Component.onCompleted: updateGasEthValue()

    function validate() {
        // causes error on application load without a null check
        if (!inputGasLimit || !inputGasPrice) {
            return
        }
        inputGasLimit.validationError = ""
        inputGasPrice.validationError = ""
        const noInputLimit = inputGasLimit.text === ""
        const noInputPrice = inputGasPrice.text === ""
        if (noInputLimit) {
            inputGasLimit.validationError = root.noInputErrorMessage
        }
        if (noInputPrice) {
            inputGasPrice.validationError = root.noInputErrorMessage
        }
        if (isNaN(inputGasLimit.text)) {
            inputGasLimit.validationError = invalidInputErrorMessage
        }
        if (isNaN(inputGasPrice.text)) {
            inputGasPrice.validationError = invalidInputErrorMessage
        }
        let inputLimit = parseFloat(inputGasLimit.text || "0.00")
        let inputPrice = parseFloat(inputGasPrice.text || "0.00")
        if (inputLimit === 0.00) {
            inputGasLimit.validationError = root.greaterThan0ErrorMessage
        }
        if (inputPrice === 0.00) {
            inputGasPrice.validationError = root.greaterThan0ErrorMessage
        }
        const isValid = inputGasLimit.validationError === "" && inputGasPrice.validationError === ""
        return isValid
    }


    StyledText {
        id: prioritytext
        anchors.top: parent.top
        anchors.left: parent.left
        text: qsTr("Priority")
        font.weight: Font.Medium
        font.pixelSize: 13
        color: Style.current.textColor
    }

    StatusButton {
        id: buttonAdvanced
        anchors.verticalCenter: prioritytext.verticalCenter
        anchors.right: parent.right
        text: advancedMode ? qsTr("Use suggestions") : qsTr("Use custom")
        flat: true
        font.pixelSize: 13
        onClicked: advancedMode = !advancedMode
    }

    Row {
        id: selectorButtons
        visible: !advancedMode
        anchors.top: prioritytext.bottom
        anchors.topMargin: Style.current.halfPadding
        spacing: 11

        ButtonGroup {
            id: gasGroup
            onClicked: updateGasEthValue()
        }

        GasSelectorButton {
            buttonGroup: gasGroup
            text: qsTr("Low")
            price: slowestGasPrice
            gasLimit: inputGasLimit ? inputGasLimit.text : ""
            getGasEthValue: root.getGasEthValue
            getFiatValue: root.getFiatValue
            defaultCurrency: root.defaultCurrency
            onChecked: inputGasPrice.text = price
        }
        GasSelectorButton {
            id: optimalGasButton
            buttonGroup: gasGroup
            checkedByDefault: true
            text: qsTr("Optimal")
            price: (fastestGasPrice + slowestGasPrice) / 2
            gasLimit: inputGasLimit ? inputGasLimit.text : ""
            getGasEthValue: root.getGasEthValue
            getFiatValue: root.getFiatValue
            defaultCurrency: root.defaultCurrency
            onChecked: inputGasPrice.text = price
        }

        GasSelectorButton {
            buttonGroup: gasGroup
            text: qsTr("High")
            price: fastestGasPrice
            gasLimit: inputGasLimit ? inputGasLimit.text : ""
            getGasEthValue: root.getGasEthValue
            getFiatValue: root.getFiatValue
            defaultCurrency: root.defaultCurrency
            onChecked: inputGasPrice.text = price
        }
    }

    Item {
        id: advancedModeItemGroup
        anchors.top: prioritytext.bottom
        anchors.topMargin: 14
        visible: root.advancedMode
        width: parent.width
        height: childrenRect.height

        Input {
            id: inputGasLimit
            label: qsTr("Gas amount limit")
            text: "21000"
            customHeight: 56
            anchors.top: parent.top
            anchors.left: parent.left
            anchors.right: inputGasPrice.left
            anchors.rightMargin: Style.current.padding
            placeholderText: "21000"
            validationErrorAlignment: TextEdit.AlignRight
            validationErrorTopMargin: 8
            onTextChanged: {
                if (root.validate()) {
                    root.updateGasEthValue()
                }
            }
        }

        Input {
            id: inputGasPrice
            label: qsTr("Per-gas overall limit")
            anchors.top: parent.top
            anchors.left: undefined
            anchors.right: parent.right
            width: 130
            customHeight: 56
            text: optimalGasButton.price
            placeholderText: "20"
            onTextChanged: {
                if (root.validate()) {
                    root.updateGasEthValue()
                }
            }
        }

        StyledText {
            color: Style.current.secondaryText
            //% "Gwei"
            text: qsTrId("gwei")
            anchors.top: parent.top
            anchors.topMargin: 42
            anchors.right: inputGasPrice.right
            anchors.rightMargin: Style.current.padding
            font.pixelSize: 15
        }

        StyledText {
            id: maxPriorityFeeText
            text: qsTr("Maximum priority fee: %1 ETH").arg(selectedGasEthValue)
            anchors.top: inputGasLimit.bottom
            anchors.topMargin: 19
            font.pixelSize: 13
        }

        StyledText {
            id: maxPriorityFeeFiatText
            text: `${selectedGasFiatValue} ${root.defaultCurrency}`
            anchors.verticalCenter: maxPriorityFeeText.verticalCenter
            anchors.left: maxPriorityFeeText.right
            anchors.leftMargin: 6
            color: Style.current.secondaryText
            anchors.topMargin: 19
            font.pixelSize: 13
        }

        StyledText {
            id: maxPriorityFeeDetailsText
            text: qsTr("Maximum overall price for the transaction. If the block base fee exceeds this, it will be included in a following block with a lower base fee.")
            width: parent.width
            anchors.top: maxPriorityFeeText.bottom
            anchors.topMargin: Style.current.smallPadding
            font.pixelSize: 13
            color: Style.current.secondaryText
            wrapMode: Text.WordWrap
        }
    }
}
