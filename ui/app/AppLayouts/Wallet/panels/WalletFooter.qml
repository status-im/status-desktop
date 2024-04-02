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

    color: Theme.palette.statusAppLayout.rightPanelBackgroundColor

    QtObject {
        id: d
        readonly property int collectibleTransferableTrait: !!walletStore.currentViewedCollectible && sendButton.visible ? walletStore.findCollectibleTrait(walletStore.currentViewedCollectible, Constants.collectibleTrait.transferable, Constants.collectibleTrait.transferableNoValue) : -1
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
            id: sendButton
            objectName: "walletFooterSendButton"
            icon.name: "send"
            text: root.isCommunityOwnershipTransfer ? qsTr("Send Owner token to transfer %1 Community ownership").arg(root.communityName) : qsTr("Send")
            interactive: d.collectibleTransferableTrait != 1 && networkConnectionStore.sendBuyBridgeEnabled
            onClicked: root.launchSendModal()
            tooltip.text: d.collectibleTransferableTrait == 1 ? qsTr("Soulbound collectibles cannot be sent to another wallet") : networkConnectionStore.sendBuyBridgeToolTipText
            visible: !walletStore.overview.isWatchOnlyAccount && walletStore.overview.canSend
        }

        StatusFlatButton {
            icon.name: "receive"
            text: qsTr("Receive")
            onClicked: function () {
                launchShareAddressModal()
            }
        }

        StatusFlatButton {
            icon.name: "bridge"
            text: qsTr("Bridge")
            interactive: networkConnectionStore.sendBuyBridgeEnabled
            onClicked: root.launchBridgeModal()
            tooltip.text: networkConnectionStore.sendBuyBridgeToolTipText
            visible: !walletStore.overview.isWatchOnlyAccount && !root.isCommunityOwnershipTransfer && walletStore.overview.canSend
        }

        StatusFlatButton {
            id: buySellBtn

            visible: !root.isCommunityOwnershipTransfer
            icon.name: "token"
            text: qsTr("Buy")
            onClicked: function () {
                Global.openPopup(buySellModal);
            }
        }
    }

    Component {
        id: buySellModal
        CryptoServicesModal {}
    }
}


