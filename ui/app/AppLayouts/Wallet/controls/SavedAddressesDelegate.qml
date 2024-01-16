import QtQuick 2.13
import QtQuick.Controls 2.13

import utils 1.0

import StatusQ.Controls 0.1
import StatusQ.Components 0.1
import StatusQ.Core 0.1
import StatusQ.Core.Theme 0.1
import StatusQ.Popups 0.1
import shared.controls 1.0

import "../popups"
import "../controls"
import "../stores"
import ".."

StatusListItem {
    id: root

    property var store
    property var contactsStore
    property string name
    property string address
    property string ens
    property string colorId
    property string chainShortNames
    property bool areTestNetworksEnabled: false
    property bool isSepoliaEnabled: false

    signal openSendModal(string recipient)

    implicitWidth: ListView.view ? ListView.view.width : 0

    title: name
    objectName: name
    subTitle: {
        if (ens.length > 0)
            return ens
        else {
            return sensor.containsMouse ? WalletUtils.colorizedChainPrefix(root.chainShortNames) +
                                          Utils.richColorText(root.address, Theme.palette.directColor1)
                                        : root.chainShortNames + root.address
        }
    }

    border.color: Theme.palette.baseColor5

    asset {
        width: 40
        height: 40
        color: Utils.getColorForId(root.colorId)
        charactersLen: {
            let parts = root.name.split(" ")
            if (parts.length > 1) {
                return 2
            }
            return 1
        }
        isLetterIdenticon: true
        useAcronymForLetterIdenticon: true
    }

    statusListItemIcon.hoverEnabled: true

    statusListItemComponentsSlot.spacing: 0
    property bool showButtons: sensor.containsMouse

    QtObject {
        id: d

        readonly property string visibleAddress: !!root.ens? root.ens : root.address
        readonly property var preferredSharedNetworkNamesArray: root.chainShortNames.split(":").filter(Boolean)
    }

    components: [
        StatusRoundButton {
            visible: !!root.name && root.showButtons
            type: StatusRoundButton.Type.Quinary
            radius: 8
            icon.name: "send"
            onClicked: root.openSendModal(d.visibleAddress)
        },
        StatusRoundButton {
            objectName: "savedAddressView_Delegate_menuButton_" + root.name
            visible: !!root.name
            enabled: root.showButtons
            type: StatusRoundButton.Type.Quinary
            radius: 8
            icon.name: "more"
            onClicked: {
                menu.openMenu(this, x + width - menu.width - statusListItemComponentsSlot.spacing, y + height + Style.current.halfPadding,
                    {
                        name: root.name,
                        address: root.address,
                        chainShortNames: root.chainShortNames,
                        ens: root.ens,
                        colorId: root.colorId,
                    }
                );
            }

        }
    ]

    StatusMenu {
        id: menu
        property string name
        property string address
        property string chainShortNames
        property string ens
        property string colorId

        readonly property int maxHeight: 341
        height: implicitHeight > maxHeight ? maxHeight : implicitHeight
        contentWidth: 216

        function openMenu(parent, x, y, model) {
            menu.name = model.name;
            menu.address = model.address;
            menu.chainShortNames = model.chainShortNames;
            menu.ens = model.ens;
            menu.colorId = model.colorId;
            popup(parent, x, y);
        }
        onClosed: {
            menu.name = "";
            menu.address = "";
            menu.chainShortNames = ""
            menu.ens = ""
            menu.colorId = ""
        }

        StatusAction {
            text: qsTr("Edit saved address")
            objectName: "editSavedAddress"
            assetSettings.name: "pencil-outline"
            onTriggered: {
                Global.openAddEditSavedAddressesPopup({
                                                          edit: true,
                                                          address: menu.address,
                                                          name: menu.name,
                                                          chainShortNames: menu.chainShortNames,
                                                          ens: menu.ens,
                                                          colorId: menu.colorId
                                                      })
            }
        }

        StatusSuccessAction {
            id: copyAddressAction
            objectName: "copySavedAddressAction"
            successText: qsTr("Address copied")
            text: qsTr("Copy address")
            icon.name: "copy"
            timeout: 1500
            autoDismissMenu: true
            onTriggered: {
                store.copyToClipboard(d.visibleAddress)
            }
        }

        StatusAction {
            text: qsTr("Show address QR")
            objectName: "showQrSavedAddressAction"
            assetSettings.name: "qr"
            onTriggered: {
                Global.openShowQRPopup({
                                           showSingleAccount: true,
                                           showForSavedAddress: true,
                                           switchingAccounsEnabled: false,
                                           changingPreferredChainsEnabled: true,
                                           hasFloatingButtons: true,
                                           name: menu.name,
                                           address: menu.address,
                                           colorId: menu.colorId,
                                           preferredSharingChainIds: RootStore.getNetworkIds(menu.chainShortNames)
                                       })
            }
        }

        StatusAction {
            text: qsTr("View activity")
            objectName: "viewActivitySavedAddressAction"
            assetSettings.name: "wallet"
            onTriggered: {
                Global.changeAppSectionBySectionType(Constants.appSection.wallet,
                                                     WalletLayout.LeftPanelSelection.AllAddresses,
                                                     WalletLayout.RightPanelSelection.Activity,
                                                     {savedAddress: menu.address})
            }
        }

        StatusMenuSeparator {
            visible: d.preferredSharedNetworkNamesArray.length > 0
        }

        StatusAction {
            text: Utils.getActionNameForDisplayingAddressOnNetwork(Constants.networkShortChainNames.mainnet)
            enabled: d.preferredSharedNetworkNamesArray.includes(Constants.networkShortChainNames.mainnet)
            icon.name: "link"
            onTriggered: {
                let link = Utils.getUrlForAddressOnNetwork(Constants.networkShortChainNames.mainnet, root.areTestNetworksEnabled, root.isSepoliaEnabled, d.visibleAddress ? d.visibleAddress : root.ens)
                Global.openLink(link)
            }
        }

        StatusAction {
            text: Utils.getActionNameForDisplayingAddressOnNetwork(Constants.networkShortChainNames.arbiscan)
            enabled: d.preferredSharedNetworkNamesArray.includes(Constants.networkShortChainNames.arbiscan)
            icon.name: "link"
            onTriggered: {
                let link = Utils.getUrlForAddressOnNetwork(Constants.networkShortChainNames.arbiscan, root.areTestNetworksEnabled, root.isSepoliaEnabled, d.visibleAddress ? d.visibleAddress : root.ens)
                Global.openLink(link)
            }
        }

        StatusAction {
            text: Utils.getActionNameForDisplayingAddressOnNetwork(Constants.networkShortChainNames.optimism)
            enabled: d.preferredSharedNetworkNamesArray.includes(Constants.networkShortChainNames.optimism)
            icon.name: "link"
            onTriggered: {
                let link = Utils.getUrlForAddressOnNetwork(Constants.networkShortChainNames.optimism, root.areTestNetworksEnabled, root.isSepoliaEnabled, d.visibleAddress ? d.visibleAddress : root.ens)
                Global.openLink(link)
            }
        }

        StatusMenuSeparator { }

        StatusAction {
            text: qsTr("Remove saved address")
            type: StatusAction.Type.Danger
            assetSettings.name: "delete"
            objectName: "deleteSavedAddress"
            onTriggered: {
                Global.openDeleteSavedAddressesPopup({
                                                         name: menu.name,
                                                         address: menu.address,
                                                         ens: menu.ens,
                                                         colorId: menu.colorId,
                                                         chainShortNames: menu.chainShortNames
                                                     })
            }
        }
    }
}
