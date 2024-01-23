import QtQuick 2.13

import StatusQ 0.1
import StatusQ.Core 0.1
import StatusQ.Components 0.1
import StatusQ.Core.Theme 0.1
import StatusQ.Core.Utils 0.1 as SQUtils
import SortFilterProxyModel 0.2

import utils 1.0

StatusListItem {
    id: root

    signal tokenSelected(var selectedToken)
    signal tokenHovered(var selectedToken, bool hovered)
    property var getCurrencyAmountFromBigInt: function(balance, symbol, decimals){}
    property var getCurrentCurrencyAmount: function(balance){}
    property var balancesModel
    property string selectedSenderAccount

    QtObject {
        id: d

        readonly property int indexesThatCanBeShown:
            Math.floor((root.statusListItemInlineTagsSlot.availableWidth
                        - compactRow.width) / statusListItemInlineTagsSlot.children[0].width) - 1

        function selectToken() {
            root.tokenSelected({name, symbol, balances, decimals})
        }

        readonly property string balanceRoleName: "balance"
        property string roleName: balanceRoleName
    }

    property var filteredBalances : SortFilterProxyModel {
        sourceModel: root.balancesModel
        filters: FastExpressionFilter {
            expression: {
                root.selectedSenderAccount
                return root.selectedSenderAccount === model.account
            }
            expectedRoles: ["account"]
        }
        onCountChanged: {
            // Added because the SumAggregator is not evaluated after the filters are applied
            d.roleName = ""
            d.roleName = d.balanceRoleName
        }
    }

    Connections {
        target: root.sensor
        function onContainsMouseChanged() {
            root.tokenHovered({name, symbol, balances, decimals},
                              root.sensor.containsMouse)
        }
    }

    title: name
    titleAsideText: symbol
    statusListItemTitleAside.font.pixelSize: 15
    statusListItemTitleAside.width: statusListItemTitleArea.width - statusListItemTitle.width
    statusListItemTitleAside.elide: Text.ElideRight
    label: {
        if (!!model && !!model.marketDetails && !!model.marketDetails.currencyPrice) {
            let totalCurrencyBalance = aggregator.value/(10 ** decimals) * model.marketDetails.currencyPrice.amount
            return LocaleUtils.currencyAmountToLocaleString(root.getCurrentCurrencyAmount(totalCurrencyBalance))
        }
        return LocaleUtils.currencyAmountToLocaleString(root.getCurrentCurrencyAmount(0))
    }
    asset.name: symbol ? Style.png("tokens/" + symbol) : ""
    asset.isImage: true
    asset.width: 32
    asset.height: 32
    statusListItemLabel.anchors.verticalCenterOffset: -12
    statusListItemLabel.color: Theme.palette.directColor1
    statusListItemInlineTagsSlot.spacing: 0
    tagsModel: filteredBalances
    tagsDelegate: expandedItem
    statusListItemInlineTagsSlot.children: Row {
        id: compactRow
        spacing: -6
        Repeater {
            model: filteredBalances
            delegate: compactItem
        }
    }

    radius: sensor.containsMouse || root.highlighted ? 0 : 8
    color: sensor.containsMouse || highlighted ? Theme.palette.baseColor2 : "transparent"

    onClicked: d.selectToken()

    SumAggregator {
        id: aggregator
        model: filteredBalances
        roleName: d.roleName
    }

    Component {
        id: compactItem
        StatusRoundedImage {
            z: index + 1
            width: 16
            height: 16
            image.source: Style.svg("tiny/%1".arg(model.iconUrl))
            visible: !root.sensor.containsMouse || index > d.indexesThatCanBeShown
        }
    }
    Component {
        id: expandedItem
        StatusListItemTag {
            height: 16
            leftPadding: 0
            title: LocaleUtils.currencyAmountToLocaleString(root.getCurrencyAmountFromBigInt(balance, symbol, decimals))
            titleText.font.pixelSize: 12
            closeButtonVisible: false
            bgColor: "transparent"
            asset.width: 16
            asset.height: 16
            asset.isImage: true
            asset.name: Style.svg("tiny/%1".arg(iconUrl))
            visible: root.sensor.containsMouse && index <= d.indexesThatCanBeShown
        }
    }
}
