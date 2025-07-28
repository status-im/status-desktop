import QtQuick
import QtQuick.Layouts

import StatusQ.Core
import StatusQ.Core.Theme
import StatusQ.Components

import shared
import shared.panels
import utils

import "../panels"
import "../popups"
import "../stores"

ActivityNotificationMessage {
    id: root

    readonly property bool pending: notification && notification.message.contactRequestState === ActivityCenterStore.ActivityCenterContactRequestState.Pending
    readonly property bool accepted: notification && notification.message.contactRequestState === ActivityCenterStore.ActivityCenterContactRequestState.Accepted
    readonly property bool dismissed: notification && notification.message.contactRequestState === ActivityCenterStore.ActivityCenterContactRequestState.Dismissed

    readonly property string contactRequestId: notification && notification.message ? notification.message.id : ""

    maximumLineCount: 5
    messageDetails.messageText: !root.isOutgoingMessage && notification ? notification.message.messageText : ""

    messageSubheaderComponent: StatusBaseText {
        text: root.isOutgoingMessage ? qsTr("Contact request sent to %1").arg(contactName) :
                                       qsTr("Contact request:")
        font.italic: true
        font.pixelSize: Theme.primaryTextFontSize
        maximumLineCount: 2
        wrapMode: Text.WordWrap
        color: Theme.palette.baseColor1
    }

    ctaComponent: ContactRequestCta {
        isOutgoingRequest: root.isOutgoingMessage
        pending: root.pending
        accepted: root.accepted
        dismissed: root.dismissed
        blocked: contactDetails && contactDetails.isBlocked
        onAcceptClicked: root.store.contactsStore.acceptContactRequest(root.contactId, root.contactRequestId)
        onDeclineClicked: root.store.contactsStore.dismissContactRequest(root.contactId, root.contactRequestId)
        onProfileClicked: Global.openProfilePopup(root.contactId)
        onBlockClicked: {
            root.store.contactsStore.dismissContactRequest(root.contactId, root.contactRequestId)
            root.store.contactsStore.blockContact(root.contactId)
        }
        onDetailsClicked: {
            Global.openReviewContactRequestPopup(root.contactId, null)
        }
    }

    onMessageClicked: {
        root.openProfilePopup()
    }
}
