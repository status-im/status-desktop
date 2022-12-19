import QtQuick 2.13
import QtQuick.Layouts 1.13

import StatusQ.Core 0.1
import StatusQ.Core.Theme 0.1
import StatusQ.Controls.Validators 0.1

import "../controls"

import utils 1.0

ColumnLayout {
    id: root

    property alias input: amountToSendInput

    property var selectedAsset
    property bool isBridgeTx: false
    property bool interactive: false
    property double maxFiatBalance: -1
    property bool cryptoFiatFlipped: false
    property string cryptoValueToSend: !cryptoFiatFlipped ? amountToSendInput.text : txtFiatBalance.text
    property string currentCurrency
    property var getFiatValue: function(cryptoValue) {}
    property var getCryptoValue: function(fiatValue) {}

    signal reCalculateSuggestedRoute()

    QtObject {
        id: d
        readonly property string zeroString: formatValue(0, 2)
        property Timer waitTimer: Timer {
            interval: 1000
            onTriggered: reCalculateSuggestedRoute()
        }
        function formatValue(value, precision) {
            const precisionVal = !!precision ? precision : (value === 0 ? 2 : 0)
            return LocaleUtils.numberToLocaleString(value, precisionVal)
        }
        function getFiatValue(value) {
            if(!root.selectedAsset || !value)
                return zeroString
            let cryptoValue = root.getFiatValue(value)
            return formatValue(parseFloat(cryptoValue))
        }
        function getCryptoValue(value) {
            if(!root.selectedAsset || !value)
                return zeroString
            let cryptoValue = root.getCryptoValue(value)
            return formatValue(parseFloat(cryptoValue))
        }
    }

    onSelectedAssetChanged: {
        if(!!root.selectedAsset) {
            txtFiatBalance.text = !cryptoFiatFlipped ? d.getFiatValue(amountToSendInput.text): d.getCryptoValue(amountToSendInput.text)
        }
    }

    onMaxFiatBalanceChanged: {
        floatValidator.top = maxFiatBalance
        input.validate()
    }

    StatusBaseText {
        Layout.alignment: Qt.AlignLeft | Qt.AlignTop
        text: root.isBridgeTx ? qsTr("Amount to bridge") : qsTr("Amount to send")
        font.pixelSize: 13
        lineHeight: 18
        lineHeightMode: Text.FixedHeight
        color: Theme.palette.directColor1
    }
    RowLayout {
        Layout.alignment: Qt.AlignLeft
        AmountInputWithCursor {
            id: amountToSendInput
            Layout.alignment: Qt.AlignVCenter | Qt.AlignLeft
            Layout.maximumWidth: 163
            Layout.preferredWidth: (!!text) ? input.edit.paintedWidth : textMetrics.advanceWidth
            placeholderText: d.zeroString
            input.edit.color: input.valid ? Theme.palette.directColor1 : Theme.palette.dangerColor1
            input.edit.readOnly: !root.interactive
            validators: [
                StatusFloatValidator {
                    id: floatValidator
                    bottom: 0
                    top: root.maxFiatBalance
                    errorMessage: ""
                }
            ]
            TextMetrics {
                id: textMetrics
                text: amountToSendInput.placeholderText
                font: amountToSendInput.input.placeholder.font
            }
            Keys.onReleased: {
                const amount = amountToSendInput.text.trim()
                if (!Utils.containsOnlyDigits(amount) || isNaN(amount)) {
                    return
                }
                txtFiatBalance.text = !cryptoFiatFlipped ? d.getFiatValue(amount): d.getCryptoValue(amount)
                d.waitTimer.restart()
            }
        }
        StatusBaseText {
            Layout.alignment: Qt.AlignVCenter
            text: root.currentCurrency.toUpperCase()
            font.pixelSize: amountToSendInput.input.edit.font.pixelSize
            color: Theme.palette.baseColor1
            visible: cryptoFiatFlipped
        }
    }
    Item {
        id: fiatBalanceLayout
        Layout.alignment: Qt.AlignLeft | Qt.AlignBottom
        Layout.preferredWidth: txtFiatBalance.width + currencyText.width
        Layout.preferredHeight: txtFiatBalance.height
        StatusBaseText {
            id: txtFiatBalance
            anchors.top: parent.top
            anchors.left: parent.left
            text: d.getFiatValue(amountToSendInput.text)
            font.pixelSize: 13
            color: Theme.palette.directColor5
        }
        StatusBaseText {
            id: currencyText
            anchors.top: parent.top
            anchors.left: txtFiatBalance.right
            anchors.leftMargin: 4
            text: !cryptoFiatFlipped ? root.currentCurrency.toUpperCase() : !!root.selectedAsset ? root.selectedAsset.symbol.toUpperCase() : ""
            font.pixelSize: 13
            color: Theme.palette.directColor5
        }
        MouseArea {
            anchors.fill: parent
            cursorShape: Qt.PointingHandCursor
            onClicked: {
                cryptoFiatFlipped = !cryptoFiatFlipped
                amountToSendInput.validate()
                if(!!amountToSendInput.text) {
                    const tempVal = Number.fromLocaleString(txtFiatBalance.text)
                    txtFiatBalance.text = !!amountToSendInput.text ? amountToSendInput.text : d.zeroString
                    amountToSendInput.text = tempVal
                }
            }
        }
    }
}

