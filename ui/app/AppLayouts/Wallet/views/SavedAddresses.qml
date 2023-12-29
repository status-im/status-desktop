import QtQuick 2.14
import QtQuick.Controls 2.14
import QtQuick.Layouts 1.14

import StatusQ.Components 0.1
import StatusQ.Core 0.1
import StatusQ.Core.Theme 0.1

import SortFilterProxyModel 0.2

import shared.controls 1.0

import "../stores"
import "../controls"

ColumnLayout {
    id: root

    property var sendModal
    property var contactsStore

    QtObject {
        id: d

        function reset() {
            RootStore.lastCreatedSavedAddress = undefined
        }
    }

    ShapeRectangle {
        id: noSavedAddresses
        Layout.fillWidth: true
        visible: listView.count === 0
        text: qsTr("Your saved addresses will appear here")
    }

    StatusLoadingIndicator {
        id: loadingIndicator
        Layout.alignment: Qt.AlignHCenter
        visible: RootStore.addingSavedAddress || RootStore.deletingSavedAddress
        color: Theme.palette.directColor4
    }

    Item {
        visible: noSavedAddresses.visible || loadingIndicator.visible
        Layout.fillWidth: true
        Layout.fillHeight: true
    }

    SearchBox {
        Layout.fillWidth: true
        visible: listView.visible
        placeholderText: qsTr("Search for name, ENS or address")
    }

    StatusListView {
        id: listView
        objectName: "SavedAddressesView_savedAddresses"
        Layout.fillWidth: true
        Layout.fillHeight: true
        Layout.topMargin: 16
        spacing: 8
        visible: count > 0

        model: SortFilterProxyModel {
            sourceModel: RootStore.savedAddresses
            sorters: RoleSorter { roleName: "name"; sortOrder: Qt.AscendingOrder }
        }

        section.property: "name"
        section.criteria: ViewSection.FirstCharacter
        section.delegate: Item {
            height: 34
            width: children.width
            StatusBaseText {
                anchors.left: parent.left
                anchors.verticalCenter: parent.verticalCenter
                text: section.toUpperCase()
                color: Theme.palette.baseColor1
                font.pixelSize: 15
            }
        }

        delegate: SavedAddressesDelegate {
            id: savedAddressDelegate
            objectName: "savedAddressView_Delegate_" + name
            name: model.name
            address: model.address
            chainShortNames: model.chainShortNames
            ens: model.ens
            colorId: model.colorId
            favourite: model.favourite
            store: RootStore
            contactsStore: root.contactsStore
            areTestNetworksEnabled: RootStore.areTestNetworksEnabled
            isSepoliaEnabled: RootStore.isSepoliaEnabled
            onOpenSendModal: root.sendModal.open(recipient);

            states: [
                State {
                    name: "highlighted"
                    when: RootStore.lastCreatedSavedAddress ? (!RootStore.lastCreatedSavedAddress.error &&
                                                               RootStore.lastCreatedSavedAddress.address.toLowerCase() === address.toLowerCase() &&
                                                               RootStore.lastCreatedSavedAddress.ens === ens) : false
                    PropertyChanges { target: savedAddressDelegate; color: Theme.palette.baseColor2 }
                    StateChangeScript {
                        script: Qt.callLater(d.reset)
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
}
