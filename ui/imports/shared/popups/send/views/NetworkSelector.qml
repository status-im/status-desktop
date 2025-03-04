import QtQuick 2.15
import QtQuick.Layouts 1.15

import utils 1.0
import shared.stores 1.0
import shared.stores.send 1.0 as SharedSendStores

import StatusQ.Controls 0.1
import StatusQ.Popups 0.1
import StatusQ.Components 0.1
import StatusQ.Core 0.1
import StatusQ.Core.Theme 0.1

import shared.popups.send.controls 1.0
import shared.controls 1.0

Item {
    id: root

    property SharedSendStores.TransactionStore store
    property CurrenciesStore currencyStore : store.currencyStore
    required property NetworksStore networksStore
    property var selectedRecipient
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
    property bool isCollectiblesTransfer: false
    property var fromNetworksList
    property var toNetworksList
    property var suggestedToNetworksList
    property int errorType: Constants.NoError
    property var bestRoutes
    property double totalFeesInFiat
    property bool showCustomRoutingMode

    readonly property int currentIndex: tabBar.currentIndex

    property string routerError: ""
    property string routerErrorDetails: ""

    signal reCalculateSuggestedRoute()

    implicitHeight: childrenRect.height

    QtObject {
        id: d

        property var customButton

        readonly property int backgroundRectRadius: 13
        readonly property color backgroundRectColor: Theme.palette.indirectColor1
    }

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
            showBetaTag: true
        }
    }

    // not visible in `production` for now, see https://github.com/status-im/status-desktop/issues/16052
    Component {
        id: customButtonComponent
        StatusSwitchTabButton {
            text: qsTr("Custom")
        }
    }

    onShowCustomRoutingModeChanged: {
        if (root.showCustomRoutingMode) {
            if (!!d.customButton)
                d.customButton.destroy()
            d.customButton = customButtonComponent.createObject(tabBar)
            tabBar.addItem(d.customButton)
        } else if (!!d.customButton) {
            d.customButton.destroy()
        }
    }

    StackLayout {
        id: stackLayout
        anchors.top: !root.isCollectiblesTransfer ? tabBar.bottom: parent.top
        anchors.topMargin: !root.isCollectiblesTransfer ? Theme.bigPadding: 0
        height: currentIndex == 0 ? networksSimpleRoutingPage.height + networksSimpleRoutingPage.anchors.margins + Theme.bigPadding:
                                   advancedNetworkRoutingPage.height + advancedNetworkRoutingPage.anchors.margins + Theme.bigPadding
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
                anchors.margins: Theme.padding
                isBridgeTx: root.isBridgeTx
                isCollectiblesTransfer: root.isCollectiblesTransfer
                minReceiveCryptoDecimals: root.minReceiveCryptoDecimals
                isLoading: root.isLoading
                store: root.store
                networksStore: root.networksStore
                errorMode: root.errorMode
                errorType: root.errorType
                fromNetworksList: root.fromNetworksList
                suggestedToNetworksList: root.suggestedToNetworksList
                // Collectibles don't have a symbol
                selectedSymbol: !!root.selectedAsset && !!root.selectedAsset.symbol ? root.selectedAsset.symbol: ""
                weiToEth: function(wei) {
                    if(!!selectedAsset && root.selectedAsset !== undefined)
                        return parseFloat(store.getWei2Eth(wei, root.selectedAsset.decimals))
                }
                formatCurrencyAmount: root.currencyStore.formatCurrencyAmount
                reCalculateSuggestedRoute: function() {
                    root.reCalculateSuggestedRoute()
                }

                showBetaTag: !root.isLoading && !!root.bestRoutes && root.bestRoutes.count > 1
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
                anchors.margins: Theme.padding
                store: root.store
                customMode: tabBar.currentIndex === 2
                selectedRecipient: root.selectedRecipient
                ensAddressOrEmpty: root.ensAddressOrEmpty
                amountToSend: root.amountToSend
                minSendCryptoDecimals: root.minSendCryptoDecimals
                minReceiveCryptoDecimals: root.minReceiveCryptoDecimals
                selectedAsset: root.selectedAsset
                onReCalculateSuggestedRoute: root.reCalculateSuggestedRoute()
                fromNetworksList: root.fromNetworksList
                toNetworksList: root.toNetworksList
                isLoading: root.isLoading
                interactive: root.interactive
                isBridgeTx: root.isBridgeTx
                errorType: root.errorType
                weiToEth: function(wei) {
                    if(!!selectedAsset && (selectedAsset.type === Constants.TokenType.Native || selectedAsset.type === Constants.TokenType.ERC20))
                        return parseFloat(store.getWei2Eth(wei, selectedAsset.decimals))
                    return 0
                }
            }
        }
    }

    FeesView {
        id: fees
        width: parent.width
        anchors.top: stackLayout.bottom
        anchors.topMargin: Theme.bigPadding
        visible: root.advancedOrCustomMode

        selectedAsset: root.selectedAsset
        isLoading: root.isLoading
        bestRoutes: root.bestRoutes
        store: root.store
        gasFiatAmount: root.totalFeesInFiat
        errorType: root.errorType
    }

    ErrorTag {
        id: errorTag

        property bool showDetails: false

        anchors.top: fees.visible? fees.bottom : stackLayout.bottom
        anchors.topMargin: Theme.bigPadding
        anchors.horizontalCenter: parent.horizontalCenter
        visible: root.routerError !== ""
        text: root.routerError
        buttonText: showDetails? qsTr("hide details") : qsTr("show details")
        buttonVisible: root.routerErrorDetails !== ""
        onButtonClicked: {
            showDetails = !showDetails
        }
    }

    Rectangle {
        width: parent.width
        implicitHeight: childrenRect.height + 2*Theme.padding
        anchors.top: errorTag.bottom
        anchors.topMargin: Theme.padding
        visible: errorTag.visible && errorTag.showDetails
        color: Theme.palette.dangerColor3
        radius: 8
        border.width: 1
        border.color: Theme.palette.dangerColor2

        StatusBaseText {
            anchors.centerIn: parent
            width: parent.width - 2*Theme.bigPadding
            text: root.routerErrorDetails
            font.pixelSize: Theme.tertiaryTextFontSize
            wrapMode: Text.WrapAnywhere
        }
    }
}
