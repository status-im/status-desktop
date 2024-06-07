import QtQuick 2.14
import QtQuick.Controls 2.14
import QtQuick.Layouts 1.13

import StatusQ.Popups 0.1
import StatusQ.Controls 0.1
import StatusQ.Core.Theme 0.1

import utils 1.0
import shared.controls 1.0

import "../controls"
import "../popups"

Rectangle {
    id: root

    property var walletStore
    property var networkConnectionStore

    // Community-token related properties:
    required property bool isCommunityOwnershipTransfer
    property string communityName: ""

    signal launchShareAddressModal()
    signal launchSendModal()
    signal launchBridgeModal()
    signal launchSwapModal()

    color: Theme.palette.statusAppLayout.rightPanelBackgroundColor

    QtObject {
        id: d
        readonly property bool isCollectibleViewed: !!walletStore.currentViewedHoldingID &&
                                                    (walletStore.currentViewedHoldingType === Constants.TokenType.ERC721 ||
                                                    walletStore.currentViewedHoldingType === Constants.TokenType.ERC1155)
        readonly property bool isCollectibleSoulbound: isCollectibleViewed && !!walletStore.currentViewedCollectible && walletStore.currentViewedCollectible.soulbound
    }

    StatusModalDivider {
        anchors.top: parent.top
        width: parent.width
    }

    RowLayout {
        anchors.centerIn: parent
        height: parent.height
        spacing:  Style.current.padding

        StatusFlatButton {
            objectName: "walletFooterSendButton"
            icon.name: "send"
            text: root.isCommunityOwnershipTransfer ? qsTr("Send Owner token to transfer %1 Community ownership").arg(root.communityName) : qsTr("Send")
            interactive: !d.isCollectibleSoulbound && networkConnectionStore.sendBuyBridgeEnabled
            onClicked: root.launchSendModal()
            tooltip.text: d.isCollectibleSoulbound ? qsTr("Soulbound collectibles cannot be sent to another wallet") : networkConnectionStore.sendBuyBridgeToolTipText
            visible: !walletStore.overview.isWatchOnlyAccount && walletStore.overview.canSend && !root.walletStore.showAllAccounts
        }

        StatusFlatButton {
            icon.name: "receive"
            text: qsTr("Receive")
            visible: !root.walletStore.showAllAccounts
            onClicked: function () {
                launchShareAddressModal()
            }
        }

        StatusFlatButton {
            icon.name: "bridge"
            text: qsTr("Bridge")
            interactive: !d.isCollectibleSoulbound && networkConnectionStore.sendBuyBridgeEnabled
            onClicked: root.launchBridgeModal()
            tooltip.text: d.isCollectibleSoulbound ? qsTr("Soulbound collectibles cannot be bridged to another wallet") :  networkConnectionStore.sendBuyBridgeToolTipText
            visible: !walletStore.overview.isWatchOnlyAccount && !root.isCommunityOwnershipTransfer && walletStore.overview.canSend && !root.walletStore.showAllAccounts
        }

        StatusFlatButton {
            id: buySellBtn

            visible: !root.isCommunityOwnershipTransfer && !root.walletStore.showAllAccounts
            icon.name: "token"
            text: qsTr("Buy")
            onClicked: Global.openBuyCryptoModalRequested()
        }        

        StatusFlatButton {
            id: swap

            interactive: !d.isCollectibleSoulbound && networkConnectionStore.sendBuyBridgeEnabled
            visible: Global.featureFlags.swapEnabled && !walletStore.overview.isWatchOnlyAccount
            tooltip.text: d.isCollectibleSoulbound ? qsTr("Soulbound collectibles cannot be swapped") :  networkConnectionStore.sendBuyBridgeToolTipText
            icon.name: "swap"
            text: qsTr("Swap")
            onClicked: root.launchSwapModal()
        }
    }
}


