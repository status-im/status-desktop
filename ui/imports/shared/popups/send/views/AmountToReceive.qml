import QtQuick
import QtQuick.Layouts

import StatusQ.Core
import StatusQ.Core.Theme

import utils
import shared.stores

ColumnLayout {
    id: root

    property var selectedHolding
    property bool isLoading: false
    property double cryptoValueToReceive
    property bool isBridgeTx: false
    property bool inputIsFiat: false
    property string currentCurrency
    property int minCryptoDecimals: 0
    property int minFiatDecimals: 0
    property var formatCurrencyAmount: function() {}

    QtObject {
        id: d
        readonly property string fiatValue: {
            if(!root.selectedHolding || !root.selectedHolding.symbol || !root.selectedHolding.marketDetails ||
                    !root.selectedHolding.marketDetails.currencyPrice || !cryptoValueToReceive)
                return LocaleUtils.numberToLocaleString(0, 2)
            let fiatValue = cryptoValueToReceive * root.selectedHolding.marketDetails.currencyPrice.amount
            return root.formatCurrencyAmount(fiatValue, root.currentCurrency, inputIsFiat ? {"minDecimals": root.minFiatDecimals, "stripTrailingZeroes": true} : {})
        }
        readonly property string cryptoValue: {
            if(!root.selectedHolding || !root.selectedHolding.symbol || !cryptoValueToReceive)
                return LocaleUtils.numberToLocaleString(0, 2)
            return root.formatCurrencyAmount(cryptoValueToReceive, root.selectedHolding.symbol, !inputIsFiat ? {"minDecimals": root.minCryptoDecimals, "stripTrailingZeroes": true} : {})
        }
    }

    StatusBaseText {
        Layout.alignment: Qt.AlignRight | Qt.AlignTop
        text: root.isBridgeTx ? qsTr("Amount Bridged") : qsTr("Recipient will get")
        font.pixelSize: Theme.additionalTextSize
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
            font.pixelSize: Theme.fontSize(34)
            color: Theme.palette.directColor1
        }
    }
    RowLayout {
        Layout.alignment: Qt.AlignRight | Qt.AlignBottom
        StatusBaseText {
            id: txtFiatBalance
            Layout.alignment: Qt.AlignLeft | Qt.AlignTop
            text: isLoading ? "..." : inputIsFiat ? d.cryptoValue : d.fiatValue
            font.pixelSize: Theme.additionalTextSize
            color: Theme.palette.directColor5
        }
    }
}

