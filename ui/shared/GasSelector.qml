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

    property string maxPriorityFeePerGas: "0"
    property var suggestedFees: {
        let r = JSON.parse(walletModel.gasView.suggestedFees)
        r.maxPriorityFeePerGas = parseFloat(r.maxPriorityFeePerGas)
        r.maxFeePerGas = parseFloat(r.maxFeePerGas)
        return r
    }
    property bool eip1599Enabled: walletModel.transactionsView.isEIP1559Enabled

    property var latestBaseFee: JSON.parse(walletModel.transactionsView.latestBaseFee)
    
    property double latestBaseFeeGwei: {
        if (!eip1599Enabled) return 0;
        return parseFloat(latestBaseFee.gwei)
    }

    property double latestBaseFeeAmount: {
        if (!eip1599Enabled) return 0;
        return parseFloat(latestBaseFee.amount)
    }

    property string latestBaseFeeUnit: {
        if (!eip1599Enabled) return "gwei";
        return latestBaseFee.unit
    }
        
    property var getGasGweiValue: function () {}
    property var getGasEthValue: function () {}
    property var getFiatValue: function () {}
    property string defaultCurrency: "USD"
    property alias selectedGasPrice: inputGasPrice.text
    property alias selectedGasLimit: inputGasLimit.text


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

    property bool advancedMode: false

    property double perGasTipLimitFloor: 1 // Matches status-react minimum-priority-fee
    property double perGasTipLimitAverage: 1.5 // Matches status-react average-priority-fee

    // TODO: determine how to calculate this? ask @roman
    property double eip1559LowPrice: 0.1
    property double eip1559OptimalPrice: suggestedFees.maxFeePerGas
    property double eip1559HighPrice: eip1559OptimalPrice * 2

    // TODO: determine how to calculate this? ask @roman
    property double perGasOverallLimitFloor: 40
    property double perGasOverallLimitAverage: 50

    property bool showPriceLimitWarning : false
    property bool showTipLimitWarning : false

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

        errorsText.text = "";

        showPriceLimitWarning = false
        showTipLimitWarning = false

        let errorMsg = "";

        // Per-gas tip limit rules
        if(inputTipLimit < perGasTipLimitFloor){
            errorMsg = appendError(errorMsg, qsTr("Miners will currently not process transactions with a tip below %1 Gwei, the average is %2 Gwei").arg(perGasTipLimitFloor).arg(perGasTipLimitAverage))
            showTipLimitWarning = true
        } else if (inputTipLimit < perGasTipLimitAverage) {
            errorMsg = appendError(errorMsg, qsTr("The average miner tip is %1 Gwei").arg(perGasTipLimitAverage), true)
        }

        // Per-gas overall limit rules
        console.log(inputOverallLimit, latestBaseFeeGwei)
        if(inputOverallLimit < latestBaseFeeGwei){
            errorMsg = appendError(errorMsg, qsTr("The limit is below the current base fee of %1 %2").arg(latestBaseFeeAmount).arg(latestBaseFeeUnit))
            showPriceLimitWarning = true
        } else if(inputOverallLimit < perGasOverallLimitFloor){
            errorMsg = appendError(errorMsg, qsTr("The limit should be at least %1 Gwei above the base fee").arg(perGasOverallLimitFloor))
        } else if(inputOverallLimit < perGasOverallLimitAverage) {
            errorMsg = appendError(errorMsg, qsTr("The maximum miner tip after the current base fee will be %1 Gwei, the minimum miner tip is currently %2 Gwei").arg(perGasOverallLimitAverage).arg(perGasOverallLimitFloor), true)
            showTipLimitWarning = true
        }

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
        visible: !advancedMode
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
        text: qsTr("Current base fee: %1 %2").arg(latestBaseFeeAmount).arg(latestBaseFeeUnit)
        font.weight: Font.Medium
        font.pixelSize: 13
        color: Style.current.secondaryText
    }

    StatusButton {
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
            price: eip1599Enabled ? eip1559LowPrice : slowestGasPrice
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
            //% "Optimal"
            text: qsTrId("optimal")
            price: {
                if (eip1599Enabled){
                    return eip1559OptimalPrice
                }
                
                const price = (fastestGasPrice + slowestGasPrice) / 2
                // Setting the gas price field here because the binding didn't work
                inputGasPrice.text = price
                return price
            }
            gasLimit: inputGasLimit ? inputGasLimit.text : ""
            getGasEthValue: root.getGasEthValue
            getFiatValue: root.getFiatValue
            defaultCurrency: root.defaultCurrency
            onChecked: inputGasPrice.text = price
        }

        GasSelectorButton {
            buttonGroup: gasGroup
            text: qsTr("High")
            price: eip1599Enabled ? eip1559HighPrice :fastestGasPrice
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
            //% "Gas amount limit"
            label: qsTrId("gas-amount-limit")
            text: "21000"
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
            anchors.top: parent.top
            anchors.right: inputGasPrice.left
            anchors.rightMargin: Style.current.padding
            anchors.left: undefined
            visible: eip1599Enabled
            width: 125
            customHeight: 56
            text: optimalGasButton.price
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
                console.log(selectedGasEthValue, selectedGasEthValue > 0.00009, selectedGasEthValue < 0.000001)
                let v = selectedGasEthValue > 0.00009 ? selectedGasEthValue : 
                    (selectedGasEthValue < 0.000001 ? "0.000000..." : selectedGasEthValue.toFixed(6))
                return qsTrId("maximum-priority-fee---1-eth").arg(v)
            
            }anchors.top: errorsText.bottom
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
