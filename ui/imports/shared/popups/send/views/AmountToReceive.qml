import QtQuick 2.13
import QtQuick.Layouts 1.13

import StatusQ.Core 0.1
import StatusQ.Core.Theme 0.1

import utils 1.0
import shared.stores 1.0

ColumnLayout {
    id: root

    property string selectedSymbol
    property bool isLoading: false
    property double cryptoValueToReceive
    property bool isBridgeTx: false
    property bool inputIsFiat: false
    property string currentCurrency
    property int minCryptoDecimals: 0
    property int minFiatDecimals: 0
    property var getFiatValue: function(cryptoValue) {}
    property var formatCurrencyAmount: function() {}

    QtObject {
        id: d
        readonly property string fiatValue: {
            if(!root.selectedSymbol || !cryptoValueToReceive)
                return LocaleUtils.numberToLocaleString(0, 2)
            let fiatValue = root.getFiatValue(cryptoValueToReceive, root.selectedSymbol, root.currentCurrency)
            return root.formatCurrencyAmount(fiatValue, root.currentCurrency, inputIsFiat ? {"minDecimals": root.minFiatDecimals, "stripTrailingZeroes": true} : {})
        }
        readonly property string cryptoValue: {
            if(!root.selectedSymbol || !cryptoValueToReceive)
                return LocaleUtils.numberToLocaleString(0, 2)
            return root.formatCurrencyAmount(cryptoValueToReceive, root.selectedSymbol, !inputIsFiat ? {"minDecimals": root.minCryptoDecimals, "stripTrailingZeroes": true} : {})
        }
    }

    StatusBaseText {
        Layout.alignment: Qt.AlignRight | Qt.AlignTop
        text: root.isBridgeTx ? qsTr("Amount Bridged") : qsTr("Recipient will get")
        font.pixelSize: 13
        lineHeight: 18
        lineHeightMode: Text.FixedHeight
        color: Theme.palette.directColor1
    }
    RowLayout {
        Layout.alignment: Qt.AlignRight
        Layout.preferredHeight: 42
        StatusBaseText {
            id: amountToReceiveText
            Layout.alignment: Qt.AlignVCenter
            text: isLoading ? "..." : inputIsFiat ? d.fiatValue : d.cryptoValue
            font.pixelSize: Utils.getFontSizeBasedOnLetterCount(text)
            color: Theme.palette.directColor1
        }
    }
    RowLayout {
        Layout.alignment: Qt.AlignRight | Qt.AlignBottom
        StatusBaseText {
            id: txtFiatBalance
            Layout.alignment: Qt.AlignLeft | Qt.AlignTop
            text: isLoading ? "..." : inputIsFiat ? d.cryptoValue : d.fiatValue
            font.pixelSize: 13
            color: Theme.palette.directColor5
        }
    }
}

