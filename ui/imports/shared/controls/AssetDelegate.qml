import QtQuick 2.13
import QtQml 2.14

import utils 1.0

import shared 1.0
import shared.panels 1.0

Item {
    id: assetDelegate

    QtObject {
        id: _internal
        readonly property var alwaysVisible : ["ETH", "SNT", "DAI", "STT"]
    }

    property string locale: ""
    property string currency: ""
    property string currencySymbol: ""

    anchors.right: parent.right

    anchors.left: parent.left
    visible: _internal.alwaysVisible.includes(symbol) || (networkVisible && enabledNetworkBalance > 0)
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
        anchors.left: assetInfoImage.right
        anchors.leftMargin: Style.current.smallPadding
        anchors.top: assetInfoImage.top
        anchors.topMargin: 0
        font.pixelSize: 15
        text: name
    }

    StyledText {
        id: assetFullTokenName
        anchors.top: assetSymbol.bottom
        anchors.left: assetInfoImage.right
        anchors.leftMargin: Style.current.smallPadding
        font.pixelSize: 15
        color: Style.current.secondaryText
        text: qsTr("%L1 %2").arg(enabledNetworkBalance).arg(symbol)
    }

    StyledText {
        id: assetBalance
        anchors.top: assetInfoImage.top
        anchors.topMargin: 0
        anchors.right: parent.right
        anchors.rightMargin: 0
        font.pixelSize: 15
        font.strikeout: false
        text: enabledNetworkCurrencyBalance.toLocaleCurrencyString(Qt.locale(), assetDelegate.currencySymbol)
    }
}
