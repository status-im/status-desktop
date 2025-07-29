import QtQuick
import QtQuick.Layouts

import StatusQ.Core
import StatusQ.Core.Utils as CoreUtils
import StatusQ.Core.Theme
import StatusQ.Components

import shared.views.chat
import utils

ActivityNotificationBase {
    id: root

    property var contactsModel

    readonly property bool isOutgoingMessage: notification && notification.message && notification.message.amISender || false
    readonly property string contactId: notification ? isOutgoingMessage ? notification.chatId : notification.author : ""
    readonly property string contactName: contactDetails ? ProfileUtils.displayName(contactDetails.localNickname, contactDetails.name,
                                                                                    contactDetails.displayName, contactDetails.alias) : ""
    property string contentHeaderAreaText: ""

    property var contactDetails: null
    property int maximumLineCount: 2

    signal messageClicked()
    signal openProfilePopup(string contactId)

    property StatusMessageDetails messageDetails: StatusMessageDetails {
        messageText: notification && notification.message ? notification.message.messageText : ""
        amISender: false
        sender.id: contactId
        sender.compressedPubKey: contactDetails ? contactDetails.compressedPubKey : ""
        sender.displayName: contactName
        sender.secondaryName: contactDetails && contactDetails.localNickname ?
                                  ProfileUtils.displayName("", contactDetails.name, contactDetails.displayName, contactDetails.alias) : ""
        sender.trustIndicator: contactDetails ? contactDetails.trustStatus : Constants.trustStatus.unknown
        sender.isEnsVerified: !!contactDetails && contactDetails.ensVerified
        sender.isContact: !!contactDetails && contactDetails.isContact
        sender.profileImage {
            width: 40
            height: 40
            name: contactDetails ? contactDetails.thumbnailImage : ""
            pubkey: contactId
            colorId: Utils.colorIdForPubkey(contactId)
            colorHash: Utils.getColorHashAsJson(contactId, sender.isEnsVerified)
        }
        contentType: notification && notification.message ? notification.message.contentType : StatusMessage.ContentType.Unknown
        album: notification && notification.message ? notification.message.albumMessageImages.split(" ") : []
        albumCount: notification && notification.message ? notification.message.albumImagesCount : 0
        messageContent: notification && notification.message ? notification.message.messageImage : ""
    }

    property Component messageSubheaderComponent: null
    property Component messageBadgeComponent: null

    function updateContactDetails() {
        contactDetails = notification ? Utils.getContactDetailsAsJson(contactId, false) : null
    }

    onContactIdChanged: root.updateContactDetails()

    CoreUtils.ModelEntryChangeTracker {
        model: root.contactsModel
        role: "pubKey"
        key: root.contactId

        onItemChanged: root.updateContactDetails()
    }

    avatarComponent:  Item {
        width: root.messageDetails.sender.profileImage.assetSettings.width
        height: profileImage.height

        StatusSmartIdenticon {
            id: profileImage
            name: root.messageDetails.sender.displayName
            asset: root.messageDetails.sender.profileImage.assetSettings
            ringSettings: root.messageDetails.sender.profileImage.ringSettings

            StatusMouseArea {
                anchors.fill: parent
                cursorShape: enabled ? Qt.PointingHandCursor : Qt.ArrowCursor
                acceptedButtons: Qt.LeftButton | Qt.RightButton
                onClicked: root.openProfilePopup(contactId)
            }
        }
    }

    bodyComponent: StatusMouseArea {
        implicitWidth: parent.width
        implicitHeight: messageView.implicitHeight
        hoverEnabled: root.messageBadgeComponent
        cursorShape: Qt.PointingHandCursor
        onClicked: {
            root.markActivityCenterNotificationReadRequested(notification.id)
            root.messageClicked()
        }

        SimplifiedMessageView {
            id: messageView
            width: parent.width
            maximumLineCount: root.maximumLineCount
            messageDetails: root.messageDetails
            contentHeaderAreaText: root.contentHeaderAreaText
            onOpenProfilePopup: root.openProfilePopup(contactId)
        }
    }
}
