import QtQuick
import QtQuick.Controls

import utils

import StatusQ
import StatusQ.Controls
import StatusQ.Components
import StatusQ.Core
import StatusQ.Core.Theme
import StatusQ.Core.Utils as StatusQUtils
import StatusQ.Popups

import shared.controls
import shared.popups
import shared.stores as SharedStores

import "../popups"
import "../controls"
import "../stores"
import ".."

import AppLayouts.Wallet.stores as WalletStores

StatusListItem {
    id: root

    property SharedStores.NetworkConnectionStore networkConnectionStore
    property var activeNetworks
    property string name
    property string address
    property string ensName
    property var tags
    property string avatar

    property int usage: FollowingAddressesDelegate.Usage.Delegate
    property bool showButtons: sensor.containsMouse

    property alias sendButton: sendButton
    property alias starButton: starButton

    signal aboutToOpenPopup()
    signal openSendModal(string recipient)

    enum Usage {
        Delegate,
        Item
    }

    implicitWidth: ListView.view ? ListView.view.width : 0

    title: name
    objectName: name || "followingAddressDelegate"
    subTitle: WalletUtils.addressToDisplay(root.address, false, sensor.containsMouse)

    border.color: Theme.palette.baseColor5

    asset {
        width: 40
        height: 40
        name: root.avatar || ""
        color: Theme.palette.primaryColor1
        isLetterIdenticon: !root.avatar
        letterIdenticonBgWithAlpha: true
    }

    statusListItemIcon.hoverEnabled: true

    statusListItemComponentsSlot.spacing: 0

    QtObject {
        id: d

        readonly property string visibleAddress: !!root.ensName ? root.ensName : root.address
        
        property int savedAddressesVersion: 0
        
        readonly property bool isAddressSaved: {
            savedAddressesVersion
            var savedAddr = WalletStores.RootStore.getSavedAddress(root.address)
            return savedAddr && savedAddr.address !== ""
        }
    }
    
    Connections {
        target: WalletStores.RootStore
        
        function onSavedAddressAddedOrUpdated(added, name, address, errorMsg) {
            if (address.toLowerCase() === root.address.toLowerCase()) {
                d.savedAddressesVersion++
            }
        }
        
        function onSavedAddressDeleted(name, address, errorMsg) {
            if (address.toLowerCase() === root.address.toLowerCase()) {
                d.savedAddressesVersion++
            }
        }
    }

    onClicked: {
        if (root.usage === FollowingAddressesDelegate.Usage.Item) {
            return
        }
        Global.openSavedAddressActivityPopup({
                                                 name: root.name,
                                                 address: root.address,
                                                 ens: root.ensName,
                                                 colorId: "",
                                                 avatar: root.avatar,
                                                 isFollowingAddress: true
                                              })
    }

    components: [
        StatusRoundButton {
            id: sendButton
            visible: !!root.name && root.showButtons
            type: StatusRoundButton.Type.Quinary
            radius: 8
            icon.name: "send"
            enabled: root.networkConnectionStore.sendBuyBridgeEnabled
            onClicked: root.openSendModal(root.address)
        },
        StatusRoundButton {
            id: starButton
            visible: !!root.name && (d.isAddressSaved || root.showButtons)
            type: StatusRoundButton.Type.Quinary
            radius: 8
            icon.name: d.isAddressSaved ? "star-icon" : "star-icon-outline"
            enabled: !d.isAddressSaved
            onClicked: {
                var nameToUse = root.ensName || root.address
                if (root.ensName && root.ensName.includes(".")) {
                    nameToUse = root.ensName.split(".")[0]
                }
                
                Global.openAddEditSavedAddressesPopup({
                    addAddress: true,
                    address: root.address,
                    name: nameToUse,
                    ens: root.ensName
                })
            }
        },
        StatusRoundButton {
            objectName: "followingAddressView_Delegate_menuButton_" + root.name
            visible: !!root.name
            enabled: root.showButtons
            type: StatusRoundButton.Type.Quinary
            radius: 8
            icon.name: "more"
            onClicked: {
                menu.openMenu(this, x + width - menu.width - statusListItemComponentsSlot.spacing, y + height + Theme.halfPadding,
                    {
                        name: root.name,
                        address: root.address,
                        ensName: root.ensName,
                        tags: root.tags,
                    }
                );
            }

        }
    ]

    StatusMenu {
        id: menu
        property string name
        property string address
        property string ensName
        property var tags

        readonly property int maxHeight: 341
        height: implicitHeight > maxHeight ? maxHeight : implicitHeight

        function openMenu(parent, x, y, model) {
            menu.name = model.name;
            menu.address = model.address;
            menu.ensName = model.ensName;
            menu.tags = model.tags;
            popup(parent, x, y);
        }
        onClosed: {
            menu.name = "";
            menu.address = "";
            menu.ensName = ""
            menu.tags = []
        }

        StatusSuccessAction {
            id: copyAddressAction
            objectName: "copyFollowingAddressAction"
            successText: qsTr("Address copied")
            text: qsTr("Copy address")
            icon.name: "copy"
            timeout: 1500
            autoDismissMenu: true
            onTriggered: ClipboardUtils.setText(d.visibleAddress)
        }

        StatusAction {
            text: qsTr("Show address QR")
            objectName: "showQrFollowingAddressAction"
            assetSettings.name: "qr"
            onTriggered: {
                if (root.usage === FollowingAddressesDelegate.Usage.Item) {
                    root.aboutToOpenPopup()
                }
                Global.openShowQRPopup({
                                           showSingleAccount: true,
                                           showForSavedAddress: false,
                                           switchingAccounsEnabled: false,
                                           hasFloatingButtons: false,
                                           name: menu.name,
                                           address: menu.address
                                       })
            }
        }

        StatusAction {
            text: qsTr("View activity")
            objectName: "viewActivityFollowingAddressAction"
            assetSettings.name: "wallet"
            onTriggered: {
                if (root.usage === FollowingAddressesDelegate.Usage.Item) {
                    root.aboutToOpenPopup()
                }
                Global.changeAppSectionBySectionType(Constants.appSection.wallet,
                                                     WalletLayout.LeftPanelSelection.AllAddresses,
                                                     WalletLayout.RightPanelSelection.Activity,
                                                     {savedAddress: menu.address})
            }
        }

        StatusMenuSeparator {}

        BlockchainExplorersMenu {
            id: blockchainExplorersMenu
            flatNetworks: root.activeNetworks
            onNetworkClicked: {
                let link = Utils.getUrlForAddressOnNetwork(shortname, isTestnet, d.visibleAddress ? d.visibleAddress : root.ensName);
                Global.openLinkWithConfirmation(link, StatusQUtils.StringUtils.extractDomainFromLink(link));
            }
        }

        StatusMenuSeparator { }

        StatusAction {
            text: {
                var savedAddr = WalletStores.RootStore.getSavedAddress(menu.address)
                var isSaved = savedAddr && savedAddr.address !== ""
                return isSaved ? qsTr("Already in saved addresses") : qsTr("Add to saved addresses")
            }
            assetSettings.name: {
                var savedAddr = WalletStores.RootStore.getSavedAddress(menu.address)
                var isSaved = savedAddr && savedAddr.address !== ""
                return isSaved ? "star-icon" : "star-icon-outline"
            }
            objectName: "addToSavedAddressesAction"
            enabled: {
                var savedAddr = WalletStores.RootStore.getSavedAddress(menu.address)
                return !(savedAddr && savedAddr.address !== "")
            }
            onTriggered: {
                if (root.usage === FollowingAddressesDelegate.Usage.Item) {
                    root.aboutToOpenPopup()
                }
                
                var nameToUse = menu.ensName || menu.address
                if (menu.ensName && menu.ensName.includes(".")) {
                    nameToUse = menu.ensName.split(".")[0]
                }
                
                Global.openAddEditSavedAddressesPopup({
                    addAddress: true,
                    address: menu.address,
                    name: nameToUse,
                    ens: menu.ensName
                })
            }
        }
    }
}
