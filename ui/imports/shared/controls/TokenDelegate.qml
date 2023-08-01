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
    property string textColor: {
        if (!modelData) {
            return Theme.palette.successColor1
        }
        return modelData.changePct24hour === undefined  ?
            Theme.palette.baseColor1 :
            modelData.changePct24hour === 0 ?
                Theme.palette.baseColor1 :
                modelData.changePct24hour < 0 ?
                    Theme.palette.dangerColor1 :
                    Theme.palette.successColor1
    }
        
    property string errorTooltipText_1
    property string errorTooltipText_2

    readonly property string symbolUrl: !!modelData && modelData.symbol ? Constants.tokenIcon(modelData.symbol, false) : ""

    title: modelData ? modelData.name : ""
    subTitle: LocaleUtils.currencyAmountToLocaleString(modelData.enabledNetworkBalance)
    asset.name: symbolUrl
    asset.isImage: true
    errorIcon.tooltip.maxWidth: 300

    statusListItemTitleIcons.sourceComponent: StatusFlatRoundButton {
        width: 14
        height: visible ? 14 : 0
        icon.width: 14
        icon.height: 14
        icon.name: "tiny/warning"
        icon.color: Theme.palette.dangerColor1
        tooltip.text: root.errorTooltipText_1
        tooltip.maxWidth: 300
        visible: !!tooltip.text
    }

    components: [
        Column {
            id: valueColumn
            StatusFlatRoundButton {
                id: errorIcon
                width: 14
                height: visible ? 14 : 0
                icon.width: 14
                icon.height: 14
                icon.name: "tiny/warning"
                icon.color: Theme.palette.dangerColor1
                tooltip.text: root.errorTooltipText_2
                tooltip.maxWidth: 200
                visible: !!tooltip.text
            }
            StatusTextWithLoadingState   {
                id: localeCurrencyBalance
                anchors.right: parent.right
                font.pixelSize: 15
                text: modelData ? LocaleUtils.currencyAmountToLocaleString(modelData.enabledNetworkCurrencyBalance) : ""
                visible: !errorIcon.visible
            }
            Row {
                anchors.horizontalCenter: parent.horizontalCenter
                spacing: 8
                visible: !errorIcon.visible
                StatusTextWithLoadingState {
                    id: change24HourText
                    font.pixelSize: 15
                    customColor: root.textColor
                    text: modelData ? LocaleUtils.currencyAmountToLocaleString(modelData.currencyPrice) : ""
                }
                Rectangle {
                    width: 1
                    height: change24HourText.implicitHeight
                    color: Theme.palette.directColor9
                }
                StatusTextWithLoadingState {
                    id: change24HourPercentageText
                    font.pixelSize: 15
                    customColor: root.textColor
                    text: modelData && modelData.changePct24hour !== "" ? "%1%".arg(LocaleUtils.numberToLocaleString(modelData.changePct24hour, 2)) : "---"
                }
            }
        }
    ]

    states: [
        State {
            name: "unkownToken"
            when: !root.symbolUrl
            PropertyChanges {
                target: root.asset
                isLetterIdenticon: true
                color: Theme.palette.miscColor5
                name: !!modelData && modelData.symbol ? modelData.symbol : ""
            }
        }

    ]
}
