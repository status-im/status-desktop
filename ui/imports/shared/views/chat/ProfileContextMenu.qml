import QtQuick 2.15
import QtQuick.Controls 2.15

import StatusQ.Core.Utils 0.1 as StatusQUtils
import StatusQ.Popups 0.1

import shared 1.0
import shared.controls.chat 1.0
import shared.controls.chat.menuItems 1.0
import shared.status 1.0
import utils 1.0

StatusMenu {
    id: root

    property string compressedPubKey: ""
    property string displayName: ""
    property string userIcon: ""
    property int trustStatus: Constants.trustStatus.unknown
    property int contactType: Constants.contactType.nonContact
    property int onlineStatus: Constants.onlineStatus.unknown
    property int profileType: Constants.profileType.regular
    property bool ensVerified: false
    property bool hasLocalNickname: false
    property int chatType: Constants.chatType.unknown
    property bool isAdmin: false
    property var emojiHash: []
    property var colorHash: []
    property int colorId

    signal openProfileClicked
    signal createOneToOneChat
    signal reviewContactRequest
    signal sendContactRequest
    signal editNickname
    signal removeNickname(string displayName)
    signal unblockContact
    signal markAsUntrusted
    signal removeTrustStatus
    signal removeContact
    signal blockContact
    signal removeFromGroup

    ProfileHeader {
        displayNameVisible: false
        displayNamePlusIconsVisible: true
        editButtonVisible: false
        displayName: StatusQUtils.Emoji.parse(root.displayName, StatusQUtils.Emoji.size.verySmall)
        compressedPubKey: root.compressedPubKey
        emojiHash: root.emojiHash
        colorHash: root.colorHash
        colorId: root.colorId
        icon: root.userIcon
        trustStatus: root.profileType === Constants.profileType.regular ? root.trustStatus : Constants.trustStatus.unknown
        isContact: root.profileType === Constants.profileType.regular ? root.contactType === Constants.contactType.contact : false
        isBlocked: root.profileType === Constants.profileType.blocked
        isCurrentUser: root.profileType === Constants.profileType.self
        userIsEnsVerified: root.ensVerified
        isBridgedAccount: root.profileType === Constants.profileType.bridged
        Binding on onlineStatus {
            value: root.onlineStatus
            when: root.profileType !== Constants.profileType.bridged
        }
    }

    StatusMenuSeparator {
        visible: root.profileType !== Constants.profileType.bridged
        topPadding: root.topPadding
    }

    ViewProfileMenuItem {
        id: viewProfileAction
        objectName: "viewProfile_StatusItem"
        enabled: root.profileType !== Constants.profileType.bridged
        onTriggered: {
            root.openProfileClicked()
            root.close()
        }
    }

    // Edit Nickname
    StatusAction {
        id: renameAction
        objectName: "rename_StatusItem"
        enabled: root.profileType === Constants.profileType.blocked || root.profileType === Constants.profileType.regular
        text: root.hasLocalNickname ? qsTr("Edit nickname") : qsTr("Add nickname")
        icon.name: "edit_pencil"
        onTriggered: root.editNickname()
    }

    // Review Contact Request
    StatusAction {
        text: qsTr("Review contact request")
        objectName: "reviewContactRequest_StatusItem"
        icon.name: "add-contact"
        enabled: root.profileType === Constants.profileType.regular && root.contactType === Constants.contactType.contactRequestReceived
        onTriggered: root.reviewContactRequest()
    }

    // Send Message
    SendMessageMenuItem {
        id: sendMessageMenuItem
        objectName: "sendMessage_StatusItem"
        enabled: root.profileType === Constants.profileType.regular && root.contactType === Constants.contactType.contact
        onTriggered: {
            root.createOneToOneChat()
            root.close()
        }
    }

    // Send Contact Request
    SendContactRequestMenuItem {
        id: sendContactRequestMenuItem
        objectName: "sendContactRequest_StatusItem"
        enabled: root.profileType === Constants.profileType.regular && root.contactType === Constants.contactType.nonContact
        onTriggered: root.sendContactRequest()
    }

    StatusMenuSeparator {
        topPadding: root.topPadding
        visible: root.profileType !== Constants.profileType.bridged &&
                 (removeNicknameAction.enabled || unblockAction.enabled || markUntrustworthyMenuItem.enabled || removeUntrustworthyMarkMenuItem.enabled || removeContactAction.enabled || blockMenuItem.enabled)
    }

    // Remove Nickname
    StatusAction {
        id: removeNicknameAction
        text: qsTr("Remove nickname")
        icon.name: "delete"
        type: StatusAction.Type.Danger
        enabled: (root.profileType === Constants.profileType.blocked || root.profileType === Constants.profileType.regular) && root.hasLocalNickname
        onTriggered: root.removeNickname(root.displayName)
    }

    // Unblock User
    StatusAction {
        id: unblockAction
        objectName: "unblock_StatusItem"
        enabled: root.profileType === Constants.profileType.blocked
        text: qsTr("Unblock user")
        icon.name: "cancel"
        type: StatusAction.Type.Danger
        onTriggered: root.unblockContact()
    }

    StatusAction {
        text: qsTr("Remove from group")
        objectName: "removeFromGroup_StatusItem"
        icon.name: "remove-contact"
        type: StatusAction.Type.Danger
        enabled: root.isAdmin && root.profileType !== Constants.profileType.self && root.chatType === Constants.chatType.privateGroupChat
        onTriggered: root.removeFromGroup()
    }

    // Mark as Untrusted
    StatusAction {
        id: markUntrustworthyMenuItem
        objectName: "markUntrustworthy_StatusItem"
        text: qsTr("Mark as untrusted")
        icon.name: "warning"
        type: StatusAction.Type.Danger
        enabled: root.profileType === Constants.profileType.regular && root.trustStatus !== Constants.trustStatus.untrustworthy
        onTriggered: root.markAsUntrusted()
    }

    // Remove Untrustworthy Mark
    StatusAction {
        id: removeUntrustworthyMarkMenuItem
        objectName: "removeUntrustworthy_StatusItem"
        text: qsTr("Remove untrusted mark")
        icon.name: "warning"
        type: StatusAction.Type.Danger
        enabled: root.profileType === Constants.profileType.regular && root.trustStatus === Constants.trustStatus.untrustworthy
        onTriggered: root.removeTrustStatus()
    }

    // Remove Contact
    StatusAction {
        id: removeContactAction
        text: qsTr("Remove contact")
        objectName: "removeContact_StatusItem"
        icon.name: "remove-contact"
        type: StatusAction.Type.Danger
        enabled: root.profileType === Constants.profileType.regular && root.contactType === Constants.contactType.contact
        onTriggered: root.removeContact()
    }

    // Block User
    StatusAction {
        id: blockMenuItem
        objectName: "blockUser_StatusItem"
        text: qsTr("Block user")
        icon.name: "cancel"
        type: StatusAction.Type.Danger
        enabled: root.profileType === Constants.profileType.regular
        onTriggered: root.blockContact()
    }
}
