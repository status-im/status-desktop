import QtQuick 2.14
import QtQuick.Layouts 1.14

import StatusQ.Core 0.1
import StatusQ.Core.Theme 0.1
import StatusQ.Components 0.1

import shared 1.0
import shared.panels 1.0
import utils 1.0

import "../panels"
import "../popups"

ActivityNotificationMessage {
    id: root

    readonly property bool isOutgoingRequest: notification && notification.message.amISender
    readonly property string contactId: notification ? isOutgoingRequest ? notification.chatId : notification.author : ""
    readonly property var contactDetails: notification ? Utils.getContactDetailsAsJson(contactId, false) : null

    readonly property bool pending: notification && notification.message.contactRequestState === Constants.contactRequestStatePending
    readonly property bool accepted: notification && notification.message.contactRequestState === Constants.contactRequestStateAccepted
    readonly property bool dismissed: notification && notification.message.contactRequestState === Constants.contactRequestStateDismissed

    maximumLineCount: 5

    messageDetails.messageText: {
        if (isOutgoingRequest && contactDetails) {
            const status = accepted ? qsTr("accepted") : dismissed ? qsTr("dismissed") : qsTr("recieved")
            return qsTr("%1 %2 your contact request").arg(contactDetails.displayName).arg(status)
        }

        if (!isOutgoingRequest && notification) {
            return notification.message.messageText
        }

        return ""
    }
    // TODO: unify with verification requests PR: https://github.com/status-im/status-desktop/pull/8246
    messageDetails.amISender: false
    messageDetails.sender.id: contactId
    messageDetails.sender.displayName: contactDetails ? contactDetails.displayName : ""
    messageDetails.sender.secondaryName: contactDetails ? contactDetails.localNickname : ""
    messageDetails.sender.trustIndicator: contactDetails ? contactDetails.trustStatus : 0
    messageDetails.sender.profileImage.name: contactDetails ? contactDetails.displayIcon : ""
    messageDetails.sender.profileImage.assetSettings.isImage: true
    messageDetails.sender.profileImage.pubkey: contactId
    messageDetails.sender.profileImage.colorId: Utils.colorIdForPubkey(notification ? contactId : "")
    messageDetails.sender.profileImage.colorHash: Utils.getColorHashAsJson(notification ? contactId : "", contactDetails.ensVerified)

    messageSubheaderComponent: !isOutgoingRequest ? subheaderComponent : null

    Component {
        id: subheaderComponent

        StatusBaseText {
            text: qsTr("Sent contact request:")
            color: Theme.palette.baseColor1
            font.italic: true
            font.pixelSize: 15
        }
    }

    ctaComponent: ContactRequestCta {
        isOutgoingRequest: root.isOutgoingRequest
        pending: root.pending
        accepted: root.accepted
        dismissed: root.dismissed
        blocked: contactDetails && contactDetails.isBlocked
        onAcceptClicked: root.store.contactsStore.acceptContactRequest(root.contactId)
        onDeclineClicked: root.store.contactsStore.dismissContactRequest(root.contactId)
        onProfileClicked: Global.openProfilePopup(root.contactId)
        onBlockClicked: {
            root.store.contactsStore.dismissContactRequest(root.contactId)
            root.store.contactsStore.blockContact(root.contactId)
        }
        onDetailsClicked: {
            Global.openPopup(reviewContactRequestPopupComponent, {
                messageDetails: root.messageDetails,
                timestampString: root.timestampString,
                timestampTooltipString: root.timestampTooltipString
            })
        }
    }

    Component {
        id: reviewContactRequestPopupComponent

        ReviewContactRequestPopup {
            id: reviewRequestPopup
            onAccepted: root.store.contactsStore.acceptContactRequest(root.contactId)
            onDeclined: root.store.contactsStore.dismissContactRequest(root.contactId)
        }
    }
}
