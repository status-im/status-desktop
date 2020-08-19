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
        text: qsTr("Network fee")
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
            text: qsTr("Slow")
            font.pixelSize: 15
            color: Style.current.textColor
            visible: parent.visible
        }

        StyledText {
            id: labelOptimal
            anchors.top: gasSlider.bottom
            anchors.topMargin: Style.current.padding
            anchors.horizontalCenter: gasSlider.horizontalCenter
            text: qsTr("Optimal")
            font.pixelSize: 15
            color: Style.current.textColor
            visible: parent.visible
        }

        StyledText {
            id: labelFast
            anchors.top: gasSlider.bottom
            anchors.topMargin: Style.current.padding
            anchors.right: parent.right
            text: qsTr("Fast")
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
        label: qsTr("Reset")
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
        label: qsTr("Advanced")
        btnColor: "transparent"
        textSize: 13
        onClicked: {
            customNetworkFeeDialog.open()
        }
    }

    ModalPopup {
        id: customNetworkFeeDialog
        title: qsTr("Custom Network Fee")
        height: 286
        width: 400

        Input {
          id: inputGasLimit
          label: qsTr("Gas limit")
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
          label: qsTr("Gas price")
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
            text: qsTr("Gwei")
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
            label: qsTr("Apply")
            disabled: !root.validate(inputGasLimit.text.trim()) || !root.validate(inputGasPrice.text.trim())
            anchors.bottom: parent.bottom
            onClicked: {
                root.updateGasEthValue()
                customNetworkFeeDialog.close()
            }
        }
    }
}
