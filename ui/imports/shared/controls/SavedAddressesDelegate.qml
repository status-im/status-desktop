import QtQuick 2.13
import QtQuick.Controls 2.13

import utils 1.0

import StatusQ.Controls 0.1
import StatusQ.Components 0.1
import StatusQ.Core 0.1
import StatusQ.Core.Utils 0.1
import StatusQ.Core.Theme 0.1
import StatusQ.Popups 0.1
import shared.controls 1.0

import "../popups"
import "../controls"

StatusListItem {
    id: root

    property var store
    property var contactsStore
    property string name
    property string address
    property string ens
    property bool favourite: false
    property var saveAddress: function (name, address, favourite) {}
    property var deleteSavedAddress: function (address) {}

    signal openSendModal()

    implicitWidth: parent.width

    title: name
    objectName: name
    subTitle: (ens.length > 0 ? ens + " \u2022 " : "")
                + Utils.elideText(address, 6, 4)
    border.color: Theme.palette.baseColor5
    // titleTextIcon: root.favourite ? "star-icon" : ""
    asset.name: root.favourite ? "star-icon" : "favourite"
    // asset.color: showButtons ? Theme.palette.directColor1 : Theme.palette.directColor5
    // asset.color: showButtons ? Theme.palette.directColor1 : Theme.palette.baseColor1
    asset.color: root.favourite ? Theme.palette.pinColor1 : (showButtons ? Theme.palette.directColor1 : Theme.palette.baseColor1) // star icon color default
    // asset.color: Theme.palette.baseColor1
    asset.hoverColor: root.favourite ? "transparent": Theme.palette.directColor1 // star icon color on hover
    // asset.color: Theme.palette.directColor5
    // asset.hoverColor: Theme.palette.directColor1
    // type: StatusListItem.Type.Secondary
    asset.bgColor: statusListItemIcon.hovered ? Theme.palette.primaryColor3 : "transparent" // icon outer background color
    asset.bgRadius: 8

    onIconClicked: {
        console.log("delegate.onIconClicked:", mouse.x, mouse.y)
        root.saveAddress(root.name, root.address, !root.favourite)
    }

        // StatusRoundButton {
        //     objectName: "savedAddressView_Delegate_favouriteButton"
        //     icon.color: root.showButtons ? Theme.palette.directColor1 : Theme.palette.baseColor1
        //     type: StatusRoundButton.Type.Tertiary
        //     icon.name: root.favourite ? "unfavourite" : "favourite"
        //     onClicked: {
        //         root.saveAddress(root.name, root.address, !root.favourite)
        //     }
        // },
    statusListItemSubTitle.font.pixelSize: 13
    statusListItemComponentsSlot.spacing: 0
    property bool showButtons: sensor.containsMouse

    components: [
        StatusRoundButton {
            icon.color: root.showButtons ? Theme.palette.directColor1 : Theme.palette.baseColor1
            type: StatusRoundButton.Type.Quinary
            radius: 8
            icon.name: "send"
            onClicked: openSendModal()
        },
        StatusRoundButton {
            objectName: "savedAddressView_Delegate_menuButton"
            visible: !!root.name
            icon.color: root.showButtons ? Theme.palette.directColor1 : Theme.palette.baseColor1
            type: StatusRoundButton.Type.Quinary
            radius: 8
            icon.name: "more"
            onClicked: {
                editDeleteMenu.openMenu(root.name, root.address, root.favourite);
            }
        },
        StatusRoundButton {
            visible: !root.name
            // visible: true
            icon.color: root.showButtons ? Theme.palette.directColor1 : Theme.palette.baseColor1
            type: StatusRoundButton.Type.Tertiary
            icon.name: "add"
            onClicked: {
                Global.openPopup(addEditSavedAddress,
                                 {
                                     addAddress: true,
                                     address: root.address
                                 })
            }
        }
    ]

    StatusMenu {
        id: editDeleteMenu
        property string contactName
        property string contactAddress
        property bool storeFavourite
        function openMenu(name, address, favourite) {
            contactName = name;
            contactAddress = address;
            storeFavourite = favourite;
            popup();
        }
        onClosed: {
            contactName = "";
            contactAddress = "";
            storeFavourite = false;
        }
        StatusAction {
            text: qsTr("Edit")
            objectName: "editroot"
            assetSettings.name: "pencil-outline"
            onTriggered: {
                Global.openPopup(addEditSavedAddress,
                                 {
                                     edit: true,
                                     address: editDeleteMenu.contactAddress,
                                     name: editDeleteMenu.contactName,
                                     favourite: editDeleteMenu.storeFavourite
                                 })
            }
        }
        StatusAction {
            text: qsTr("Copy")
            objectName: "copySavedAddressAction"
            assetSettings.name: "copy"
            onTriggered: {
                if (root.address)
                    store.copyToClipboard(root.address)
            }
        }
        StatusMenuSeparator { }
        StatusAction {
            text: qsTr("View on Etherscan")
            objectName: "viewOnEtherscanAction"
            assetSettings.name: "external"
            onTriggered: {
                Qt.openUrlExternally("https://etherscan.io/address/%1".arg(root.address))
            }
        }
        StatusMenuSeparator { }
        StatusAction {
            text: qsTr("Delete")
            type: StatusAction.Type.Danger
            assetSettings.name: "delete"
            objectName: "deleteSavedAddress"
            onTriggered: {
                deleteAddressConfirm.name = editDeleteMenu.contactName;
                deleteAddressConfirm.address = editDeleteMenu.contactAddress;
                deleteAddressConfirm.favourite = editDeleteMenu.storeFavourite;
                deleteAddressConfirm.open()
            }
        }
    }

    Component {
        id: addEditSavedAddress
        AddEditSavedAddressPopup {
            id: addEditModal
            anchors.centerIn: parent
            onClosed: destroy()
            contactsStore: root.contactsStore
            onSave: {
                root.saveAddress(name, address, favourite)
                close()
            }
        }
    }

    StatusModal {
        id: deleteAddressConfirm
        property string address
        property string name
        property bool favourite
        anchors.centerIn: parent
        header.title: qsTr("Are you sure?")
        header.subTitle: name
        contentItem: StatusBaseText {
            anchors.centerIn: parent
            height: contentHeight + topPadding + bottomPadding
            text: qsTr("Are you sure you want to remove '%1' from your saved addresses?").arg(name)
            font.pixelSize: 15
            color: Theme.palette.directColor1
            wrapMode: Text.Wrap
            topPadding: Style.current.padding
            rightPadding: Style.current.padding
            bottomPadding: Style.current.padding
            leftPadding: Style.current.padding
        }
        rightButtons: [
            StatusButton {
                text: qsTr("Cancel")
                onClicked: deleteAddressConfirm.close()
            },
            StatusButton {
                type: StatusBaseButton.Type.Danger
                objectName: "confirmDeleteSavedAddress"
                text: qsTr("Delete")
                onClicked: {
                    root.deleteSavedAddress(deleteAddressConfirm.address)
                    deleteAddressConfirm.close()
                }
            }
        ]
    }
}
