import QtQuick 2.13
import QtQuick.Controls 2.13
import QtQuick.Layouts 1.13
import "../imports"
import "./status"
import "./"

Item {
    id: root
    anchors.left: parent.left
    anchors.right: parent.right
    height: sliderWrapper.height + Style.current.smallPadding + txtNetworkFee.height + buttonAdvanced.height
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

    function defaultGasPrice() {
        return ((50 * (root.fastestGasPrice - root.slowestGasPrice) / 100) + root.slowestGasPrice)
    }

    function updateGasEthValue() {
        // causes error on application load without this null check
        if (!inputGasPrice || !inputGasLimit) {
            return
        }
        let ethValue = root.getGasEthValue(inputGasPrice.text, inputGasLimit.text)
        let fiatValue = root.getFiatValue(ethValue, "ETH", root.defaultCurrency)
        let summary = Utils.stripTrailingZeros(ethValue) + " ETH ~" + fiatValue + " " + root.defaultCurrency.toUpperCase()
        labelGasPriceSummary.text = summary
        labelGasPriceSummaryAdvanced.text = summary
        selectedGasEthValue = ethValue
        selectedGasFiatValue = fiatValue
    }

    StyledText {
        id: txtNetworkFee
        anchors.top: parent.top
        anchors.left: parent.left
        //% "Network fee"
        text: qsTrId("network-fee")
        font.weight: Font.Medium
        font.pixelSize: 13
        color: Style.current.textColor
    }

    StyledText {
        id: labelGasPriceSummary
        anchors.top: parent.top
        anchors.right: parent.right
        font.weight: Font.Medium
        font.pixelSize: 13
        color: Style.current.secondaryText
    }

    Item {
        id: sliderWrapper
        anchors.topMargin: Style.current.smallPadding
        anchors.top: labelGasPriceSummary.bottom
        height: sliderWrapper.visible ? gasSlider.height + labelSlow.height + Style.current.padding : 0
        width: parent.width
        visible: Number(root.selectedGasPrice) >= Number(root.slowestGasPrice) && Number(root.selectedGasPrice) <= Number(root.fastestGasPrice)

        StatusSlider {
            id: gasSlider
            minimumValue: root.slowestGasPrice
            maximumValue: root.fastestGasPrice
            stepSize: root.stepSize
            value: root.defaultGasPrice()
            onValueChanged: {
                if (!isNaN(gasSlider.value)) {
                    inputGasPrice.text = gasSlider.value + ""
                    root.updateGasEthValue()
                }
            }
            visible: parent.visible
        }

        StyledText {
            id: labelSlow
            anchors.top: gasSlider.bottom
            anchors.topMargin: Style.current.padding
            anchors.left: parent.left
            //% "Slow"
            text: qsTrId("slow")
            font.pixelSize: 15
            color: Style.current.textColor
            visible: parent.visible
        }

        StyledText {
            id: labelOptimal
            anchors.top: gasSlider.bottom
            anchors.topMargin: Style.current.padding
            anchors.horizontalCenter: gasSlider.horizontalCenter
            //% "Optimal"
            text: qsTrId("optimal")
            font.pixelSize: 15
            color: Style.current.textColor
            visible: parent.visible
        }

        StyledText {
            id: labelFast
            anchors.top: gasSlider.bottom
            anchors.topMargin: Style.current.padding
            anchors.right: parent.right
            //% "Fast"
            text: qsTrId("fast")
            font.pixelSize: 15
            color: Style.current.textColor
            visible: parent.visible
        }
    }

    StatusButton {
        id: buttonReset
        anchors.top: sliderWrapper.bottom
        anchors.topMargin: sliderWrapper.visible ? Style.current.smallPadding : 0
        anchors.right: buttonAdvanced.left
        anchors.rightMargin: Style.current.padding
        text: qsTr("Reset")
        flat: true
        font.pixelSize: 13
        visible: !sliderWrapper.visible
        onClicked: {
            gasSlider.value = root.defaultGasPrice()
            inputGasPrice.text = root.defaultGasPrice()
        }
    }

    StatusButton {
        id: buttonAdvanced
        anchors.top: sliderWrapper.bottom
        anchors.topMargin: sliderWrapper.visible ? Style.current.smallPadding : 0
        anchors.right: parent.right
        anchors.rightMargin: -Style.current.padding
        text: qsTr("Advanced")
        flat: true
        font.pixelSize: 13
        onClicked: {
            customNetworkFeeDialog.open()
        }
    }

    ModalPopup {
        id: customNetworkFeeDialog
        //% "Custom Network Fee"
        title: qsTrId("custom-network-fee")
        height: 286
        width: 400
        property bool isValid: true

        onIsValidChanged: {
            root.isValid = isValid
        }

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
            customNetworkFeeDialog.isValid = isValid
            return isValid
        }

        Input {
          id: inputGasLimit
          //% "Gas limit"
          label: qsTrId("gas-limit")
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
              if (customNetworkFeeDialog.validate()) {
                  root.updateGasEthValue()
              }
          }
        }

        Input {
          id: inputGasPrice
          //% "Gas price"
          label: qsTrId("gas-price")
          anchors.top: parent.top
          anchors.left: undefined
          anchors.right: parent.right
          width: 130
          customHeight: 56
          text: root.defaultGasPrice()
          placeholderText: "20"
          onTextChanged: {
              if (inputGasPrice.text.trim() === "") {
                  inputGasPrice.text = root.defaultGasPrice()
              }
              if (customNetworkFeeDialog.validate()) {
                  root.updateGasEthValue()
              }
          }

          StyledText {
            color: Style.current.darkGrey
            //% "Gwei"
            text: qsTrId("gwei")
            anchors.top: parent.top
            anchors.topMargin: 42
            anchors.right: parent.right
            anchors.rightMargin: Style.current.padding
            font.pixelSize: 15
          }
        }

        StyledText {
            id: labelGasPriceSummaryAdvanced
            anchors.bottom: parent.bottom
            anchors.bottomMargin: Style.current.smallPadding
            anchors.right: parent.right
            font.weight: Font.Medium
            font.pixelSize: 13
            color: Style.current.secondaryText
        }

        footer: StatusButton {
            id: applyButton
            anchors.right: parent.right
            anchors.rightMargin: Style.current.smallPadding
            //% "Apply"
            text: qsTrId("invalid-key-confirm")
            anchors.bottom: parent.bottom
            enabled: customNetworkFeeDialog.isValid
            onClicked: {
                if (customNetworkFeeDialog.validate()) {
                    root.updateGasEthValue()
                }
                customNetworkFeeDialog.close()
            }
        }
    }
}
