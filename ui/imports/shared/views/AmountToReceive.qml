import QtQuick 2.13
import QtQuick.Layouts 1.13

import StatusQ.Core 0.1
import StatusQ.Core.Theme 0.1

import utils 1.0
import shared.stores 1.0

ColumnLayout {
    id: root

    property var store
    property var selectedAsset
    property bool isLoading: false
    property var cryptoValueToReceive
    property bool isBridgeTx: false
    property bool inputIsFiat: false
    property string currentCurrency
    property var getFiatValue: function(cryptoValue) {}

    QtObject {
        id: d
        readonly property string fiatValue: {
            if(!root.selectedAsset || !cryptoValueToReceive)
                return LocaleUtils.numberToLocaleString(0, 2)
            let fiatValue = root.getFiatValue(cryptoValueToReceive.amount, root.selectedAsset.symbol, RootStore.currentCurrency)
            return LocaleUtils.currencyAmountToLocaleString(fiatValue)
        }
        readonly property string cryptoValue: {
            if(!root.selectedAsset || !cryptoValueToReceive)
                return LocaleUtils.numberToLocaleString(0, 2)
            return LocaleUtils.currencyAmountToLocaleString(cryptoValueToReceive)
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

