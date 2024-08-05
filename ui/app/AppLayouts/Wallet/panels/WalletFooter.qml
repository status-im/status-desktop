import QtQuick 2.14
import QtQuick.Controls 2.14
import QtQuick.Layouts 1.13
import QtQml 2.15

import StatusQ 0.1
import StatusQ.Popups 0.1
import StatusQ.Controls 0.1
import StatusQ.Core.Theme 0.1
import StatusQ.Core.Utils 0.1 as SQUtils

import utils 1.0
import shared.controls 1.0
import shared.stores.send 1.0

import "../controls"
import "../popups"

Rectangle {
    id: root

    readonly property alias anyActionAvailable: d.anyActionAvailable

    property var walletStore
    property var networkConnectionStore
    required property TransactionStore transactionStore

    // Community-token related properties:
    required property bool isCommunityOwnershipTransfer
    property string communityName: ""

    signal launchShareAddressModal()
    signal launchSendModal(string fromAddress)
    signal launchBridgeModal()
    signal launchSwapModal()

    color: Theme.palette.statusAppLayout.rightPanelBackgroundColor

    QtObject {
        id: d
        readonly property bool isCollectibleViewed: !!walletStore.currentViewedHoldingID &&
                                                    (walletStore.currentViewedHoldingType === Constants.TokenType.ERC721 ||
                                                    walletStore.currentViewedHoldingType === Constants.TokenType.ERC1155)
        readonly property bool isCollectibleSoulbound: isCollectibleViewed && !!walletStore.currentViewedCollectible && walletStore.currentViewedCollectible.soulbound

        readonly property var collectibleOwnership: isCollectibleViewed && walletStore.currentViewedCollectible ?
                                                        walletStore.currentViewedCollectible.ownership : null

        readonly property string userOwnedAddressForCollectible: !!walletStore.currentViewedHoldingID ? getFirstUserOwnedAddress(collectibleOwnership, root.walletStore.nonWatchAccounts) : ""

        readonly property bool hideCollectibleTransferActions: isCollectibleViewed && !userOwnedAddressForCollectible

        /// Actions available
        readonly property bool anyActionAvailable: sendActionAvailable
                                                    || receiveActionAvailable
                                                    || bridgeActionAvailable
                                                    || buyActionAvailable
                                                    || swapActionAvailable

        readonly property bool sendActionAvailable: !walletStore.overview.isWatchOnlyAccount
                                                    && walletStore.overview.canSend
                                                    && !d.hideCollectibleTransferActions
        
        readonly property bool receiveActionAvailable: !walletStore.showAllAccounts

        readonly property bool bridgeActionAvailable: !walletStore.overview.isWatchOnlyAccount
                                                        && !root.isCommunityOwnershipTransfer
                                                        && walletStore.overview.canSend
                                                        && !root.walletStore.showAllAccounts
                                                        && !d.hideCollectibleTransferActions

        readonly property bool buyActionAvailable: !root.isCommunityOwnershipTransfer && !root.walletStore.showAllAccounts

        readonly property bool swapActionAvailable: Global.featureFlags.swapEnabled && !walletStore.overview.isWatchOnlyAccount && walletStore.overview.canSend && !d.hideCollectibleTransferActions

        function getFirstUserOwnedAddress(ownershipModel, accountsModel) {
            if (!ownershipModel) return ""
            
            for (let i = 0; i < ownershipModel.rowCount(); i++) {
                const accountAddress = SQUtils.ModelUtils.get(ownershipModel, i, "accountAddress")
                if (SQUtils.ModelUtils.contains(accountsModel, "address", accountAddress, Qt.CaseInsensitive))
                    return accountAddress
            }
            return ""
        }
    }

    StatusModalDivider {
        anchors.top: parent.top
        width: parent.width
    }

    RowLayout {
        id: layout
        anchors.centerIn: parent
        height: parent.height
        width: Math.min(root.width, implicitWidth)
        spacing:  Style.current.padding

        StatusFlatButton {
            id: sendButton
            Layout.fillWidth: true
            Layout.maximumWidth: implicitWidth
            objectName: "walletFooterSendButton"
            icon.name: "send"
            text: root.isCommunityOwnershipTransfer ? qsTr("Send Owner token to transfer %1 Community ownership").arg(root.communityName) : qsTr("Send")
            interactive: !d.isCollectibleSoulbound && networkConnectionStore.sendBuyBridgeEnabled
            onClicked: {
                root.transactionStore.setSenderAccount(root.walletStore.selectedAddress)
                root.launchSendModal(d.userOwnedAddressForCollectible)
            }
            tooltip.text: d.isCollectibleSoulbound ? qsTr("Soulbound collectibles cannot be sent to another wallet") : networkConnectionStore.sendBuyBridgeToolTipText
            visible: d.sendActionAvailable
        }

        StatusFlatButton {
            icon.name: "receive"
            text: qsTr("Receive")
            visible: d.receiveActionAvailable
            onClicked: function () {
                root.transactionStore.setReceiverAccount(root.walletStore.selectedAddress)
                launchShareAddressModal()
            }
        }

        StatusFlatButton {
            icon.name: "bridge"
            text: qsTr("Bridge")
            interactive: !d.isCollectibleSoulbound && networkConnectionStore.sendBuyBridgeEnabled
            onClicked: root.launchBridgeModal()
            tooltip.text: d.isCollectibleSoulbound ? qsTr("Soulbound collectibles cannot be bridged to another wallet") :  networkConnectionStore.sendBuyBridgeToolTipText
            visible: d.bridgeActionAvailable
        }

        StatusFlatButton {
            id: buySellBtn

            visible: d.buyActionAvailable
            icon.name: "token"
            text: qsTr("Buy")
            onClicked: Global.openBuyCryptoModalRequested()
        }

        StatusFlatButton {
            id: swap

            interactive: !d.isCollectibleViewed && networkConnectionStore.sendBuyBridgeEnabled
            visible: d.swapActionAvailable
            tooltip.text: d.isCollectibleViewed ? qsTr("Collectibles cannot be swapped") : networkConnectionStore.sendBuyBridgeToolTipText
            icon.name: "swap"
            text: qsTr("Swap")
            onClicked: root.launchSwapModal()
        }
    }
}


