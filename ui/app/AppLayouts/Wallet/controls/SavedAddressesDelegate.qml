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
    property bool favourite: false
    property bool areTestNetworksEnabled: false
    property bool isSepoliaEnabled: false
    property var saveAddress: function (name, address, favourite, chainShortNames, ens) {}

    signal openSendModal(string recipient)

    implicitWidth: ListView.view ? ListView.view.width : 0

    title: name
    objectName: name
    subTitle: {
        if (ens.length > 0)
            return ens
        else
            return WalletUtils.colorizedChainPrefix(chainShortNames) + address
    }
    border.color: Theme.palette.baseColor5
    asset.name: d.favouriteEnabled ? (root.favourite ? "star-icon" : "favourite") : ""
    asset.color: root.favourite ? Theme.palette.pinColor1 : (showButtons ? Theme.palette.directColor1 : Theme.palette.baseColor1) // star icon color default
    asset.hoverColor: root.favourite ? "transparent": Theme.palette.directColor1 // star icon color on hover
    asset.bgColor: statusListItemIcon.hovered ? Theme.palette.primaryColor3 : "transparent" // icon outer background color
    asset.bgRadius: 8

    statusListItemIcon.hoverEnabled: true

    onIconClicked: {
        root.saveAddress(root.name, root.address, !root.favourite, root.chainShortNames, root.ens)
    }

    statusListItemSubTitle.font.pixelSize: 13
    statusListItemSubTitle.customColor: !enabled ? Theme.palette.baseColor1 : Theme.palette.directColor1
    statusListItemComponentsSlot.spacing: 0
    property bool showButtons: sensor.containsMouse

    QtObject {
        id: d

        readonly property string visibleAddress: root.address == Constants.zeroAddress ? root.ens : root.address
        readonly property bool favouriteEnabled: false // Disabling favourite functionality until good times
    }

    components: [
        StatusRoundButton {
            icon.color: root.showButtons ? Theme.palette.directColor1 : Theme.palette.baseColor1
            type: StatusRoundButton.Type.Quinary
            radius: 8
            icon.name: "send"
            onClicked: openSendModal(d.visibleAddress)
        },
        StatusRoundButton {
            objectName: "savedAddressView_Delegate_menuButton_" + root.name
            visible: !!root.name
            icon.color: root.showButtons ? Theme.palette.directColor1 : Theme.palette.baseColor1
            type: StatusRoundButton.Type.Quinary
            radius: 8
            icon.name: "more"
            onClicked: {
                editDeleteMenu.openMenu(this, x - editDeleteMenu.width - statusListItemComponentsSlot.spacing, y + height + Style.current.halfPadding,
                    {
                        name: root.name,
                        address: root.address,
                        favourite: root.favourite,
                        chainShortNames: root.chainShortNames,
                        ens: root.ens,
                        colorId: root.colorId,
                    }
                );
            }

        },
        StatusRoundButton {
            visible: !root.name
            icon.color: root.showButtons ? Theme.palette.directColor1 : Theme.palette.baseColor1
            type: StatusRoundButton.Type.Tertiary
            icon.name: "add"
            onClicked: {
                Global.openAddEditSavedAddressesPopup({
                                                          addAddress: true,
                                                          address: d.visibleAddress,
                                                          ens: root.ens
                                                      })
            }
        }
    ]

    StatusMenu {
        id: editDeleteMenu
        property string contactName
        property string contactAddress
        property bool storeFavourite
        property string contactChainShortNames
        property string contactEns
        property string colorId

        readonly property int maxHeight: 341
        height: implicitHeight > maxHeight ? maxHeight : implicitHeight
        contentWidth: 216

        function openMenu(parent, x, y, model) {
            contactName = model.name;
            contactAddress = model.address;
            storeFavourite = model.favourite;
            contactChainShortNames = model.chainShortNames;
            contactEns = model.ens;
            colorId = model.colorId;
            popup(parent, x, y);
        }
        onClosed: {
            contactName = "";
            contactAddress = "";
            storeFavourite = false;
            contactChainShortNames = ""
            contactEns = ""
        }
        StatusAction {
            text: qsTr("Edit")
            objectName: "editroot"
            assetSettings.name: "pencil-outline"
            onTriggered: {
                Global.openAddEditSavedAddressesPopup({
                                                          edit: true,
                                                          address: editDeleteMenu.contactAddress,
                                                          name: editDeleteMenu.contactName,
                                                          favourite: editDeleteMenu.storeFavourite,
                                                          chainShortNames: editDeleteMenu.contactChainShortNames,
                                                          ens: editDeleteMenu.contactEns,
                                                          colorId: editDeleteMenu.colorId
                                                      })
            }
        }
        StatusAction {
            text: qsTr("Copy")
            objectName: "copySavedAddressAction"
            assetSettings.name: "copy"
            onTriggered: {
                if (d.visibleAddress)
                    store.copyToClipboard(d.visibleAddress)
                else
                    store.copyToClipboard(root.ens)
            }
        }
        StatusMenuSeparator { }

        StatusAction {
            text: qsTr("View on Etherscan")
            objectName: "viewOnEtherscanAction"
            assetSettings.name: "external"
            onTriggered: {
                var baseUrl = Constants.networkExplorerLinks.etherscan
                if (root.areTestNetworksEnabled) {
                    if (root.isSepoliaEnabled) {
                        baseUrl = Constants.networkExplorerLinks.sepoliaEtherscan
                    } else {
                        baseUrl = Constants.networkExplorerLinks.goerliEtherscan
                    }
                }
                Global.openLink("%1/%2/%3".arg(baseUrl).arg(Constants.networkExplorerLinks.addressPath).arg(d.visibleAddress ? d.visibleAddress : root.ens))
            }
        }

        StatusAction {
            text: qsTr("View on Arbiscan")
            objectName: "viewOnArbiscanAction"
            assetSettings.name: "external"
            onTriggered: {
                var baseUrl = Constants.networkExplorerLinks.arbiscan
                if (root.areTestNetworksEnabled) {
                    baseUrl = Constants.networkExplorerLinks.goerliArbiscan
                }
                Global.openLink("%1/%2/%3".arg(baseUrl).arg(Constants.networkExplorerLinks.addressPath).arg(d.visibleAddress ? d.visibleAddress : root.ens))
            }
        }
        StatusAction {
            text: qsTr("View on Optimism Explorer")
            objectName: "viewOnOptimismExplorerAction"
            assetSettings.name: "external"
            onTriggered: {
                var baseUrl = Constants.networkExplorerLinks.optimistic
                if (root.areTestNetworksEnabled) {
                    baseUrl = Constants.networkExplorerLinks.goerliOptimistic
                }
                Global.openLink("%1/%2/%3".arg(baseUrl).arg(Constants.networkExplorerLinks.addressPath).arg(d.visibleAddress ? d.visibleAddress : root.ens))
            }
        }
        StatusMenuSeparator { }
        StatusAction {
            text: qsTr("Delete")
            type: StatusAction.Type.Danger
            assetSettings.name: "delete"
            objectName: "deleteSavedAddress"
            onTriggered: {
                Global.openDeleteSavedAddressesPopup({
                                                         name: editDeleteMenu.contactName,
                                                         address: editDeleteMenu.contactAddress,
                                                         favourite: editDeleteMenu.storeFavourite,
                                                         ens: editDeleteMenu.contactEns
                                                     })
            }
        }
    }
}
