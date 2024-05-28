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

    objectName: "tokenBalancePerChainDelegate"

    signal tokenSelected(var selectedToken)
    signal tokenHovered(var selectedToken, bool hovered)
    property var formatCurrentCurrencyAmount: function(balance){}
    property var formatCurrencyAmountFromBigInt: function(balance, symbol, decimals){}
    property var balancesModel

    QtObject {
        id: d

        function selectToken() {
            root.tokenSelected({name, symbol, balances, decimals})
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
    titleAsideText: symbol ?? ""
    statusListItemTitleAside.font.pixelSize: 15
    statusListItemTitleAside.width: statusListItemTitleArea.width - statusListItemTitle.width
    statusListItemTitleAside.elide: Text.ElideRight
    label: {
        let balance = !!model && !!model.currentCurrencyBalance ? model.currentCurrencyBalance : 0
        return root.formatCurrentCurrencyAmount(balance)
    }
    // Community assets have a dedicated image streamed from status-go
    asset.name: !!model && !!model.image
                ? model.image
                : Constants.tokenIcon(symbol)
    asset.isImage: true
    asset.width: 32
    asset.height: 32
    statusListItemLabel.anchors.verticalCenterOffset: -12
    statusListItemLabel.color: Theme.palette.directColor1
    statusListItemInlineTagsSlot.spacing: 0
    tagsModel: root.balancesModel
    tagsDelegate: expandedItem
    tagsScrollBarVisible: false

    radius: sensor.containsMouse || highlighted ? 0 : 8
    color: sensor.containsMouse || highlighted ? Theme.palette.statusListItem.highlightColor : "transparent"

    onClicked: d.selectToken()

    Component {
        id: expandedItem
        StatusListItemTag {
            height: 16
            leftPadding: 0
            title: root.formatCurrencyAmountFromBigInt(balance, symbol, decimals)
            titleText.font.pixelSize: 12
            closeButtonVisible: false
            bgColor: "transparent"
            asset.width: 16
            asset.height: 16
            asset.isImage: true
            asset.name: Style.svg("tiny/%1".arg(model.iconUrl))
            tagClickable: true
            onTagClicked: d.selectToken()
        }
    }
}
