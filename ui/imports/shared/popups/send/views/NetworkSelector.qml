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
    property bool advancedMode: true
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

    property string routerError: ""
    property string routerErrorDetails: ""

    signal reCalculateSuggestedRoute()

    implicitHeight: childrenRect.height

    QtObject {
        id: d

        readonly property int backgroundRectRadius: 13
        readonly property color backgroundRectColor: Theme.palette.indirectColor1
    }

    StackLayout {
        id: stackLayout
        anchors.top: parent.top
        anchors.topMargin: !root.isCollectiblesTransfer ? Theme.bigPadding: 0
        height: advancedNetworkRoutingPage.height + advancedNetworkRoutingPage.anchors.margins + Theme.bigPadding
        width: parent.width

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
                fnRawToDecimal: function(rawValue) {
                    if(!!selectedAsset && (selectedAsset.type === Constants.TokenType.Native || selectedAsset.type === Constants.TokenType.ERC20))
                        return parseFloat(store.getWei2Eth(rawValue, selectedAsset.decimals))
                    return 0
                }
            }
        }
    }

    FeesView {
        id: fees
        width: parent.width
        height: visible ? implicitHeight : 0
        anchors.top: stackLayout.bottom
        anchors.topMargin: Theme.bigPadding
        visible: root.advancedMode

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
        height: visible ? implicitHeight : 0
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
        implicitHeight: visible ? errorText.height + 2*Theme.padding: 0
        anchors.top: errorTag.bottom
        anchors.topMargin: Theme.padding
        visible: errorTag.visible && errorTag.showDetails
        color: Theme.palette.dangerColor3
        radius: 8
        border.width: 1
        border.color: Theme.palette.dangerColor2

        StatusBaseText {
            id: errorText
            anchors.centerIn: parent
            width: parent.width - 2*Theme.bigPadding
            text: root.routerErrorDetails
            font.pixelSize: Theme.tertiaryTextFontSize
            wrapMode: Text.WrapAnywhere
        }
    }
}
