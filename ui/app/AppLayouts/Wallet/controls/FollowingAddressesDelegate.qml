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

    signal openSendModal(string recipient)
    signal menuRequested(var menuModel)

    enum Usage {
        Delegate,
        Item
    }

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
                root.menuRequested({
                    name: root.name,
                    address: root.address,
                    ensName: root.ensName,
                    tags: root.tags,
                })
            }

        }
    ]
}
