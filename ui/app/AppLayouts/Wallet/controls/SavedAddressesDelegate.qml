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

        readonly property string visibleAddress: root.address == Constants.zeroAddress ? root.ens : root.address
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
        StatusAction {
            text: qsTr("Copy address")
            objectName: "copySavedAddressAction"
            assetSettings.name: "copy"
            onTriggered: {
                if (d.visibleAddress)
                    store.copyToClipboard(d.visibleAddress)
                else
                    store.copyToClipboard(root.ens)
            }
        }
        StatusAction {
            text: qsTr("Show address QR")
            objectName: "showQrSavedAddressAction"
            assetSettings.name: "qr"
            onTriggered: {
                console.warn("TODO: open qr popup...")
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
