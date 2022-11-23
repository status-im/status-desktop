import QtQuick 2.13
import QtQuick.Controls 2.13

import StatusQ.Popups 0.1
import StatusQ.Core.Theme 0.1
import StatusQ.Components 0.1
import StatusQ.Core 0.1

import utils 1.0

StatusListItem {
    property string currentCurrencySymbol

    title: name
    subTitle: `${enabledNetworkBalance} ${symbol}`
    asset.name: symbol ? Style.png("tokens/" + symbol) : ""
    asset.isImage: true
    components: [
        Column {
            id: valueColumn
            property string textColor: Math.sign(Number(changePct24hour)) === 0 ? Theme.palette.baseColor1 :
                                       Math.sign(Number(changePct24hour)) === -1 ? Theme.palette.dangerColor1 :
                                                                                   Theme.palette.successColor1
            StatusBaseText {
                anchors.right: parent.right
                font.pixelSize: 15
                font.strikeout: false
                text: enabledNetworkCurrencyBalance.toLocaleCurrencyString(Qt.locale(), currentCurrencySymbol)
            }
            Row {
                anchors.horizontalCenter: parent.horizontalCenter
                spacing: 8
                StatusBaseText {
                    id: change24HourText
                    font.pixelSize: 15
                    font.strikeout: false
                    color: valueColumn.textColor
                    text: currencyPrice.toLocaleCurrencyString(Qt.locale(), currentCurrencySymbol)
                }
                Rectangle {
                    width: 1
                    height: change24HourText.implicitHeight
                    color: Theme.palette.directColor9
                }
                StatusBaseText {
                    font.pixelSize: 15
                    font.strikeout: false
                    color: valueColumn.textColor
                    text: changePct24hour !== "" ? "%1%".arg(changePct24hour) : "---"
                }
            }
        }
    ]
}
