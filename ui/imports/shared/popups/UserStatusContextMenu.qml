import QtQuick 2.12
import QtQuick.Controls 2.14
import QtQuick.Layouts 1.3
import QtQml.Models 2.3

import utils 1.0
import shared.controls.chat 1.0
import shared.panels 1.0

import StatusQ.Components 0.1
import StatusQ.Popups 0.1

StatusPopupMenu {
    id: root

    property var store

    width: 210

    ProfileHeader {
        width: parent.width

        displayName: root.store.userProfileInst.name
        pubkey: root.store.userProfileInst.pubKey
        icon: root.store.userProfileInst.icon
    }

    StatusMenuSeparator {
    }

    StatusMenuItem {
        text: qsTr("View My Profile")
        icon.name: "profile"
        onTriggered: {
            Global.openProfilePopup(root.store.userProfileInst.pubKey)
            root.close()
        }
    }

    StatusMenuSeparator {
    }

    StatusMenuItem {
        id: alwaysOnlineAction
        text: qsTr("Always online")
        image.source: Style.svg("statuses/online")
        image.width: 12
        image.height: 12
        fontSettings.bold: root.store.userProfileInst.currentUserStatus === Constants.currentUserStatus.alwaysOnline
        onTriggered: {
            store.setCurrentUserStatus(Constants.currentUserStatus.alwaysOnline)
            root.close();
        }
    }

    StatusMenuItem {
        id: inactiveAction
        text: qsTr("Inactive")
        image.source: Style.svg("statuses/inactive")
        image.width: 12
        image.height: 12
        fontSettings.bold: root.store.userProfileInst.currentUserStatus === Constants.currentUserStatus.inactive
        onTriggered: {
            store.setCurrentUserStatus(Constants.currentUserStatus.inactive)
            root.close();
        }
    }

    StatusMenuItem {
        id: automaticAction
        text: qsTr("Set status automatically")
        image.source: Style.svg("statuses/automatic")
        fontSettings.bold: root.store.userProfileInst.currentUserStatus === Constants.currentUserStatus.automatic
        onTriggered: {
            store.setCurrentUserStatus(Constants.currentUserStatus.automatic)
            root.close();
        }
    }
}
