import QtQuick 2.13
import QtQuick.Layouts 1.13

import utils 1.0

import StatusQ.Controls 0.1
import StatusQ.Popups 0.1
import StatusQ.Components 0.1
import StatusQ.Core 0.1
import StatusQ.Core.Theme 0.1

import shared.popups.send.controls 1.0
import shared.popups.send.views 1.0

StatusScrollView {
    id: root

    property var selectedRecipient
    property string ensAddressOrEmpty: ""
    property var selectedAsset
    property double amountToSend
    property bool isLoading: false
    property bool interactive: true
    property bool isBridgeTx: false
    property bool isCollectiblesTransfer: false
    property int errorType: Constants.NoError
    property var bestRoutes
    property double totalFeesInFiat
    property bool showUnPreferredChains
    property string currentCurrency

    readonly property bool advancedOrCustomMode: (tabBar.currentIndex === 1) || (tabBar.currentIndex === 2)
    readonly property bool errorMode: advancedNetworkRoutingPage.errorMode

    // Models:
    property var suggestedToNetworksList
    property var fromNetworksList
    property var toNetworksList
    property var flatNetworksModel

    property var formatFiat: function () {}
    property var formatFiatSendMinDecimals: function (amount, applyMinDecimals) {}
    property var formatFiatReceiveMinDecimals: function (amount, applyMinDecimals) {}
    property var weiToEth: function(wei) {}
    property var getGasEthValue: function () {}
    property var getFiatValue: function () {}
    property var getNetworkName: function () {}

    signal recalculateSuggestedRoute()
    signal toggleShowUnPreferredChains()
    signal toggleToDisabledChains(int chainId)
    signal toggleFromDisabledChains(int chainId)
    signal lockCard(int chainId, string amount, bool lock)
    signal setRouteDisabledChains(int chainId, bool disabled)

    QtObject {
        id: d
        readonly property int backgroundRectRadius: 13
        readonly property color backgroundRectColor: Theme.palette.indirectColor1
    }

    contentWidth: availableWidth

    Item {
        width: root.availableWidth

        StatusSwitchTabBar {
            id: tabBar

            anchors.top: parent.top
            anchors.horizontalCenter: parent.horizontalCenter
            visible: !root.isCollectiblesTransfer

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

            anchors.top: !root.isCollectiblesTransfer ? tabBar.bottom: parent.top
            anchors.topMargin: !root.isCollectiblesTransfer ? Style.current.bigPadding: 0
            height: currentIndex == 0 ? networksSimpleRoutingPage.height + networksSimpleRoutingPage.anchors.margins + Style.current.bigPadding:
                                        advancedNetworkRoutingPage.height + advancedNetworkRoutingPage.anchors.margins + Style.current.bigPadding
            width: parent.width
            currentIndex: root.isCollectiblesTransfer ? 0: tabBar.currentIndex === 0 ? 0 : 1

            Rectangle {
                id: simple

                radius: d.backgroundRectRadius
                color: d.backgroundRectColor

                NetworksSimpleRoutingView {
                    id: networksSimpleRoutingPage

                    anchors.top: parent.top
                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.margins: Style.current.padding

                    isBridgeTx: root.isBridgeTx
                    isCollectiblesTransfer: root.isCollectiblesTransfer
                    isLoading: root.isLoading
                    errorMode: root.errorMode
                    errorType: root.errorType

                    // Models:
                    fromNetworksList: root.fromNetworksList
                    toNetworksList: root.suggestedToNetworksList
                    flatNetworksModel: root.flatNetworksModel

                    formatFiat: root.formatFiatReceiveMinDecimals
                    weiToEth: root.weiToEth

                    onRecalculateSuggestedRoute: root.recalculateSuggestedRoute()
                    onSetRouteDisabledChains: root.setRouteDisabledChains(chainId, disabled)
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
                    anchors.right: parent.right
                    anchors.margins: Style.current.padding

                    showUnPreferredChains: root.showUnPreferredChains
                    customMode: tabBar.currentIndex === 2
                    selectedRecipient: root.selectedRecipient
                    ensAddressOrEmpty: root.ensAddressOrEmpty
                    amountToSend: root.amountToSend
                    selectedAsset: root.selectedAsset
                    isLoading: root.isLoading
                    interactive: root.interactive
                    isBridgeTx: root.isBridgeTx
                    errorType: root.errorType

                    // Models
                    fromNetworksList: root.fromNetworksList
                    toNetworksList: root.toNetworksList

                    formatFiat: root.formatFiatMinDecimals
                    weiToEth: root.weiToEth

                    onRecalculateSuggestedRoute: root.recalculateSuggestedRoute()
                    onToggleShowUnPreferredChains: root.toggleShowUnPreferredChains
                    onToggleToDisabledChains: root.toggleToDisabledChains(chainId)
                    onToggleFromDisabledChains: root.toggleFromDisabledChains(chainId)
                    onLockCard: root.lockCard(chainId, amount, lock)
                }
            }
        }

        FeesView {
            id: fees

            width: parent.width
            anchors.top: stackLayout.bottom
            anchors.topMargin: Style.current.bigPadding
            visible: root.advancedOrCustomMode

            selectedAsset: root.selectedAsset
            isLoading: root.isLoading
            bestRoutes: root.bestRoutes
            gasFiatAmount: root.totalFeesInFiat
            errorType: root.errorType
            currentCurrency: root.currentCurrency

            getGasEthValue: root.getGasEthValue
            getFiatValue: root.getFiatValue
            getNetworkName: root.getNetworkName
            formatFiat: root.formatFiat
        }
    }

    Behavior on implicitHeight {
        NumberAnimation { duration: 700; easing.type: Easing.OutExpo; alwaysRunToEnd: true}
    }
}
