import QtQuick 2.14
import QtQuick.Layouts 1.14

import StatusQ.Core 0.1

import "../stores"
import "../panels"

FocusScope {
    id: root

    property var store
    property var contactsStore
    property var networkConnectionStore

    property var sendModal

    property alias header: header
    property alias headerButton: header.headerButton
    property alias networkFilter: header.networkFilter

    default property alias content: contentWrapper.children

    ColumnLayout {
        anchors.fill: parent
        spacing: 0

        WalletHeader {
            id: header
            Layout.fillWidth: true
            overview: RootStore.overview
            store: root.store
            walletStore: RootStore
            networkConnectionStore: root.networkConnectionStore
        }

        Item {
            id: contentWrapper
            Layout.fillWidth: true
            Layout.fillHeight: true
        }
    }
}
