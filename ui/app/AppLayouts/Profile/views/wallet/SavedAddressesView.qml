import QtQuick 2.15
import QtQuick.Layouts 1.15

import AppLayouts.Wallet.views 1.0

import shared.stores 1.0 as SharedStores
import AppLayouts.stores 1.0 as AppLayoutStores

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
