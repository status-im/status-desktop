import QtQuick 2.15
import QtQuick.Layouts 1.15

import AppLayouts.Wallet.views 1.0

import shared.stores 1.0 as SharedStores

import "../../stores"

ColumnLayout {
    id: root

    property ContactsStore contactsStore
    property SharedStores.NetworkConnectionStore networkConnectionStore

    signal sendToAddressRequested(string address)

    SavedAddresses {
        contactsStore: root.contactsStore
        networkConnectionStore: root.networkConnectionStore

        onSendToAddressRequested: root.sendToAddressRequested(address)
    }
}
