import QtQuick 2.13
import QtQuick.Controls 2.13
import QtQuick.Layouts 1.13

import utils 1.0

import StatusQ.Controls 0.1
import StatusQ.Components 0.1
import StatusQ.Core 0.1
import StatusQ.Core.Theme 0.1
import StatusQ.Popups 0.1
import shared.controls 1.0
import SortFilterProxyModel 0.2

import "../stores"
import "../popups"
import "../controls"

Item {
    id: root
    anchors.leftMargin: Style.current.padding
    anchors.rightMargin: Style.current.padding

    property var sendModal
    property var contactsStore

    QtObject {
        id: _internal
        property bool loading: false
        property string error: ""
        property var lastCreatedAddress // used to display animation for the newly saved address
        function saveAddress(name, address, favourite, chainShortNames, ens) {
            loading = true
            error = RootStore.createOrUpdateSavedAddress(name, address, favourite, chainShortNames, ens)
            loading = false
        }
        function deleteSavedAddress(address, ens) {
            loading = true
            error = RootStore.deleteSavedAddress(address, ens)
            loading = false
        }

        function resetLastCreatedAddress() {
            lastCreatedAddress = undefined
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
        anchors.top: header.bottom
        anchors.topMargin: Style.current.padding
        anchors.bottom: parent.bottom
        anchors.right: parent.right
        anchors.left: parent.left
        spacing: 5
        visible: count > 0
        model: SortFilterProxyModel {
            sourceModel: RootStore.savedAddresses
            sorters: RoleSorter { roleName: "createdAt"; sortOrder: Qt.DescendingOrder }
        }
        delegate: SavedAddressesDelegate {
            id: savedAddressDelegate
            objectName: "savedAddressView_Delegate_" + name
            name: model.name
            address: model.address
            chainShortNames: model.chainShortNames
            ens: model.ens
            favourite: model.favourite
            store: RootStore
            contactsStore: root.contactsStore
            areTestNetworksEnabled: RootStore.areTestNetworksEnabled
            isSepoliaEnabled: RootStore.isSepoliaEnabled
            onOpenSendModal: root.sendModal.open(recipient);
            saveAddress: function(name, address, favourite, chainShortNames, ens) {
                _internal.saveAddress(name, address, favourite, chainShortNames, ens)
            }
            deleteSavedAddress: function(address, ens) {
                _internal.deleteSavedAddress(address, ens)
            }

            states: [
                State {
                    name: "highlighted"
                    when: _internal.lastCreatedAddress ? (_internal.lastCreatedAddress.address.toLowerCase() === address.toLowerCase() &&
                          _internal.lastCreatedAddress.ens === ens) : false
                    PropertyChanges { target: savedAddressDelegate; color: Theme.palette.baseColor2 }
                    StateChangeScript {
                        script: Qt.callLater(_internal.resetLastCreatedAddress)
                    }
                }
            ]

            transitions: [
                Transition {
                    from: "highlighted"
                    ColorAnimation {
                        target: savedAddressDelegate
                        duration: 3000
                    }
                }
            ]
        }
    }

    Component {
        id: addEditSavedAddress
        AddEditSavedAddressPopup {
            id: addEditModal
            anchors.centerIn: parent
            onClosed: destroy()
            contactsStore: root.contactsStore
            store: RootStore
            onSave: {
                 _internal.lastCreatedAddress = { address: address, ens: ens }
                 _internal.saveAddress(name, address, favourite, chainShortNames, ens)
                close()
            }
        }
    }
}
