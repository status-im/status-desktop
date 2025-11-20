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

StatusMenu {
    id: root

    property var rootStore  // Injected from parent, not singleton
    property string name
    property string address
    property string ensName
    property var tags
    
    // Model providing active networks
    // Expected roles: chainId (int), chainName (string), iconUrl (string), layer (int)
    property var activeNetworksModel

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
        flatNetworks: root.activeNetworksModel
        onNetworkClicked: (shortname, isTestnet) => {
            let link = Utils.getUrlForAddressOnNetwork(shortname, isTestnet, d.visibleAddress ? d.visibleAddress : root.ensName);
            Global.openLinkWithConfirmation(link, StatusQUtils.StringUtils.extractDomainFromLink(link));
        }
    }

    StatusMenuSeparator { }

    StatusAction {
        readonly property var savedAddr: root.rootStore ? root.rootStore.getSavedAddress(root.address) : null
        readonly property bool isSaved: savedAddr && savedAddr.address !== ""
        
        text: isSaved ? qsTr("Already in saved addresses") : qsTr("Add to saved addresses")
        assetSettings.name: isSaved ? "star-icon" : "star-icon-outline"
        objectName: "addToSavedAddressesAction"
        enabled: !isSaved
        onTriggered: {
            let nameToUse = root.ensName || root.address
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

