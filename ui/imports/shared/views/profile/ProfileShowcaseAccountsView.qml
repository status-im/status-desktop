import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

import StatusQ.Controls 0.1
import StatusQ.Core 0.1
import StatusQ.Core.Theme 0.1
import StatusQ.Core.Utils 0.1 as StatusQUtils
import StatusQ.Popups 0.1

import shared.controls.delegates 1.0
import utils 1.0

import AppLayouts.Wallet.stores 1.0 as WalletStores

Item {
    id: root

    required property string mainDisplayName
    required property bool sendToAccountEnabled
    required property var accountsModel
    required property WalletStores.RootStore walletStore

    property alias cellWidth: accountsView.cellWidth
    property alias cellHeight: accountsView.cellHeight

    signal copyToClipboard(string text)

    StatusBaseText {
        anchors.centerIn: parent
        visible: (accountsView.count === 0)
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter
        color: Theme.palette.directColor1
        text: qsTr("%1 has not shared any accounts").arg(root.mainDisplayName)
    }

    StatusGridView {
        id: accountsView

        anchors.fill: parent
        topMargin: Style.current.bigPadding
        bottomMargin: Style.current.bigPadding
        leftMargin: Style.current.bigPadding

        visible: count
        ScrollBar.vertical: StatusScrollBar { anchors.right: parent.right; anchors.rightMargin: width / 2 }
        model: root.accountsModel
        delegate: InfoCard {
            id: accountInfoDelegate
            implicitWidth: GridView.view.cellWidth - Style.current.padding
            implicitHeight: GridView.view.cellHeight - Style.current.padding
            title: model.name
            subTitle: StatusQUtils.Utils.elideText(model.address, 6, 4).replace("0x", "0×")
            asset.color: Utils.getColorForId(model.colorId)
            asset.emoji: model.emoji ?? ""
            asset.name: asset.emoji || "filled-account"
            asset.isLetterIdenticon: asset.emoji
            asset.letterSize: 14
            asset.bgColor: Theme.palette.primaryColor3
            asset.isImage: asset.emoji
            rightSideButtons: RowLayout {
                StatusFlatRoundButton {
                    Layout.preferredWidth: 32
                    Layout.preferredHeight: 32
                    visible: accountInfoDelegate.hovered && model.canReceiveFromMyAccounts
                    type: StatusFlatRoundButton.Type.Secondary
                    icon.name: "send"
                    icon.color: !hovered ? Theme.palette.baseColor1 : Theme.palette.directColor1
                    enabled: root.sendToAccountEnabled
                    onClicked: {
                        Global.openSendModal(model.address)
                    }
                    onHoveredChanged: accountInfoDelegate.highlight = hovered
                }
                StatusFlatRoundButton {
                    id: moreButton
                    Layout.preferredWidth: 32
                    Layout.preferredHeight: 32
                    visible: accountInfoDelegate.hovered
                    type: StatusFlatRoundButton.Type.Secondary
                    icon.name: "more"
                    icon.color: (hovered || d.menuOpened) ? Theme.palette.directColor1 : Theme.palette.baseColor1
                    highlighted: d.menuOpened
                    onClicked: {
                        Global.openMenu(delegatesActionsMenu, this, { 
                            x: moreButton.x, 
                            y : moreButton.y, 
                            accountAddress: model.address,
                            accountName: model.name,
                            accountColorId: model.colorId
                        });
                    }
                    onHoveredChanged: accountInfoDelegate.highlight = hovered
                }
            }
            onClicked: {
                if (mouse.button === Qt.RightButton) {
                    Global.openMenu(delegatesActionsMenu, this, { 
                        accountAddress: model.address,
                        accountName: model.name,
                        accountColorId: model.colorId
                    });
                }
            }
        }
    }

    Component {
        id: delegatesActionsMenu
        StatusMenu {
            id: contextMenu
            property string accountAddress: ""
            property string accountName: ""
            property string accountColorId: ""

            onOpened: { d.menuOpened = true; }
            onClosed: { d.menuOpened = false; }

            StatusSuccessAction {
                id: copyAddressAction
                successText: qsTr("Copied")
                text: qsTr("Copy adress")
                icon.name: "copy"
                onTriggered: {
                    root.copyToClipboard(accountAddress)
                }
            }

            StatusAction {
                text: qsTr("Show address QR")
                icon.name: "qr"
                onTriggered: {
                    Global.openShowQRPopup({
                        showSingleAccount: true,
                        switchingAccounsEnabled: false,
                        hasFloatingButtons: false,
                        name: contextMenu.accountName,
                        address: contextMenu.accountAddress,
                        colorId: contextMenu.accountColorId
                    })
                }
            }

            StatusAction {
                text: qsTr("Save address")
                icon.name: "favourite"
                onTriggered: {
                    Global.openAddEditSavedAddressesPopup({ addAddress: true,  address: contextMenu.accountAddress })
                }
            }

            StatusAction {
                text: qsTr("View on Etherscan")
                icon.name: "link"
                onTriggered: {
                    let link = Utils.getUrlForAddressOnNetwork(Constants.networkShortChainNames.mainnet,
                                            root.walletStore.areTestNetworksEnabled,
                                            root.walletStore.isGoerliEnabled,
                                            contextMenu.accountAddress);
                    Global.openLinkWithConfirmation(link, StatusQUtils.StringUtils.extractDomainFromLink(link));
                }
            }
        }
    }

    QtObject {
        id: d
        property bool menuOpened: false
    }
}
