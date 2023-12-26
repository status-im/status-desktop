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

    default property Item content

    Component.onCompleted: {
        content.parent = contentWrapper
    }

    ColumnLayout {
        anchors.left: parent.left
        anchors.right: parent.right
        spacing: 0

        WalletHeader {
            id: header
            Layout.fillWidth: true
            overview: RootStore.overview
            store: root.store
            walletStore: RootStore
            networkConnectionStore: root.networkConnectionStore
        }

        Column {
            id: contentWrapper
            Layout.fillWidth: true
        }
    }
}
