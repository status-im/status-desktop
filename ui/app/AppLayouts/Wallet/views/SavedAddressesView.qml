import QtQuick

RightTabBaseView {
    id: root

    signal sendToAddressRequested(string address)

    SavedAddresses {
        objectName: "savedAddressesArea"

        contactsStore: root.contactsStore
        networkConnectionStore: root.networkConnectionStore
        networksStore: root.networksStore

        onSendToAddressRequested: root.sendToAddressRequested(address)
    }
}
