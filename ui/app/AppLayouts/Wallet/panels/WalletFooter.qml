import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

import StatusQ.Popups 0.1
import StatusQ.Controls 0.1
import StatusQ.Core.Theme 0.1
import StatusQ.Core.Utils 0.1 as SQUtils

import utils 1.0
import shared.stores.send 1.0

Rectangle {
    id: root

    property var walletStore
    property var networkConnectionStore
    required property TransactionStore transactionStore

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
            onClicked: {
                root.transactionStore.setSenderAccount(root.walletStore.selectedAddress ||
                                                       SQUtils.ModelUtils.get(root.walletStore.nonWatchAccounts, 0, "address"))
                root.launchSendModal()
            }
            tooltip.text: d.isCollectibleSoulbound ? qsTr("Soulbound collectibles cannot be sent to another wallet") : networkConnectionStore.sendBuyBridgeToolTipText
            visible: walletStore.overview.canSend
        }

        StatusFlatButton {
            icon.name: "receive"
            text: qsTr("Receive")
            onClicked: function () {
                root.transactionStore.setSenderAccount(root.walletStore.selectedAddress ||
                                                       SQUtils.ModelUtils.get(root.walletStore.nonWatchAccounts, 0, "address"))
                root.launchShareAddressModal()
            }
        }

        StatusFlatButton {
            icon.name: "bridge"
            text: qsTr("Bridge")
            interactive: !d.isCollectibleSoulbound && networkConnectionStore.sendBuyBridgeEnabled
            onClicked: root.launchBridgeModal()
            tooltip.text: d.isCollectibleSoulbound ? qsTr("Soulbound collectibles cannot be bridged to another wallet") :  networkConnectionStore.sendBuyBridgeToolTipText
            visible: !root.isCommunityOwnershipTransfer && walletStore.overview.canSend
        }

        StatusFlatButton {
            visible: !root.isCommunityOwnershipTransfer
            icon.name: "token"
            text: qsTr("Buy")
            onClicked: Global.openBuyCryptoModalRequested()
        }

        StatusFlatButton {
            interactive: !d.isCollectibleViewed && networkConnectionStore.sendBuyBridgeEnabled
            visible: Global.featureFlags.swapEnabled
            tooltip.text: d.isCollectibleViewed ? qsTr("Collectibles cannot be swapped") : networkConnectionStore.sendBuyBridgeToolTipText
            icon.name: "swap"
            text: qsTr("Swap")
            onClicked: root.launchSwapModal()
        }
    }
}
