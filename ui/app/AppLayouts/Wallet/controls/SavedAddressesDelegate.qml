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

StatusListItem {
    id: root

    property SharedStores.NetworkConnectionStore networkConnectionStore
    property var activeNetworks
    property string name
    property string address
    property string ens
    property string colorId

    property int usage: SavedAddressesDelegate.Usage.Delegate
    property bool showButtons: sensor.containsMouse

    property alias sendButton: sendButton

    signal aboutToOpenPopup()
    signal openSendModal(string recipient)

    enum Usage {
        Delegate,
        Item
    }

    implicitWidth: ListView.view ? ListView.view.width : 0

    title: name
    objectName: name
    subTitle: {
        if (ens.length > 0)
            return ens
        else {
            return WalletUtils.addressToDisplay(root.address, false, sensor.containsMouse)
        }
    }

    border.color: Theme.palette.baseColor5

    asset {
        width: 40
        height: 40
        color: Utils.getColorForId(root.colorId)
        isLetterIdenticon: true
        letterIdenticonBgWithAlpha: true
    }

    statusListItemIcon.hoverEnabled: true

    statusListItemComponentsSlot.spacing: 0

    QtObject {
        id: d

        readonly property string visibleAddress: !!root.ens? root.ens : root.address
    }

    onClicked: {
        if (root.usage === SavedAddressesDelegate.Usage.Item) {
            return
        }
        Global.openSavedAddressActivityPopup({
                                                 name: root.name,
                                                 address: root.address,
                                                 ens: root.ens,
                                                 colorId: root.colorId
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
                menu.openMenu(this, x + width - menu.width - statusListItemComponentsSlot.spacing, y + height + Theme.halfPadding,
                    {
                        name: root.name,
                        address: root.address,
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
        property string ens
        property string colorId

        readonly property int maxHeight: 341
        height: implicitHeight > maxHeight ? maxHeight : implicitHeight

        function openMenu(parent, x, y, model) {
            menu.name = model.name;
            menu.address = model.address;
            menu.ens = model.ens;
            menu.colorId = model.colorId;
            popup(parent, x, y);
        }
        onClosed: {
            menu.name = "";
            menu.address = "";
            menu.ens = ""
            menu.colorId = ""
        }

        StatusAction {
            text: qsTr("Edit saved address")
            objectName: "editSavedAddress"
            assetSettings.name: "pencil-outline"
            onTriggered: {
                if (root.usage === SavedAddressesDelegate.Usage.Item) {
                    root.aboutToOpenPopup()
                }
                Global.openAddEditSavedAddressesPopup({
                                                          edit: true,
                                                          address: menu.address,
                                                          name: menu.name,
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
            onTriggered: ClipboardUtils.setText(d.visibleAddress)
        }

        StatusAction {
            text: qsTr("Show address QR")
            objectName: "showQrSavedAddressAction"
            assetSettings.name: "qr"
            onTriggered: {
                if (root.usage === SavedAddressesDelegate.Usage.Item) {
                    root.aboutToOpenPopup()
                }
                Global.openShowQRPopup({
                                           showSingleAccount: true,
                                           showForSavedAddress: true,
                                           switchingAccounsEnabled: false,
                                           hasFloatingButtons: false,
                                           name: menu.name,
                                           address: menu.address,
                                           colorId: menu.colorId
                                       })
            }
        }

        StatusAction {
            text: qsTr("View activity")
            objectName: "viewActivitySavedAddressAction"
            assetSettings.name: "wallet"
            onTriggered: {
                if (root.usage === SavedAddressesDelegate.Usage.Item) {
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
                let link = Utils.getUrlForAddressOnNetwork(shortname, isTestnet, d.visibleAddress ? d.visibleAddress : root.ens);
                Global.openLinkWithConfirmation(link, StatusQUtils.StringUtils.extractDomainFromLink(link));
            }
        }

        StatusMenuSeparator { }

        StatusAction {
            text: qsTr("Remove saved address")
            type: StatusAction.Type.Danger
            assetSettings.name: "delete"
            objectName: "deleteSavedAddress"
            onTriggered: {
                if (root.usage === SavedAddressesDelegate.Usage.Item) {
                    root.aboutToOpenPopup()
                }
                Global.openDeleteSavedAddressesPopup({
                                                         name: menu.name,
                                                         address: menu.address,
                                                         ens: menu.ens,
                                                         colorId: menu.colorId
                                                     })
            }
        }
    }
}
