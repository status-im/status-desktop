import QtQuick 2.13
import QtQuick.Layouts 1.13

import utils 1.0

import StatusQ.Controls 0.1
import StatusQ.Popups 0.1
import StatusQ.Components 0.1
import StatusQ.Core 0.1
import StatusQ.Core.Theme 0.1

import "../controls"

Item {
    id: root

    height: visible ? tabBar.height + stackLayout.height + 2* Style.current.xlPadding : 0

    property var store
    property var suggestedRoutes
    property var selectedNetwork
    property var selectedAccount
    property var selectedAsset
    property var assets
    property double amountToSend: 0
    property double requiredGasInEth: 0
    property bool errorMode: customNetworkRoutingPage.errorMode

    signal networkChanged(int chainId)
    signal reCalculateSuggestedRoute(var disabledChainIds)

    QtObject {
        id: d
        readonly property int backgroundRectRadius: 13
        readonly property string backgroundRectColor: Theme.palette.indirectColor1
    }

    StatusSwitchTabBar {
        id: tabBar
        anchors.top: parent.top
        anchors.topMargin: Style.current.bigPadding
        anchors.horizontalCenter: parent.horizontalCenter
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
        anchors.top: tabBar.bottom
        anchors.topMargin: Style.current.bigPadding
        height: currentIndex == 0 ? networksSimpleRoutingPage.height + networksSimpleRoutingPage.anchors.margins + Style.current.bigPadding:
                                    currentIndex == 1 ? advancedNetworkRoutingPage.height + advancedNetworkRoutingPage.anchors.margins + Style.current.bigPadding:
                                                        customNetworkRoutingPage.height + customNetworkRoutingPage.anchors.margins + Style.current.bigPadding
        width: parent.width
        currentIndex: tabBar.currentIndex

        Rectangle {
            id: simple
            radius: d.backgroundRectRadius
            color: d.backgroundRectColor
            NetworksSimpleRoutingView {
                id: networksSimpleRoutingPage
                anchors.top: parent.top
                anchors.left: parent.left
                anchors.margins: Style.current.padding
                selectedNetwork: root.selectedNetwork
                suggestedRoutes: root.suggestedRoutes
                amountToSend: root.amountToSend
                onNetworkChanged:  {
                    root.selectedNetwork = network
                    root.networkChanged(network.chainId)
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
                store: root.store
                assets: root.assets
                selectedNetwork: root.selectedNetwork
                selectedAccount: root.selectedAccount
                amountToSend: root.amountToSend
                requiredGasInEth: root.requiredGasInEth
                selectedAsset: root.selectedAsset
                suggestedRoutes: root.suggestedRoutes
                onReCalculateSuggestedRoute: root.reCalculateSuggestedRoute(disabledChainIds)
            }
        }

        Rectangle {
            id: custom
            radius: d.backgroundRectRadius
            color: d.backgroundRectColor
            NetworksAdvancedCustomRoutingView {
                id: customNetworkRoutingPage
                anchors.top: parent.top
                anchors.left: parent.left
                anchors.margins: Style.current.padding
                customMode: true
                store: root.store
                assets: root.assets
                selectedNetwork: root.selectedNetwork
                selectedAccount: root.selectedAccount
                amountToSend: root.amountToSend
                requiredGasInEth: root.requiredGasInEth
                selectedAsset: root.selectedAsset
                suggestedRoutes: root.suggestedRoutes
                onReCalculateSuggestedRoute: root.reCalculateSuggestedRoute(disabledChainIds)
            }
        }
    }
}
