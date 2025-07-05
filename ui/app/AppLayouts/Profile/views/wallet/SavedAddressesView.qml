import QtQuick
import QtQuick.Layouts

import AppLayouts.Wallet.views

import shared.stores as SharedStores
import AppLayouts.stores as AppLayoutStores

import "../../stores"

ColumnLayout {
    id: root

    property AppLayoutStores.ContactsStore contactsStore
    property SharedStores.NetworkConnectionStore networkConnectionStore
    required property SharedStores.NetworksStore networksStore

    signal sendToAddressRequested(string address)

    SavedAddresses {
        contactsStore: root.contactsStore
        networkConnectionStore: root.networkConnectionStore
        networksStore: root.networksStore

        onSendToAddressRequested: root.sendToAddressRequested(address)
    }
}
