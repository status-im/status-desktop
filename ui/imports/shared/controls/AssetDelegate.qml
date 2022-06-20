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
    visible: networkVisible && enabledNetworkBalance > 0
    height: visible ? Style.dp(40) + 2 * Style.current.padding : 0


    Image {
        id: assetInfoImage
        width: Style.dp(36)
        height: Style.dp(36)
        fillMode: Image.PreserveAspectFit
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
        font.pixelSize: Style.current.primaryTextFontSize
    }
    StyledText {
        id: assetFullTokenName
        text: name
        anchors.top: assetSymbol.bottom
        anchors.left: assetInfoImage.right
        anchors.leftMargin: Style.current.smallPadding
        color: Style.current.secondaryText
        font.pixelSize: Style.current.primaryTextFontSize
    }
    StyledText {
        id: assetBalance
        text: Utils.toLocaleString(enabledNetworkBalance, locale) + " " + symbol.toUpperCase()
        anchors.top: assetInfoImage.top
        anchors.topMargin: 0
        anchors.right: parent.right
        anchors.rightMargin: 0
        font.pixelSize: Style.current.primaryTextFontSize
        font.strikeout: false
    }
    StyledText {
        id: assetCurrencyBalance
        color: Style.current.secondaryText
        text: Utils.toLocaleString(enabledNetworkCurrencyBalance.toFixed(2), locale) + " " + assetDelegate.currency.toUpperCase()
        anchors.right: parent.right
        anchors.rightMargin: 0
        anchors.top: assetBalance.bottom
        font.pixelSize: Style.current.primaryTextFontSize
    }
}
