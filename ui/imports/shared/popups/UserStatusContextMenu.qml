import QtQuick 2.12
import QtQuick.Controls 2.3
import QtQuick.Layouts 1.3
import QtQml.Models 2.3

import utils 1.0
import shared.controls.chat 1.0
import shared.panels 1.0

import StatusQ.Components 0.1

// TODO: replace with StatusPopupMenu
PopupMenu {
    id: root

    property var store

    width: 200
    closePolicy: Popup.CloseOnReleaseOutsideParent | Popup.CloseOnEscape

    overrideTextColor: Style.current.textColor

    ProfileHeader {
        width: parent.width

        displayName: root.store.userProfileInst.name
        pubkey: root.store.userProfileInst.pubKey
        icon: root.store.userProfileInst.icon
    }

    Item {
        height: root.topPadding
    }

    Separator {
    }

    Action {
        text: qsTr("View My Profile")

        icon.source: Style.svg("profile")
        icon.width: 16
        icon.height: 16

        onTriggered: {
            Global.openProfilePopup(root.store.userProfileInst.pubKey)
            root.close()
        }
    }

    Separator {
    }

    Action {
        text: qsTr("Always online")
        onTriggered: {
            //TODO move this to the store as soon as #4274 is merged
            if (userProfile.currentUserStatus !== Constants.currentUserStatus.alwaysOnline) {
                mainModule.setCurrentUserStatus(Constants.currentUserStatus.alwaysOnline);
            }
            root.close();
        }

        icon.color: Style.current.green
        icon.source: Style.svg("online")
        icon.width: 16
        icon.height: 16
    }

    Action {
        text: qsTr("Inactive")
        onTriggered: {
            //TODO move this to the store as soon as #4274 is merged
            if (userProfile.currentUserStatus !== Constants.currentUserStatus.inactive) {
                mainModule.setCurrentUserStatus(Constants.currentUserStatus.inactive);
            }
            root.close();
        }

        icon.color: Style.current.midGrey
        icon.source: Style.svg("offline")
        icon.width: 16
        icon.height: 16
    }

    Action {
        text: qsTr("Set status automatically")
        onTriggered: {
            //TODO move this to the store as soon as #4274 is merged
            if (userProfile.currentUserStatus !== Constants.currentUserStatus.automatic) {
                mainModule.setCurrentUserStatus(Constants.currentUserStatus.automatic);
            }
            root.close();
        }

        icon.color: Style.current.green
        icon.source: Style.svg("online")
        icon.width: 16
        icon.height: 16
    }
}
