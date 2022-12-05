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

    maximumLineCount: 5

    ctaComponent: ContactRequestCta {
        readonly property string senderId: notification ? notification.message.senderId : ""
        readonly property var contactDetails: notification ?
                        Utils.getContactDetailsAsJson(notification.message.senderId, false) :
                        null

        pending: notification && notification.message.contactRequestState === Constants.contactRequestStatePending
        accepted: notification && notification.message.contactRequestState === Constants.contactRequestStateAccepted
        dismissed: notification && notification.message.contactRequestState === Constants.contactRequestStateDismissed
        blocked: contactDetails && contactDetails.isBlocked
        onAcceptClicked: root.store.contactsStore.acceptContactRequest(senderId)
        onDeclineClicked: root.store.contactsStore.dismissContactRequest(senderId)
        onProfileClicked: Global.openProfilePopup(senderId)
        onBlockClicked: {
            root.store.contactsStore.dismissContactRequest(senderId)
            root.store.contactsStore.blockContact(senderId)
        }
        onDetailsClicked: {
            Global.openPopup(reviewContactRequestPopupComponent,
                             {
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
            onAccepted: root.store.contactsStore.acceptContactRequest(notification.message.senderId)
            onDeclined: root.store.contactsStore.dismissContactRequest(notification.message.senderId)
        }
    }
}
