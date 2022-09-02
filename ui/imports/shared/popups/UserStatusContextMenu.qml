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
        objectName: "userStatusViewMyProfileAction"
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
        objectName: "userStatusMenuAlwaysOnlineAction"
        text: qsTr("Always online")
        icon.name: Style.svg("statuses/online")
        assetSettings.isImage: true
        icon.width: 12
        icon.height: 12
        fontSettings.bold: root.store.userProfileInst.currentUserStatus === Constants.currentUserStatus.alwaysOnline
        onTriggered: {
            store.setCurrentUserStatus(Constants.currentUserStatus.alwaysOnline)
            root.close();
        }
    }

    StatusMenuItem {
        id: inactiveAction
        objectName: "userStatusMenuInactiveAction"
        text: qsTr("Inactive")
        icon.name: Style.svg("statuses/inactive")
        assetSettings.isImage: true
        icon.width: 12
        icon.height: 12
        fontSettings.bold: root.store.userProfileInst.currentUserStatus === Constants.currentUserStatus.inactive
        onTriggered: {
            store.setCurrentUserStatus(Constants.currentUserStatus.inactive)
            root.close();
        }
    }

    StatusMenuItem {
        id: automaticAction
        objectName: "userStatusMenuAutomaticAction"
        text: qsTr("Set status automatically")
        icon.name: Style.svg("statuses/automatic")
        assetSettings.isImage: true
        fontSettings.bold: root.store.userProfileInst.currentUserStatus === Constants.currentUserStatus.automatic
        onTriggered: {
            store.setCurrentUserStatus(Constants.currentUserStatus.automatic)
            root.close();
        }
    }
}
