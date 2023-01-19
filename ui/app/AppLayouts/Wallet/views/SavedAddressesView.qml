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

import "../stores"
import "../popups"
import "../controls"

Item {
    id: root
    width: 500
    height: 300
    anchors.leftMargin: Style.current.padding
    anchors.rightMargin: Style.current.padding

    property var sendModal
    property var contactsStore

    QtObject {
        id: _internal
        property bool loading: false
        property string error: ""
        function saveAddress(name, address, favourite) {
            loading = true
            error = RootStore.createOrUpdateSavedAddress(name, address, favourite)
            loading = false
        }
        function deleteSavedAddress(address) {
            loading = true
            error = RootStore.deleteSavedAddress(address)
            loading = false
        }
    }

    Item {
        id: header
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: parent.top
        height: btnAdd.height

        StatusBaseText {
            anchors.left: parent.left
            anchors.verticalCenter: parent.verticalCenter
            id: title
            text: qsTr("Saved addresses")
            font.weight: Font.Bold
            font.pixelSize: 28
            color: Theme.palette.directColor1
        }
        StatusButton {
            objectName: "addNewAddressBtn"
            id: btnAdd
            anchors.right: parent.right
            anchors.top: parent.top
            anchors.verticalCenter: parent.verticalCenter
            size: StatusBaseButton.Size.Small
            font.weight: Font.Medium
            text: qsTr("Add new address")
            visible: !_internal.loading
            onClicked: {
                Global.openPopup(addEditSavedAddress)
            }
        }
        StatusLoadingIndicator {
            anchors.centerIn: parent
            visible: _internal.loading
            color: Theme.palette.directColor4
        }
    }

    SavedAddressesError {
        id: errorMessage
        anchors.top: header.bottom
        anchors.topMargin: Style.current.padding
        visible: _internal.error !== ""
        text: _internal.error
        height: visible ? 36 : 0
    }

    StatusBaseText {
        anchors.centerIn: parent
        visible: listView.count === 0
        color: Theme.palette.baseColor1
        text: qsTr("No saved addresses")
    }

    StatusListView {
        id: listView
        objectName: "SavedAddressesView_savedAddresses"
        anchors.top: errorMessage.bottom
        anchors.topMargin: Style.current.padding
        anchors.bottom: parent.bottom
        anchors.bottomMargin: Style.current.halfPadding
        anchors.right: parent.right
        anchors.left: parent.left
        visible: listView.count > 0
        spacing: 5
        // model: RootStore.savedAddresses
        model: RootStore.exampleSavedAddresses
        delegate: SavedAddressesDelegate {
            objectName: "savedAddressView_Delegate_" + name

            name: model.name
            address: model.address
            ens: model.ens
            favourite: model.favourite
            store: RootStore
            contactsStore: root.contactsStore
            onOpenSendModal: root.sendModal.open(address);
            saveAddress: function(name, address, favourite) {
                _internal.saveAddress(name, address, favourite)
            }
            deleteSavedAddress: function(address) {
                _internal.deleteSavedAddress(address)
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
                 _internal.saveAddress(name, address, favourite)
                close()
            }
        }
    }
}
