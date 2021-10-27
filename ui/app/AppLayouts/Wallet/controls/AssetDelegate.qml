import QtQuick 2.13

import utils 1.0

import shared 1.0
import shared.panels 1.0

Item {
    id: assetDelegate

    property string defaultCurrency: ""

    anchors.right: parent.right
    anchors.left: parent.left
    height: 40

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
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 0
        anchors.left: assetInfoImage.right
        anchors.leftMargin: Style.current.smallPadding
        color: Style.current.secondaryText
        font.pixelSize: 15
    }
    StyledText {
        id: assetValue
        text: value.toUpperCase() + " " + symbol
        anchors.right: parent.right
        anchors.rightMargin: 0
        font.pixelSize: 15
        font.strikeout: false
    }
    StyledText {
        id: assetFiatValue
        color: Style.current.secondaryText
        text: Utils.toLocaleString(fiatBalance, globalSettings.locale) + " " + assetDelegate.defaultCurrency.toUpperCase()
        anchors.right: parent.right
        anchors.rightMargin: 0
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 0
        font.pixelSize: 15
    }
}
