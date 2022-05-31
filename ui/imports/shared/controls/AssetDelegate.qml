import QtQuick 2.13

import utils 1.0

import shared 1.0
import shared.panels 1.0

Item {
    id: assetDelegate

    property string locale: ""
    property string currency: ""

    anchors.right: parent.right

    anchors.left: parent.left
    visible: balance > 0
    height: visible ? 40 + 2 * Style.current.padding : 0


    Image {
        id: assetInfoImage
        width: 36
        height: 36
        source: symbol ? Style.png("tokens/" + symbol) : ""
        anchors.left: parent.left
        anchors.leftMargin: 0
        anchors.verticalCenter: parent.verticalCenter
        onStatusChanged: {
            if (assetInfoImage.status == Image.Error) {
                assetInfoImage.source = Style.png("tokens/DEFAULT-TOKEN@3x")
            }
        }
    }
    StyledText {
        id: assetSymbol
        text: symbol
        anchors.left: assetInfoImage.right
        anchors.leftMargin: Style.current.smallPadding
        anchors.top: assetInfoImage.top
        anchors.topMargin: 0
        font.pixelSize: 15
    }
    StyledText {
        id: assetFullTokenName
        text: name
        anchors.top: assetSymbol.bottom
        anchors.left: assetInfoImage.right
        anchors.leftMargin: Style.current.smallPadding
        color: Style.current.secondaryText
        font.pixelSize: 15
    }
    StyledText {
        id: assetBalance
        text: Utils.toLocaleString(balance, locale) + " " + symbol.toUpperCase()
        anchors.top: assetInfoImage.top
        anchors.topMargin: 0
        anchors.right: parent.right
        anchors.rightMargin: 0
        font.pixelSize: 15
        font.strikeout: false
    }
    StyledText {
        id: assetCurrencyBalance
        color: Style.current.secondaryText
        text: Utils.toLocaleString(currencyBalance.toFixed(2), locale) + " " + assetDelegate.currency.toUpperCase()
        anchors.right: parent.right
        anchors.rightMargin: 0
        anchors.top: assetBalance.bottom
        font.pixelSize: 15
    }
}
