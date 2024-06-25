import QtQuick 2.12
import QtQuick.Controls 2.14
import QtQuick.Layouts 1.3
import QtQml.Models 2.3

import utils 1.0
import shared.controls.chat 1.0
import shared.panels 1.0
import shared.controls.chat.menuItems 1.0

import StatusQ.Components 0.1
import StatusQ.Popups 0.1

import AppLayouts.stores 1.0

StatusMenu {
    id: root

    property RootStore store

    ProfileHeader {
        width: parent.width

        displayName: root.store.userProfileInst.name
        pubkey: root.store.userProfileInst.pubKey
        icon: root.store.userProfileInst.icon
        userIsEnsVerified: !!root.store.userProfileInst.preferredName
        objectName: 'onlineIdentifierProfileHeader'
    }

    StatusMenuSeparator {
    }

    ViewProfileMenuItem {
        objectName: "userStatusViewMyProfileAction"
        onTriggered: {
            Global.openProfilePopup(root.store.userProfileInst.pubKey)
            root.close()
        }
    }

    StatusAction {
        text: qsTr("Copy link to profile")
        icon.name: "copy"
        onTriggered: {
            Utils.copyToClipboard(root.store.contactStore.getLinkToProfile(root.store.userProfileInst.pubKey))
            root.close()
        }
    }

    StatusMenuSeparator {
    }

    StatusAction {
        id: alwaysOnlineAction
        objectName: "userStatusMenuAlwaysOnlineAction"
        text: qsTr("Always online")
        assetSettings.name: "statuses/online"
        assetSettings.width: 12
        assetSettings.height: 12
        assetSettings.color: "transparent"
        fontSettings.bold: root.store.userProfileInst.currentUserStatus === Constants.currentUserStatus.alwaysOnline
        onTriggered: {
            store.setCurrentUserStatus(Constants.currentUserStatus.alwaysOnline)
            root.close();
        }
    }

    StatusAction {
        id: inactiveAction
        objectName: "userStatusMenuInactiveAction"
        text: qsTr("Inactive")
        assetSettings.name: "statuses/inactive"
        assetSettings.width: 12
        assetSettings.height: 12
        assetSettings.color: "transparent"
        fontSettings.bold: root.store.userProfileInst.currentUserStatus === Constants.currentUserStatus.inactive
        onTriggered: {
            store.setCurrentUserStatus(Constants.currentUserStatus.inactive)
            root.close();
        }
    }

    StatusAction {
        id: automaticAction
        objectName: "userStatusMenuAutomaticAction"
        text: qsTr("Set status automatically")
        assetSettings.name: "statuses/automatic"
        assetSettings.color: "transparent"
        fontSettings.bold: root.store.userProfileInst.currentUserStatus === Constants.currentUserStatus.automatic
        onTriggered: {
            store.setCurrentUserStatus(Constants.currentUserStatus.automatic)
            root.close();
        }
    }
}
