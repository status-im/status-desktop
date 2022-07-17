import QtQuick 2.13
import QtQuick.Controls 2.13
import QtQuick.Layouts 1.13

import utils 1.0
import shared.panels 1.0
import shared.controls 1.0
import shared.controls.chat 1.0
import StatusQ.Controls 0.1
import StatusQ.Components 0.1

Item {
    id: root
    width: parent.width
    height:  visible ? Style.current.smallPadding + prioritytext.height +
             (advancedMode ? advancedModeItemGroup.height : selectorButtons.height) : 0

    property var suggestedFees: ({
        eip1559Enabled: true
    })
    property var getGasGweiValue: function () {}
    property var getGasEthValue: function () {}
    property var getFiatValue: function () {}
    property var getEstimatedTime: function () {}
    property string defaultCurrency: "USD"
    property alias selectedGasPrice: inputGasPrice.text
    property alias selectedGasLimit: inputGasLimit.text
    property string defaultGasLimit: "0"
    property string maxFiatFees: selectedGasFiatValue + root.defaultCurrency.toUpperCase()
    property int estimatedTxTimeFlag: Constants.transactionEstimatedTime.unknown
    property int chainId: 1

    property alias selectedTipLimit: inputPerGasTipLimit.text
    property alias selectedOverallLimit: inputGasPrice.text

    property double selectedGasEthValue
    property double selectedGasFiatValue
    property string greaterThan0ErrorMessage: qsTr("Must be greater than 0")
    property string invalidInputErrorMessage: qsTr("This needs to be a number")
    property string noInputErrorMessage: qsTr("Please enter an amount")
    property bool isValid: true
    readonly property string uuid: Utils.uuid()

    property bool advancedMode: false

    // TODO: change these values false once EIP1559 suggestions are revised
    property double perGasTipLimitFloor: 1 // Matches status-mobile minimum-priority-fee
    property double perGasTipLimitAverage: formatDec(root.suggestedFees.maxPriorityFeePerGas, 2) // 1.5 // Matches status-mobile average-priority-fee


    property bool showPriceLimitWarning : false
    property bool showTipLimitWarning : false

    function formatDec(num, dec){
       return Math.round((num + Number.EPSILON) * Math.pow(10, dec)) / Math.pow(10, dec)
    }

    function updateGasEthValue() {
        // causes error on application load without this null check
        if (!inputGasPrice || !inputGasLimit) {
            return

        }

        Qt.callLater(function () {
            let ethValue = root.getGasEthValue(inputGasPrice.text, inputGasLimit.text)
            let fiatValue = root.getFiatValue(ethValue, "ETH", root.defaultCurrency)
            selectedGasEthValue = ethValue
            selectedGasFiatValue = fiatValue
            root.estimatedTxTimeFlag = root.getEstimatedTime(root.chainId, inputGasPrice.text)
        })
    }

    function appendError(accum, error, nonBlocking = false) {
        return accum + ` <span class="${nonBlocking ? "non-blocking" : ""}">${error}.</span>`
    }


    function checkLimits(){
        if(!root.suggestedFees.eip1559Enabled) return;

        let inputTipLimit = parseFloat(inputPerGasTipLimit.text || "0.00")
        let inputOverallLimit = parseFloat(inputGasPrice.text || "0.00")
        let gasLimit = parseInt(inputGasLimit.text, 10)
        errorsText.text = "";

        showPriceLimitWarning = false
        showTipLimitWarning = false

        let errorMsg = "";

        if(gasLimit < 21000) {
            errorMsg = appendError(errorMsg, qsTr("Min 21000 units"))
        } else if (gasLimit < parseInt(defaultGasLimit)){
            errorMsg = appendError(errorMsg, qsTr("Not enough gas").arg(perGasTipLimitAverage), true)
        }

        // Per-gas tip limit rules
        if(inputTipLimit < perGasTipLimitFloor){
            errorMsg = appendError(errorMsg, qsTr("Miners will currently not process transactions with a tip below %1 Gwei, the average is %2 Gwei").arg(perGasTipLimitFloor).arg(perGasTipLimitAverage))
            showTipLimitWarning = true
        } else if (inputTipLimit < perGasTipLimitAverage) {
            errorMsg = appendError(errorMsg, qsTr("The average miner tip is %1 Gwei").arg(perGasTipLimitAverage), true)
        }

        errorsText.text = `<style type="text/css">span { color: "#ff0000" } span.non-blocking { color: "#FE8F59" }</style>${errorMsg}`

    }

    function checkOptimal() {
        if (!optimalGasButton.checked) {
            optimalGasButton.toggle()
        }
    }

    function validate() {
        // causes error on application load without a null check
        if (!inputGasLimit || !inputGasPrice || !inputPerGasTipLimit) {
            return
        }

        inputGasLimit.validationError = ""
        inputGasPrice.validationError = ""
        inputPerGasTipLimit.validationError = ""

        const noInputLimit = inputGasLimit.text === ""
        const noInputPrice = inputGasPrice.text === ""
        const noPerGasTip = inputPerGasTipLimit.text === ""

        if (noInputLimit) {
            inputGasLimit.validationError = root.noInputErrorMessage
        }

        if (noInputPrice) {
            inputGasPrice.validationError = root.noInputErrorMessage
        }

        if (root.suggestedFees.eip1559Enabled && noPerGasTip) {
            inputPerGasTipLimit.validationError = root.noInputErrorMessage
        }

        if (isNaN(inputGasLimit.text)) {
            inputGasLimit.validationError = invalidInputErrorMessage
        }
        if (isNaN(inputGasPrice.text)) {
            inputGasPrice.validationError = invalidInputErrorMessage
        }

        if (root.suggestedFees.eip1559Enabled && isNaN(inputPerGasTipLimit.text)) {
            inputPerGasTipLimit.validationError = invalidInputErrorMessage
        }

        let inputLimit = parseFloat(inputGasLimit.text || "0.00")
        let inputPrice = parseFloat(inputGasPrice.text || "0.00")
        let inputTipLimit = parseFloat(inputPerGasTipLimit.text || "0.00")

        if (inputLimit <= 0.00) {
            inputGasLimit.validationError = root.greaterThan0ErrorMessage
        }

        if (inputPrice <= 0.00) {
            inputGasPrice.validationError = root.greaterThan0ErrorMessage
        }
        if (root.suggestedFees.eip1559Enabled && inputTipLimit <= 0.00) {
            inputPerGasTipLimit.validationError = root.greaterThan0ErrorMessage
        }
        return inputGasLimit.validationError === "" && inputGasPrice.validationError === "" && (!root.suggestedFees.eip1559Enabled  || (root.suggestedFees.eip1559Enabled && inputPerGasTipLimit.validationError === ""))
    }


    StyledText {
        id: prioritytext
        anchors.top: parent.top
        anchors.left: parent.left
        text: root.suggestedFees.eip1559Enabled ? qsTr("Priority") : qsTr("Gas Price")
        font.weight: Font.Medium
        font.pixelSize: 13
        color: Style.current.textColor
    }

    StyledText {
        id: baseFeeText
        visible: root.suggestedFees.eip1559Enabled && advancedMode
        anchors.top: parent.top
        anchors.left: prioritytext.right
        anchors.leftMargin: Style.current.smallPadding
        text: qsTr("Current base fee: %1 %2").arg(root.suggestedFees.baseFee).arg("Gwei")
        font.weight: Font.Medium
        font.pixelSize: 13
        color: Style.current.secondaryText
    }

    StatusButton {
        anchors.verticalCenter: prioritytext.verticalCenter
        anchors.right: parent.right
        height: 22
        defaultTopPadding: 2
        defaultBottomPadding: 2
        size: StatusBaseButton.Size.Tiny
        visible: root.suggestedFees.eip1559Enabled
        text: advancedMode ?
            qsTr("Use suggestions") :
            qsTr("Use custom")
        font.pixelSize: 13
        onClicked: advancedMode = !advancedMode
    }

    Row {
        id: selectorButtons
        visible: root.suggestedFees.eip1559Enabled && !advancedMode
        anchors.top: prioritytext.bottom
        anchors.topMargin: Style.current.halfPadding
        spacing: 11

        GasSelectorButton {
            id: lowGasButton
            primaryText: qsTr("Low")
            gasLimit: inputGasLimit ? inputGasLimit.text : ""
            getGasEthValue: root.getGasEthValue
            getFiatValue: root.getFiatValue
            defaultCurrency: root.defaultCurrency
            price: {
                if (!root.suggestedFees.eip1559Enabled) return root.suggestedFees.gasPrice;
                return formatDec(root.suggestedFees.maxFeePerGasL, 6)
            }
            onCheckedChanged: {
                if(checked) {
                    if (root.suggestedFees.eip1559Enabled){
                        inputPerGasTipLimit.text = formatDec(root.suggestedFees.maxPriorityFeePerGas, 2);
                        inputGasPrice.text = formatDec(root.suggestedFees.maxFeePerGasL, 2);
                    } else {
                        inputGasPrice.text = price
                    }
                    root.updateGasEthValue()
                    root.checkLimits()
                }
            }
        }

        GasSelectorButton {
            id: optimalGasButton
            primaryText: qsTr("Optimal")
            price: {
                if (!root.suggestedFees.eip1559Enabled) {
                    // Setting the gas price field here because the binding didn't work
                    inputGasPrice.text = root.suggestedFees.gasPrice
                    return root.suggestedFees.gasPrice
                }

                return formatDec(root.suggestedFees.maxFeePerGasM, 6)
            }
            gasLimit: inputGasLimit ? inputGasLimit.text : ""
            getGasEthValue: root.getGasEthValue
            getFiatValue: root.getFiatValue
            defaultCurrency: root.defaultCurrency
            onCheckedChanged: {
                if(checked) {
                    if (root.suggestedFees.eip1559Enabled){
                        inputPerGasTipLimit.text = formatDec(root.suggestedFees.maxPriorityFeePerGas, 2);
                        inputGasPrice.text = formatDec(root.suggestedFees.maxFeePerGasM, 2);
                    } else {
                        inputGasPrice.text = root.suggestedFees.gasPrice
                    }
                    root.updateGasEthValue()
                    root.checkLimits()
                }
            }
        }

        GasSelectorButton {
            id: highGasButton
            primaryText: qsTr("High")
            price: {
                if (!root.suggestedFees.eip1559Enabled) return root.suggestedFees.gasPrice;
                return formatDec(root.suggestedFees.maxFeePerGasH,6);
            }
            gasLimit: inputGasLimit ? inputGasLimit.text : ""
            getGasEthValue: root.getGasEthValue
            getFiatValue: root.getFiatValue
            defaultCurrency: root.defaultCurrency
            onCheckedChanged: {
                if(checked) {
                    if (root.suggestedFees.eip1559Enabled){
                        inputPerGasTipLimit.text = formatDec(root.suggestedFees.maxPriorityFeePerGas, 2);
                        inputGasPrice.text = formatDec(root.suggestedFees.maxFeePerGasH, 2);
                    } else {
                        inputGasPrice.text = price
                    }
                    root.updateGasEthValue()
                    root.checkLimits()
                }
            }
        }
    }

    Item {
        id: advancedModeItemGroup
        anchors.top: prioritytext.bottom
        anchors.topMargin: 14
        visible: !root.suggestedFees.eip1559Enabled || root.advancedMode
        width: parent.width
        height: childrenRect.height

        Input {
            id: inputGasLimit
            label: qsTr("Gas amount limit")
            text: "21000"
            inputLabel.color: Style.current.secondaryText
            customHeight: 56
            anchors.top: parent.top
            anchors.left: parent.left
            anchors.right: root.suggestedFees.eip1559Enabled ? inputPerGasTipLimit.left : inputGasPrice.left
            anchors.rightMargin: Style.current.padding
            placeholderText: "21000"
            validator: IntValidator{
                bottom: 1
            }
            validationErrorAlignment: TextEdit.AlignRight
            validationErrorTopMargin: 8
            onTextChanged: {
                if (root.validate()) {
                    root.updateGasEthValue()
                    root.checkLimits()
                }
            }
        }

        Input {
            id: inputPerGasTipLimit
            label: qsTr("Per-gas tip limit")
            inputLabel.color: Style.current.secondaryText
            anchors.top: parent.top
            anchors.right: inputGasPrice.left
            anchors.rightMargin: Style.current.padding
            anchors.left: undefined
            visible: root.suggestedFees.eip1559Enabled
            width: 125
            customHeight: 56
            text: formatDec(root.suggestedFees.maxPriorityFeePerGas, 2);
            placeholderText: "20"
            onTextChanged: {
                if (root.validate()) {
                    root.updateGasEthValue()
                    root.checkLimits()
                }
            }
        }

        StyledText {
            color: Style.current.secondaryText
            text: qsTr("Gwei")
            visible: root.suggestedFees.eip1559Enabled
            anchors.top: parent.top
            anchors.topMargin: 42
            anchors.right: inputPerGasTipLimit.right
            anchors.rightMargin: Style.current.padding
            font.pixelSize: 15
        }

        Input {
            id: inputGasPrice
            label: qsTr("Per-gas overall limit")
            inputLabel.color: Style.current.secondaryText
            anchors.top: parent.top
            anchors.left: undefined
            anchors.right: parent.right
            width: 125
            customHeight: 56
            placeholderText: "20"
            onTextChanged: {
                if (root.validate()) {
                    root.updateGasEthValue()
                    root.checkLimits()
                }
            }
        }

        StyledText {
            color: Style.current.secondaryText
            text: qsTr("Gwei")
            anchors.top: parent.top
            anchors.topMargin: 42
            anchors.right: inputGasPrice.right
            anchors.rightMargin: Style.current.padding
            font.pixelSize: 15
        }

        StyledText {
            id: errorsText
            text: ""
            width: parent.width - Style.current.padding
            visible: text != ""
            height: visible ? undefined : 0
            anchors.top: inputGasLimit.bottom
            anchors.topMargin: Style.current.smallPadding + 5
            font.pixelSize: 13
            textFormat: Text.RichText
            color: Style.current.secondaryText
            wrapMode: Text.WordWrap
        }

        StyledText {
            id: maxPriorityFeeText
            anchors.left: parent.left
            visible: root.suggestedFees.eip1559Enabled
            text: {
                let v = selectedGasEthValue > 0.00009 ? selectedGasEthValue :
                    (selectedGasEthValue < 0.000001 ? "0.000000..." : selectedGasEthValue.toFixed(6))
                return qsTr("Maximum priority fee: %1 ETH").arg(v)
            }
            anchors.top: errorsText.bottom
            anchors.topMargin: Style.current.smallPadding + 5
            font.pixelSize: 13
            color: Style.current.textColor
        }

        StyledText {
            id: maxPriorityFeeFiatText
            text: root.maxFiatFees
            visible: root.suggestedFees.eip1559Enabled
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
            visible: root.suggestedFees.eip1559Enabled
            width: parent.width
            anchors.top: maxPriorityFeeText.bottom
            anchors.topMargin: Style.current.smallPadding
            font.pixelSize: 13
            color: Style.current.secondaryText
            wrapMode: Text.WordWrap
        }
    }
}
