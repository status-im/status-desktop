import QtQuick 2.13
import QtQuick.Layouts 1.13

import utils 1.0
import shared.stores 1.0

import StatusQ.Controls 0.1
import StatusQ.Popups 0.1
import StatusQ.Components 0.1
import StatusQ.Core 0.1
import StatusQ.Core.Theme 0.1

import "../controls"

Item {
    id: root

    implicitHeight: visible ? tabBar.height + stackLayout.height + Style.current.xlPadding : 0

    property var store
    property var currencyStore : store.currencyStore
    property var selectedAccount
    property string ensAddressOrEmpty: ""
    property var selectedAsset
    property double amountToSend
    property int minSendCryptoDecimals: 0
    property int minReceiveCryptoDecimals: 0
    property bool isLoading: false
    property bool advancedOrCustomMode: (tabBar.currentIndex === 1) || (tabBar.currentIndex === 2)
    property bool errorMode: advancedNetworkRoutingPage.errorMode
    property bool interactive: true
    property bool isBridgeTx: false
    property bool isERC721Transfer: false
    property var toNetworksList
    property int errorType: Constants.NoError

    signal reCalculateSuggestedRoute()

    QtObject {
        id: d
        readonly property int backgroundRectRadius: 13
        readonly property color backgroundRectColor: Theme.palette.indirectColor1
    }

    StatusSwitchTabBar {
        id: tabBar
        anchors.top: parent.top
        anchors.horizontalCenter: parent.horizontalCenter
        visible: !root.isERC721Transfer
        StatusSwitchTabButton {
            text: qsTr("Simple")
        }
        StatusSwitchTabButton {
            text: qsTr("Advanced")
        }
        StatusSwitchTabButton {
            text: qsTr("Custom")
        }
    }

    StackLayout {
        id: stackLayout
        anchors.top: !root.isERC721Transfer ? tabBar.bottom: parent.top
        anchors.topMargin: !root.isERC721Transfer ? Style.current.bigPadding: 0
        height: currentIndex == 0 ? networksSimpleRoutingPage.height + networksSimpleRoutingPage.anchors.margins + Style.current.bigPadding:
                                   advancedNetworkRoutingPage.height + advancedNetworkRoutingPage.anchors.margins + Style.current.bigPadding
        width: parent.width
        currentIndex: root.isERC721Transfer ? 0: tabBar.currentIndex === 0 ? 0 : 1

        Rectangle {
            id: simple
            radius: d.backgroundRectRadius
            color: d.backgroundRectColor
            NetworksSimpleRoutingView {
                id: networksSimpleRoutingPage
                anchors.top: parent.top
                anchors.left: parent.left
                anchors.margins: Style.current.padding
                width: stackLayout.width  - Style.current.bigPadding
                isBridgeTx: root.isBridgeTx
                isERC721Transfer: root.isERC721Transfer
                minReceiveCryptoDecimals: root.minReceiveCryptoDecimals
                isLoading: root.isLoading
                store: root.store
                selectedAccount: root.selectedAccount
                errorMode: root.errorMode
                errorType: root.errorType
                toNetworksList: root.toNetworksList
                weiToEth: function(wei) {
                    if(!!selectedAsset && root.selectedAsset !== undefined)
                        return parseFloat(store.getWei2Eth(wei, root.selectedAsset.decimals))
                }
                formatCurrencyAmount: root.currencyStore.formatCurrencyAmount
                reCalculateSuggestedRoute: function() {
                    root.reCalculateSuggestedRoute()
                }
            }
        }

        Rectangle {
            id: advanced
            radius: d.backgroundRectRadius
            color: d.backgroundRectColor
            NetworksAdvancedCustomRoutingView {
                id: advancedNetworkRoutingPage
                anchors.top: parent.top
                anchors.left: parent.left
                anchors.margins: Style.current.padding
                width: stackLayout.width - Style.current.xlPadding
                store: root.store
                customMode: tabBar.currentIndex === 2
                selectedAccount: root.selectedAccount
                ensAddressOrEmpty: root.ensAddressOrEmpty
                amountToSend: root.amountToSend
                minSendCryptoDecimals: root.minSendCryptoDecimals
                minReceiveCryptoDecimals: root.minReceiveCryptoDecimals
                selectedAsset: root.selectedAsset
                onReCalculateSuggestedRoute: root.reCalculateSuggestedRoute()
                isLoading: root.isLoading
                interactive: root.interactive
                isBridgeTx: root.isBridgeTx
                errorType: root.errorType
                weiToEth: function(wei) {
                    if(!!selectedAsset && selectedAsset !== undefined)
                        return parseFloat(store.getWei2Eth(wei, selectedAsset.decimals))
                }
            }
        }
    }
}
