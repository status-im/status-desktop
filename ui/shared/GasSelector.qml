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

    property double gasPrice: 0

   
    property bool eip1599Enabled: walletModel.transactionsView.isEIP1559Enabled
    property var suggestedFees: JSON.parse(walletModel.gasView.suggestedFees)
    property var latestBaseFee: JSON.parse(walletModel.transactionsView.latestBaseFee)
    
    property double latestBaseFeeGwei: {
        if (!eip1599Enabled) return 0;
        return parseFloat(latestBaseFee.gwei)
    }

    property var getGasGweiValue: function () {}
    property var getGasEthValue: function () {}
    property var getFiatValue: function () {}
    property string defaultCurrency: "USD"
    property alias selectedGasPrice: inputGasPrice.text
    property alias selectedGasLimit: inputGasLimit.text
    property string defaultGasLimit: "0"


    property alias selectedTipLimit: inputPerGasTipLimit.text
    property alias selectedOverallLimit: inputGasPrice.text

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

    property bool advancedMode: true // TODO: change to false once EIP1559 suggestions are revised

    // TODO: change these values false once EIP1559 suggestions are revised
    property double perGasTipLimitFloor: 1 // Matches status-react minimum-priority-fee
    property double perGasTipLimitAverage: formatDec(suggestedFees.maxPriorityFeePerGas, 2) // 1.5 // Matches status-react average-priority-fee


    property bool showPriceLimitWarning : false
    property bool showTipLimitWarning : false

    function formatDec(num, dec){
       return Math.round((num + Number.EPSILON) * Math.pow(10, dec)) / Math.pow(10, dec)
    }

    property real gasSelectorButtonWidth: 130
    property real gasSelectorButtonHeight: 120

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

    function appendError(accum, error, nonBlocking = false) {
        return accum + ` <span class="${nonBlocking ? "non-blocking" : ""}">${error}.</span>`
    }


    function checkLimits(){
        if(!eip1599Enabled) return;

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

        // Per-gas overall limit rules
        if(inputOverallLimit < latestBaseFeeGwei){
            errorMsg = appendError(errorMsg, qsTr("The limit is below the current base fee of %1 %2").arg(latestBaseFeeGwei).arg("Gwei"))
            showPriceLimitWarning = true
        }

        /* TODO: change these values false once EIP1559 suggestions are revised
         else if((inputOverallLimit - inputTipLimit) < latestBaseFeeGwei){
            errorMsg = appendError(errorMsg, qsTr("The limit should be at least %1 Gwei above the base fee").arg(perGasTipLimitFloor))
        } else if((inputOverallLimit - perGasTipLimitAverage) < latestBaseFeeGwei) {
            errorMsg = appendError(errorMsg, qsTr("The maximum miner tip after the current base fee will be %1 Gwei, the minimum miner tip is currently %2 Gwei").arg(inputOverallLimit).arg(perGasTipLimitFloor), true)
            showTipLimitWarning = true
        }*/

        errorsText.text = `<style type="text/css">span { color: "#ff0000" } span.non-blocking { color: "#FE8F59" }</style>${errorMsg}`

    }

    Component.onCompleted: {
        updateGasEthValue()
        checkLimits()
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

        if (noPerGasTip) {
            inputPerGasTipLimit.validationError = root.noInputErrorMessage
        }

        if (isNaN(inputGasLimit.text)) {
            inputGasLimit.validationError = invalidInputErrorMessage
        }
        if (isNaN(inputGasPrice.text)) {
            inputGasPrice.validationError = invalidInputErrorMessage
        }

        if (isNaN(inputPerGasTipLimit.text)) {
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
        if (inputTipLimit <= 0.00) {
            inputPerGasTipLimit.validationError = root.greaterThan0ErrorMessage
        }
        const isInputValid = inputGasLimit.validationError === "" && inputGasPrice.validationError === "" && inputPerGasTipLimit.validationError === ""
        return isInputValid
    }


    StyledText {
        id: prioritytext
        anchors.top: parent.top
        anchors.left: parent.left
        //% "Priority"
        text: qsTrId("priority")
        font.weight: Font.Medium
        font.pixelSize: 13
        color: Style.current.textColor
    }

    StyledText {
        id: baseFeeText
        visible: eip1599Enabled && advancedMode
        anchors.top: parent.top
        anchors.left: prioritytext.right
        anchors.leftMargin: Style.current.smallPadding
        text: qsTr("Current base fee: %1 %2").arg(latestBaseFeeGwei).arg("Gwei")
        font.weight: Font.Medium
        font.pixelSize: 13
        color: Style.current.secondaryText
    }

    StatusButton {
        visible: false // Change to TRUE once EIP1559 suggestions are revised
        id: buttonAdvanced
        anchors.verticalCenter: prioritytext.verticalCenter
        anchors.right: parent.right
        text: advancedMode ?
            //% "Use suggestions"
            qsTrId("use-suggestions") :
            //% "Use custom"
            qsTrId("use-custom")
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
            price: {
                if (!eip1599Enabled) return gasPrice;
                return formatDec(suggestedFees.maxFeePerGasL, 6)
            }
            gasLimit: inputGasLimit ? inputGasLimit.text : ""
            getGasEthValue: root.getGasEthValue
            getFiatValue: root.getFiatValue
            defaultCurrency: root.defaultCurrency
            onChecked: {
                if (eip1599Enabled){
                    inputPerGasTipLimit.text = formatDec(suggestedFees.maxPriorityFeePerGas, 2);
                    inputGasPrice.text = formatDec(suggestedFees.maxFeePerGasL, 2);
                } else {
                    inputGasPrice.text = price
                }
                root.updateGasEthValue()
                root.checkLimits()
            }
            width: root.gasSelectorButtonWidth
            height: root.gasSelectorButtonHeight
        }
        GasSelectorButton {
            id: optimalGasButton
            buttonGroup: gasGroup
            checkedByDefault: true
            //% "Optimal"
            text: qsTrId("optimal")
            price: {
                if (!eip1599Enabled) {
                     const price = gasPrice
                    // Setting the gas price field here because the binding didn't work
                    inputGasPrice.text = price
                    return price
                }

                return formatDec(suggestedFees.maxFeePerGasM, 6)
            }
            gasLimit: inputGasLimit ? inputGasLimit.text : ""
            getGasEthValue: root.getGasEthValue
            getFiatValue: root.getFiatValue
            defaultCurrency: root.defaultCurrency
            onChecked: {
                if (eip1599Enabled){
                    inputPerGasTipLimit.text = formatDec(suggestedFees.maxPriorityFeePerGas, 2);
                    inputGasPrice.text = formatDec(suggestedFees.maxFeePerGasM, 2);
                } else {
                    inputGasPrice.text = price
                }
                root.updateGasEthValue()
                root.checkLimits()
            }
            width: root.gasSelectorButtonWidth
            height: root.gasSelectorButtonHeight
        }

        GasSelectorButton {
            buttonGroup: gasGroup
            text: qsTr("High")
            price: {
                if (!eip1599Enabled) return gasPrice;
                return formatDec(suggestedFees.maxFeePerGasH,6);
            }
            gasLimit: inputGasLimit ? inputGasLimit.text : ""
            getGasEthValue: root.getGasEthValue
            getFiatValue: root.getFiatValue
            defaultCurrency: root.defaultCurrency
            onChecked: {
                if (eip1599Enabled){
                    inputPerGasTipLimit.text = formatDec(suggestedFees.maxPriorityFeePerGas, 2);
                    inputGasPrice.text = formatDec(suggestedFees.maxFeePerGasH, 2);
                } else {
                    inputGasPrice.text = price
                }
                root.updateGasEthValue()
                root.checkLimits()
            }
            width: root.gasSelectorButtonWidth
            height: root.gasSelectorButtonHeight
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
            //% "Gas amount limit"
            label: qsTrId("gas-amount-limit")
            text: "21000"
            inputLabel.color: Style.current.secondaryText
            customHeight: 56
            anchors.top: parent.top
            anchors.left: parent.left
            anchors.right: eip1599Enabled ? inputPerGasTipLimit.left : inputGasPrice.left
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
            visible: eip1599Enabled
            width: 125
            customHeight: 56
            text: formatDec(suggestedFees.maxPriorityFeePerGas, 2);
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
            //% "Gwei"
            text: qsTrId("gwei")
            visible: eip1599Enabled
            anchors.top: parent.top
            anchors.topMargin: 42
            anchors.right: inputPerGasTipLimit.right
            anchors.rightMargin: Style.current.padding
            font.pixelSize: 15
        }

        Input {
            id: inputGasPrice
            //% "Per-gas overall limit"
            label: qsTrId("per-gas-overall-limit")
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
            //% "Gwei"
            text: qsTrId("gwei")
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
            //% "Maximum priority fee: %1 ETH"
            text: {
                let v = selectedGasEthValue > 0.00009 ? selectedGasEthValue : 
                    (selectedGasEthValue < 0.000001 ? "0.000000..." : selectedGasEthValue.toFixed(6))
                return qsTrId("maximum-priority-fee---1-eth").arg(v)
            }
            anchors.top: errorsText.bottom
            anchors.topMargin: Style.current.smallPadding + 5
            font.pixelSize: 13
            color: Style.current.textColor
        }

        StyledText {
            id: maxPriorityFeeFiatText
            text: `${selectedGasFiatValue} ${root.defaultCurrency.toUpperCase()}`
            anchors.verticalCenter: maxPriorityFeeText.verticalCenter
            anchors.left: maxPriorityFeeText.right
            anchors.leftMargin: 6
            color: Style.current.secondaryText
            anchors.topMargin: 19
            font.pixelSize: 13
        }

        StyledText {
            id: maxPriorityFeeDetailsText
            //% "Maximum overall price for the transaction. If the block base fee exceeds this, it will be included in a following block with a lower base fee."
            text: qsTrId("maximum-overall-price-for-the-transaction--if-the-block-base-fee-exceeds-this--it-will-be-included-in-a-following-block-with-a-lower-base-fee-")
            width: parent.width
            anchors.top: maxPriorityFeeText.bottom
            anchors.topMargin: Style.current.smallPadding
            font.pixelSize: 13
            color: Style.current.secondaryText
            wrapMode: Text.WordWrap
        }
    }
}
