import QtQuick 2.13
import QtQuick.Controls 2.13
import QtQuick.Layouts 1.13
import "../imports"
import "./"

Item {
    id: root
    anchors.left: parent.left
    anchors.right: parent.right
    height: sliderWrapper.height + Style.current.smallPadding + txtNetworkFee.height + buttonAdvanced.height
    property string validationError: "Please enter a number"
    property double slowestGasPrice: 0
    property double fastestGasPrice: 100
    property double stepSize: ((root.fastestGasPrice - root.slowestGasPrice) / 10).toFixed(1)
    property var getGasEthValue: function () {}
    property var getFiatValue: function () {}
    property string defaultCurrency: "USD"
    property alias selectedGasPrice: inputGasPrice.text
    property alias selectedGasLimit: inputGasLimit.text

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
    }

    function validate(value) {
        return !isNaN(value)
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

    StyledButton {
        id: buttonReset
        anchors.top: sliderWrapper.bottom
        anchors.topMargin: sliderWrapper.visible ? Style.current.smallPadding : 0
        anchors.right: buttonAdvanced.left
        anchors.rightMargin: -Style.current.padding
        //% "Reset"
        label: qsTrId("reset")
        btnColor: "transparent"
        textSize: 13
        visible: !sliderWrapper.visible
        onClicked: {
            gasSlider.value = root.defaultGasPrice()
            inputGasPrice.text = root.defaultGasPrice()
        }
    }

    StyledButton {
        id: buttonAdvanced
        anchors.top: sliderWrapper.bottom
        anchors.topMargin: sliderWrapper.visible ? Style.current.smallPadding : 0
        anchors.right: parent.right
        anchors.rightMargin: -Style.current.padding
        //% "Advanced"
        label: qsTrId("advanced")
        btnColor: "transparent"
        textSize: 13
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

        Input {
          id: inputGasLimit
          //% "Gas limit"
          label: qsTrId("gas-limit")
          text: "22000"
          customHeight: 56
          anchors.top: parent.top
          anchors.left: parent.left
          anchors.right: inputGasPrice.left
          anchors.rightMargin: Style.current.padding
          onTextChanged: {
              if (root.validate(inputGasLimit.text.trim())) {
                  inputGasLimit.validationError = ""
                  root.updateGasEthValue()
                  return
              }
              inputGasLimit.validationError = root.validationError
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
          onTextChanged: {
              if (root.validate(inputGasPrice.text.trim())) {
                  inputGasPrice.validationError = ""
                  root.updateGasEthValue()
                  return
              }
              inputGasPrice.validationError = root.validationError
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

        footer: StyledButton {
            id: applyButton
            anchors.right: parent.right
            anchors.rightMargin: Style.current.smallPadding
            //% "Apply"
            label: qsTrId("invalid-key-confirm")
            disabled: !root.validate(inputGasLimit.text.trim()) || !root.validate(inputGasPrice.text.trim())
            anchors.bottom: parent.bottom
            onClicked: {
                root.updateGasEthValue()
                customNetworkFeeDialog.close()
            }
        }
    }
}
