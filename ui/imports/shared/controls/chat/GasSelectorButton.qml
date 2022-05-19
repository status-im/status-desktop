import QtQuick 2.13
import QtQuick.Controls 2.13
import QtQuick.Layouts 1.13
import StatusQ.Controls 0.1

import utils 1.0
import shared.panels 1.0
import shared.controls 1.0

// TODO: use StatusQ components
Rectangle {
    property var buttonGroup
    //% "Low"
    property string text: qsTrId("low")
    property string gasLimit
    property double price: 1
    property string defaultCurrency: "USD"
    property bool hovered: false
    property bool checkedByDefault: false
    property var getGasEthValue: function () {}
    property var getFiatValue: function () {}

    property alias gasRadioBtn: gasRadioBtn

    function formatDec(num, dec){
       return Math.round((num + Number.EPSILON) * Math.pow(10, dec)) / Math.pow(10, dec)
    }

    property double ethValue: {
        if (!gasLimit) {
            return 0
        }
        return formatDec(parseFloat(getGasEthValue(gasRectangle.price, gasLimit)), 6)
    }
    property double fiatValue: getFiatValue(ethValue, "ETH", defaultCurrency)
    signal checked()

    id: gasRectangle
    border.color: hovered || gasRadioBtn.checked ? Style.current.primary : Style.current.border
    border.width: 1
    color: Style.current.transparent
    width: 130
    height: 120
    clip: true
    radius: Style.current.radius

    StatusRadioButton {
        id: gasRadioBtn
        ButtonGroup.group: buttonGroup
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: parent.top
        anchors.topMargin: 14
        checked: gasRectangle.checkedByDefault
        onCheckedChanged: {
            if (checked) {
                gasRectangle.checked()
            }
        }
    }

    StyledText {
        id: gasText
        text: gasRectangle.text
        font.pixelSize: 15
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: gasRadioBtn.bottom
        anchors.topMargin: 6
    }

    StyledText {
        id: ethText
        text: gasRectangle.ethValue + " ETH"
        font.pixelSize: 13
        color: Style.current.secondaryText
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: gasText.bottom
        anchors.topMargin: 4
    }

    StyledText {
        id: fiatText
        text: `${gasRectangle.fiatValue} ${gasRectangle.defaultCurrency}`
        font.pixelSize: 13
        color: Style.current.secondaryText
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: ethText.bottom
    }

    MouseArea {
        anchors.fill: parent
        hoverEnabled: true
        onEntered: gasRectangle.hovered = true
        onExited: gasRectangle.hovered = false
        onClicked: gasRadioBtn.toggle()
    }
}
