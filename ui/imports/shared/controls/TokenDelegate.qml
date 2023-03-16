import QtQuick 2.13
import QtQuick.Controls 2.13

import StatusQ.Popups 0.1
import StatusQ.Core.Theme 0.1
import StatusQ.Components 0.1
import StatusQ.Core 0.1
import StatusQ.Controls 0.1

import utils 1.0

StatusListItem {
    id: root

    property alias localeCurrencyBalance: localeCurrencyBalance
    property alias change24Hour: change24HourText
    property alias change24HourPercentage: change24HourPercentageText

    property string currentCurrencySymbol
    property string textColor: changePct24hour === undefined  ? Theme.palette.baseColor1 :
                               Math.sign(changePct24hour) === 0 ? Theme.palette.baseColor1 :
                               Math.sign(changePct24hour) === -1 ? Theme.palette.dangerColor1 :
                                                                           Theme.palette.successColor1

    title: name
    subTitle: LocaleUtils.currencyAmountToLocaleString(enabledNetworkBalance)
    asset.name: symbol ? Style.png("tokens/" + symbol) : ""
    asset.isImage: true

    components: [
        Column {
            id: valueColumn
            StatusTextWithLoadingState   {
                id: localeCurrencyBalance
                anchors.right: parent.right
                font.pixelSize: 15
                font.strikeout: false
                text: LocaleUtils.currencyAmountToLocaleString(enabledNetworkCurrencyBalance)
            }
            Row {
                anchors.horizontalCenter: parent.horizontalCenter
                spacing: 8
                StatusTextWithLoadingState {
                    id: change24HourText
                    font.pixelSize: 15
                    font.strikeout: false
                    customColor: root.textColor
                    text: LocaleUtils.currencyAmountToLocaleString(currencyPrice)
                }
                Rectangle {
                    width: 1
                    height: change24HourText.implicitHeight
                    color: Theme.palette.directColor9
                }
                StatusTextWithLoadingState {
                    id: change24HourPercentageText
                    font.pixelSize: 15
                    font.strikeout: false
                    customColor: root.textColor
                    text: changePct24hour !== "" ? changePct24hour.toFixed(2) + "%" : "---"
                }
            }
        }
    ]
}
