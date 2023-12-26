import QtQuick 2.13

RightTabBaseView {
    id: root

    SavedAddresses {
        width: root.width
        height: root.height - header.height

        sendModal: root.sendModal
        contactsStore: root.contactsStore
    }
}
