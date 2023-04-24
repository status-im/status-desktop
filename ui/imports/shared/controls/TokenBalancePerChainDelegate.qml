import QtQuick 2.13

import StatusQ.Core 0.1
import StatusQ.Components 0.1
import StatusQ.Core.Theme 0.1

import utils 1.0

StatusListItem {
    id: root

    property var getNetworkIcon: function(chainId){
        return ""
    }
    signal tokenSelected(var selectedToken)
    signal tokenHovered(var selectedToken, bool hovered)

    title: name
    titleAsideText: symbol
    statusListItemTitleAside.font.pixelSize: 15
    label: LocaleUtils.currencyAmountToLocaleString(totalCurrencyBalance)
    asset.name: symbol ? Style.png("tokens/" + symbol) : ""
    asset.isImage: true
    asset.width: 32
    asset.height: 32
    statusListItemLabel.anchors.verticalCenterOffset: -12
    statusListItemLabel.color: Theme.palette.directColor1
    statusListItemInlineTagsSlot.spacing: sensor.containsMouse ? 0 :  -8
    tagsModel: balances.count > 0 ? balances : []
    tagsDelegate: sensor.containsMouse ? expandedItem : compactItem
    radius: sensor.containsMouse || root.highlighted ? 0 : 8
    color: sensor.containsMouse || highlighted ? Theme.palette.baseColor2 : "transparent"

    onClicked: d.selectToken()

    Connections {
        target: root.sensor
        function onContainsMouseChanged() {
            root.tokenHovered({name, symbol, totalBalance, totalCurrencyBalance, balances, decimals}, root.sensor.containsMouse)
        }
    }

    QtObject {
        id: d

        function selectToken() {
            root.tokenSelected({name, symbol, totalBalance, totalCurrencyBalance, balances, decimals})
        }
    }

    Component {
        id: compactItem
        StatusRoundedImage {
            z: index + 1
            width: 16
            height: 16
            image.source: Style.svg("tiny/%1".arg(root.getNetworkIcon(chainId)))
        }
    }
    Component {
        id: expandedItem
        StatusListItemTag {
            height: 16
            title: LocaleUtils.currencyAmountToLocaleString(balance)
            titleText.font.pixelSize: 12
            closeButtonVisible: false
            bgColor: "transparent"
            asset.width: 16
            asset.height: 16
            asset.isImage: true
            asset.name: Style.svg("tiny/%1".arg(root.getNetworkIcon(chainId)))
        }
    }
}
