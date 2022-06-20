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
        icon.width: Style.dp(16)
        icon.height: Style.dp(16)

        onTriggered: {
            Global.openProfilePopup(root.store.userProfileInst.pubKey)
            root.close()
        }
    }

    Separator {
    }

    Action {
        text: qsTr("Online")
        onTriggered: {
            //TODO move this to the store as soon as #4274 is merged
            if (userProfile.userStatus !== true) {
                mainModule.setUserStatus(true);
            }
            root.close();
        }
        icon.color: Style.current.green
        icon.source: Style.svg("online")
        icon.width: Style.dp(16)
        icon.height: Style.dp(16)
    }

    Action {
        text: qsTr("Offline")
        onTriggered: {
            //TODO move this to the store as soon as #4274 is merged
            if (userProfile.userStatus !== false) {
                mainModule.setUserStatus(false);
            }
            root.close();
        }

        icon.color: Style.current.midGrey
        icon.source: Style.svg("offline")
        icon.width: Style.dp(16)
        icon.height: Style.dp(16)
    }
}
