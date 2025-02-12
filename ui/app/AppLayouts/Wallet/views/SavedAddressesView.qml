import QtQuick 2.13

RightTabBaseView {
    id: root

    signal sendToAddressRequested(string address)

    SavedAddresses {
        objectName: "savedAddressesArea"
        width: root.width
        height: root.height - header.height

        contactsStore: root.contactsStore
        networkConnectionStore: root.networkConnectionStore
        networksStore: root.networksStore

        onSendToAddressRequested: root.sendToAddressRequested(address)
    }
}
