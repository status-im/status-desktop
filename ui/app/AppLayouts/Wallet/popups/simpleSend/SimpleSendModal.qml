import QtQuick 2.15
import QtQuick.Layouts 1.14

import StatusQ.Core 0.1
import StatusQ.Controls 0.1
import StatusQ.Core.Theme 0.1
import StatusQ.Popups.Dialog 0.1

import shared.popups.send.views 1.0
import shared.controls 1.0

import AppLayouts.Wallet.panels 1.0

StatusDialog {
    id: root

    /**
    TODO: use the newly defined WalletAccountsSelectorAdaptor
    in https://github.com/status-im/status-desktop/pull/16834
    This will also remove watch only accounts from the list
    Expected model structure:
    - name: name of account
    - address: wallet address
    - color: color of the account
    - emoji: emoji selected for the account
    - currencyBalance: total currency balance in CurrencyAmount
    - accountBalance: balance of selected token + selected chain
    **/
    required property var accountsModel
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
    Only networks valid as per mainnet/testnet selection
    **/
    required property var networksModel

    /** TODO: rethink property definitions needed to pre set values +
    expose values to outside world **/
    property int selectedChainId: sendModalHeader.selectedNetworkChainId
    property string selectedAccountAddress: accountSelector.currentAccountAddress

    QtObject {
        id: d

        readonly property bool isScrolling:
            scrollView.flickable.contentY > sendModalHeader.height
    }

    width: 556
    padding: 0
    leftPadding: Theme.xlPadding
    rightPadding: Theme.xlPadding
    topMargin: margins + accountSelector.height + Theme.padding

    background: StatusDialogBackground {
        color: Theme.palette.baseColor3
    }

    Item {
        id: sendModalcontentItem

        anchors.fill: parent
        anchors.top: parent.top

        implicitWidth: parent.width
        implicitHeight: scrollView.implicitHeight

        // Floating account Selector
        AccountSelectorHeader {
            id: accountSelector

            anchors.top: parent.top
            anchors.topMargin: -accountSelector.height - Theme.padding
            anchors.left: parent.left
            anchors.leftMargin: -Theme.xlPadding

            model: root.accountsModel
        }

        // Sticky header only visible when scrolling
        StickySendModalHeader {
            width: root.width
            anchors.top: accountSelector.bottom
            anchors.topMargin:Theme.padding
            anchors.left: parent.left
            anchors.leftMargin: -Theme.xlPadding
            z: 1

            networksModel: root.networksModel
            assetsModel: root.assetsModel
            collectiblesModel: root.collectiblesModel
            isScrolling: d.isScrolling

            onCollectibleSelected: console.log("collectible selected:", key)
            onCollectionSelected: console.log("collection selected:", key)
            onAssetSelected: console.log("asset selected:", key)
        }

        // Main scrollable Layout
        StatusScrollView {
            id: scrollView

            anchors.fill: parent
            anchors.topMargin: 28
            contentWidth: availableWidth

            padding: 0

            StatusScrollBar.vertical {
                id: verticalScrollbar

                parent: sendModalcontentItem
                x: sendModalcontentItem.width + root.rightPadding - verticalScrollbar.width
            }

            ColumnLayout {
                id: scrollViewLayout

                width: scrollView.availableWidth
                spacing: 20

                // Header that scrolls
                SendModalHeader {
                    id: sendModalHeader

                    Layout.fillWidth: true

                    isScrolling: d.isScrolling

                    networksModel: root.networksModel
                    assetsModel: root.assetsModel
                    collectiblesModel: root.collectiblesModel

                    onCollectibleSelected: console.log("collectible selected:", key)
                    onCollectionSelected: console.log("collection selected:", key)
                    onAssetSelected: console.log("asset selected:", key)
                }

                // TODO: Remove these Dummy items added only to test dialog resizing
                readonly property string longLoremIpsum: "Lorem Ipsum is simply dummy text of the printing and typesetting industry. Lorem Ipsum has been the industry's standard dummy text ever since the 1500s, when an unknown printer took a galley of type and scrambled it to make a type specimen book. It has survived not only five centuries, but also the leap into electronic typesetting, remaining essentially unchanged. It was popularised in the 1960s with the release of Letraset sheets containing Lorem Ipsum passages, and more recently with desktop publishing software like Aldus PageMaker including versions of Lorem Ipsum."
                Text {
                    Layout.fillWidth: true
                    text: scrollViewLayout.longLoremIpsum.repeat(3)
                    wrapMode: Text.WordWrap
                }
                Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 200
                    opacity: 0.2
                    color:  "red"
                }
                Text {
                    Layout.fillWidth: true
                    text: scrollViewLayout.longLoremIpsum.repeat(3)
                    wrapMode: Text.WordWrap
                }
                Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 200
                    opacity: 0.2
                    color:  "red"
                }
                // End Dummy items
            }
        }
    }

    // TODO:: move to new location and rework if needed
    footer: TransactionModalFooter {
        width: parent.width
        pending: false
        nextButtonText: qsTr("Review Send")
        maxFiatFees: "..."
        totalTimeEstimate: "..."
    }
}
