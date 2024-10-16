import StatusQ.Popups 0.1

import shared.controls.chat 1.0
import shared.controls.chat.menuItems 1.0
import shared.panels 1.0
import utils 1.0

StatusMenu {
    id: root

    property string pubKey
    property alias name: header.displayName
    property alias icon: header.icon

    property alias isEnsVerified: header.userIsEnsVerified

    // Constants.currentUserStatus
    property int currentUserStatus

    signal viewProfileRequested
    signal copyLinkRequested
    signal setCurrentUserStatusRequested(int status)

    ProfileHeader {
        id: header

        objectName: 'onlineIdentifierProfileHeader'

        width: parent.width
        pubkey: root.pubKey
    }

    StatusMenuSeparator {}

    ViewProfileMenuItem {
        objectName: "userStatusViewMyProfileAction"
        onTriggered: {
            root.viewProfileRequested()
            root.close()
        }
    }

    StatusAction {
        objectName: "userStatusCopyLinkAction"
        text: qsTr("Copy link to profile")
        icon.name: "copy"
        onTriggered: {
            root.copyLinkRequested()
            root.close()
        }
    }

    StatusMenuSeparator {}

    StatusAction {
        objectName: "userStatusMenuAlwaysOnlineAction"
        text: qsTr("Always online")
        assetSettings.name: "statuses/online"
        assetSettings.width: 12
        assetSettings.height: 12
        assetSettings.color: "transparent"
        fontSettings.bold: root.currentUserStatus === Constants.currentUserStatus.alwaysOnline
        onTriggered: {
            root.setCurrentUserStatusRequested(Constants.currentUserStatus.alwaysOnline)
            root.close()
        }
    }

    StatusAction {
        objectName: "userStatusMenuInactiveAction"
        text: qsTr("Inactive")
        assetSettings.name: "statuses/inactive"
        assetSettings.width: 12
        assetSettings.height: 12
        assetSettings.color: "transparent"
        fontSettings.bold: root.currentUserStatus === Constants.currentUserStatus.inactive
        onTriggered: {
            root.setCurrentUserStatusRequested(Constants.currentUserStatus.inactive)
            root.close()
        }
    }

    StatusAction {
        objectName: "userStatusMenuAutomaticAction"
        text: qsTr("Set status automatically")
        assetSettings.name: "statuses/automatic"
        assetSettings.color: "transparent"
        fontSettings.bold: root.currentUserStatus === Constants.currentUserStatus.automatic
        onTriggered: {
            root.setCurrentUserStatusRequested(Constants.currentUserStatus.automatic)
            root.close()
        }
    }
}
