import QtQuick 2.14
import QtGraphicalEffects 1.15

import StatusQ.Core.Theme 0.1
import StatusQ.Popups.Dialog 0.1

Rectangle {
    id: root

    /**
    Expected model structure:
    - tokensKey: unique string ID of the token (asset); e.g. "ETH" or contract address
    - name: user visible token name (e.g. "Ethereum")
    - symbol: user visible token symbol (e.g. "ETH")
    - decimals: number of decimal places
    - communityId:optional; ID of the community this token belongs to, if any
    - marketDetails: object containing props like `currencyPrice` for the computed values below
    - balances: submodel[ chainId:int, account:string, balance:BigIntString, iconUrl:string ]
    - currentBalance: amount of tokens
    - currencyBalance: e.g. `1000.42` in user's fiat currency
    - currencyBalanceAsString: e.g. "1 000,42 CZK" formatted as a string according to the user's locale
    - balanceAsString: `1.42` formatted as e.g. "1,42" in user's locale
    - iconSource: string
    **/
    required property var assetsModel
    /**
    Expected model structure:
    - groupName: group name (from collection or community name)
    - icon: from imageUrl or mediaUrl
    - type: can be "community" or "other"
    - subitems: submodel of collectibles/collections of the group
    - key: key of collection (community type) or collectible (other type)
    - name: name of the subitem (of collectible or collection)
    - balance: balance of collection (in case of community collectibles)
               or collectible (in case of ERC-1155)
    - icon: icon of the subitem
    **/
    required property var collectiblesModel
    /**
    Expected model structure:
    - chainId: network chain id
    - chainName: name of network
    - iconUrl: network icon url
    **/
    required property var networksModel

    /** this property decided if the sticky header is visible or not.
    Not using visible property directly here as the animation on
    implicitHeight doesnt work
    **/
    property bool isScrolling

    /** input property for programatic selection of network **/
    property int selectedChainId: -1

    /** signal to propagate that an asset was selected **/
    signal assetSelected(string key)
    /** signal to propagate that a collection was selected **/
    signal collectionSelected(string key)
    /** signal to propagate that a collectible was selected **/
    signal collectibleSelected(string key)
    /** signal to propagate that a network was selected **/
    signal networkSelected(string chainId)

    /** input function for programatic selection of token
    (asset/collectible/collection) **/
    function setToken(name, icon, key) {
        sendModalHeader.setToken(name, icon, key)
    }

    enabled: root.isScrolling
    color: Theme.palette.baseColor3
    radius: 8

    implicitHeight: root.isScrolling ?
                        sendModalHeader.implicitHeight +
                        sendModalHeader.anchors.topMargin +
                        sendModalHeader.anchors.bottomMargin:
                        0
    implicitWidth: sendModalHeader.implicitWidth +
                   sendModalHeader.anchors.leftMargin +
                   sendModalHeader.anchors.rightMargin


    // Drawer animation for stickey heade
    Behavior on implicitHeight {
        NumberAnimation { duration: 350 }
    }

    // cover for the bottom rounded corners
    Rectangle {
        width: parent.width
        height: parent.radius
        anchors.bottom: parent.bottom
        color: parent.color
    }

    SendModalHeader {
        id: sendModalHeader

        width: parent.width

        anchors {
            fill: parent
            leftMargin: Theme.xlPadding
            rightMargin: Theme.xlPadding
            topMargin: 16
            bottomMargin: 12
        }

        isStickyHeader: true
        isScrolling: root.isScrolling

        networksModel: root.networksModel
        assetsModel: root.assetsModel
        collectiblesModel: root.collectiblesModel

        selectedChainId: root.selectedChainId

        onCollectibleSelected: root.collectibleSelected(key)
        onCollectionSelected: root.collectionSelected(key)
        onAssetSelected: root.assetSelected(key)
        onNetworkSelected: root.networkSelected(chainId)
    }

    StatusDialogDivider {
        anchors.bottom: parent.bottom
        width: parent.width
    }

    layer.enabled: true
    layer.effect: DropShadow {
        horizontalOffset: 0
        verticalOffset: 2
        samples: 37
        color: Theme.palette.dropShadow
    }
}

