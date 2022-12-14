import QtQuick 2.13
import QtQuick.Layouts 1.13

import StatusQ.Core 0.1
import StatusQ.Core.Theme 0.1

import utils 1.0

ColumnLayout {
    id: root

    property var store
    property var selectedAsset
    property bool isLoading: false
    property string amountToReceive
    property bool isBridgeTx: false
    property bool cryptoFiatFlipped: false

    QtObject {
        id: d
        function formatValue(value) {
            const precision = (value === 0 ? 2 : 0)
            return LocaleUtils.numberToLocaleString(value, precision)
        }
        readonly property string fiatValue: {
            if(!root.selectedAsset || !amountToReceive)
                return formatValue(0)
            let cryptoValue = root.store.getFiatValue(amountToReceive, root.selectedAsset.symbol, root.store.currentCurrency)
            return formatValue(parseFloat(cryptoValue))
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
            text: isLoading ? "..." : cryptoFiatFlipped ? d.fiatValue: amountToReceive
            font.pixelSize: Utils.getFontSizeBasedOnLetterCount(text)
            color: Theme.palette.directColor1
        }
        StatusBaseText {
            Layout.alignment: Qt.AlignVCenter
            text: isLoading ? "..." : root.store.currentCurrency.toUpperCase()
            font.pixelSize: amountToReceiveText.font.pixelSize
            color: Theme.palette.directColor1
            visible: cryptoFiatFlipped
        }
    }
    RowLayout {
        Layout.alignment: Qt.AlignRight | Qt.AlignBottom
        StatusBaseText {
            id: txtFiatBalance
            Layout.alignment: Qt.AlignLeft | Qt.AlignTop
            text: isLoading ? "..." : cryptoFiatFlipped ? amountToReceive : d.fiatValue
            font.pixelSize: 13
            color: Theme.palette.directColor5
        }
        StatusBaseText {
            Layout.alignment: Qt.AlignTop
            Layout.leftMargin: 4
            text: isLoading ? "..." : !cryptoFiatFlipped ? root.store.currentCurrency.toUpperCase() : !!root.selectedAsset ? root.selectedAsset.symbol.toUpperCase() : ""
            font.pixelSize: 13
            color: Theme.palette.directColor5
        }
    }
}

