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
    color: "transparent"
    border.color: Theme.palette.baseColor5
    titleTextIcon: root.favourite ? "star-icon" : ""
    statusListItemComponentsSlot.spacing: 0
    property bool showButtons: sensor.containsMouse

    components: [
        StatusRoundButton {
            icon.color: root.showButtons ? Theme.palette.directColor1 : Theme.palette.baseColor1
            type: StatusRoundButton.Type.Tertiary
            icon.name: "send"
            onClicked: openSendModal()
        },
        CopyToClipBoardButton {
            id: copyButton
            type: StatusRoundButton.Type.Tertiary
            icon.color: root.showButtons ? Theme.palette.directColor1 : Theme.palette.baseColor1
            store: root.store
            textToCopy: root.address
        },
        StatusRoundButton {
            objectName: "savedAddressView_Delegate_favouriteButton"
            icon.color: root.showButtons ? Theme.palette.directColor1 : Theme.palette.baseColor1
            type: StatusRoundButton.Type.Tertiary
            icon.name: root.favourite ? "unfavourite" : "favourite"
            onClicked: {
                root.saveAddress(root.name, root.address, !root.favourite)
            }
        },
        StatusRoundButton {
            objectName: "savedAddressView_Delegate_menuButton"
            visible: !!root.name
            icon.color: root.showButtons ? Theme.palette.directColor1 : Theme.palette.baseColor1
            type: StatusRoundButton.Type.Tertiary
            icon.name: "more"
            onClicked: {
                editDeleteMenu.openMenu(root.name, root.address, root.favourite);
            }
        },
        StatusRoundButton {
            visible: !root.name
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

    StatusPopupMenu {
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
        StatusMenuItem {
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
        StatusMenuSeparator { }
        StatusMenuItem {
            text: qsTr("Delete")
            type: StatusMenuItem.Type.Danger
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
