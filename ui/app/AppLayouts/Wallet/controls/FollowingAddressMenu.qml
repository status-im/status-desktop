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

StatusMenu {
    id: root

    property string name
    property string address
    property string ensName
    property var tags
    property var activeNetworks

    readonly property int maxHeight: 341
    height: implicitHeight > maxHeight ? maxHeight : implicitHeight

    QtObject {
        id: d
        readonly property string visibleAddress: !!root.ensName ? root.ensName : root.address
    }

    function openMenu(parent, x, y, model) {
        root.name = model.name;
        root.address = model.address;
        root.ensName = model.ensName;
        root.tags = model.tags;
        popup(parent, x, y);
    }

    onClosed: {
        root.name = "";
        root.address = "";
        root.ensName = ""
        root.tags = []
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
            Global.openShowQRPopup({
                                       showSingleAccount: true,
                                       showForSavedAddress: false,
                                       switchingAccounsEnabled: false,
                                       hasFloatingButtons: false,
                                       name: root.name,
                                       address: root.address
                                   })
        }
    }

    StatusAction {
        text: qsTr("View activity")
        objectName: "viewActivityFollowingAddressAction"
        assetSettings.name: "wallet"
        onTriggered: {
            Global.changeAppSectionBySectionType(Constants.appSection.wallet,
                                                 WalletLayout.LeftPanelSelection.AllAddresses,
                                                 WalletLayout.RightPanelSelection.Activity,
                                                 {savedAddress: root.address})
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
            var savedAddr = WalletStores.RootStore.getSavedAddress(root.address)
            var isSaved = savedAddr && savedAddr.address !== ""
            return isSaved ? qsTr("Already in saved addresses") : qsTr("Add to saved addresses")
        }
        assetSettings.name: {
            var savedAddr = WalletStores.RootStore.getSavedAddress(root.address)
            var isSaved = savedAddr && savedAddr.address !== ""
            return isSaved ? "star-icon" : "star-icon-outline"
        }
        objectName: "addToSavedAddressesAction"
        enabled: {
            var savedAddr = WalletStores.RootStore.getSavedAddress(root.address)
            return !(savedAddr && savedAddr.address !== "")
        }
        onTriggered: {
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
    }
}

