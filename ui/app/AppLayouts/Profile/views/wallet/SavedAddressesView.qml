import QtQuick 2.15
import QtQuick.Layouts 1.15

import AppLayouts.Wallet.views 1.0

import "../../stores"

ColumnLayout {
    id: root

    property ContactsStore contactsStore
    property var networkConnectionStore
    property var sendModal

    SavedAddresses {
        sendModal: root.sendModal
        contactsStore: root.contactsStore
        networkConnectionStore: root.networkConnectionStore
    }
}
