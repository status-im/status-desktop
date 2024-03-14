import QtQuick 2.14

import StatusQ.Popups.Dialog 0.1

import shared.views 1.0

StatusDialog {
    id: root

    property var parentPopup

    property string publicKey

    property var profileStore
    property var contactsStore
    property var networkConnectionStore

    property var dirtyValues: ({})
    property bool dirty: false

    width: 640
    padding: 0

    header: null
    footer: null

    contentItem: ProfileDialogView {
        publicKey: root.publicKey
        profileStore: root.profileStore
        contactsStore: root.contactsStore
        networkConnectionStore: root.networkConnectionStore
        onCloseRequested: root.close()
        dirtyValues: root.dirtyValues
        dirty: root.dirty
    }
}
