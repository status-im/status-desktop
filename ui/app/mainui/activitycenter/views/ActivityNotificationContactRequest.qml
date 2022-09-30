import QtQuick 2.14
import QtQuick.Layouts 1.14

import StatusQ.Core 0.1
import StatusQ.Core.Theme 0.1
import StatusQ.Components 0.1

import shared 1.0
import shared.panels 1.0
import utils 1.0

import "../panels"

ActivityNotificationMessage {
    id: root

    ctaComponent: ContactRequestCta {
        readonly property string senderId: notification.message.senderId
        readonly property var contactDetails: Utils.getContactDetailsAsJson(senderId)

        pending: notification.message.contactRequestState == Constants.contactRequestStatePending
        accepted: notification.message.contactRequestState == Constants.contactRequestStateAccepted
        dismissed: notification.message.contactRequestState == Constants.contactRequestStateDismissed
        blocked: contactDetails.isBlocked
        onAcceptClicked: root.store.contactsStore.acceptContactRequest(senderId)
        onDeclineClicked: root.store.contactsStore.dismissContactRequest(senderId)
        onProfileClicked: Global.openProfilePopup(senderId)
        onBlockClicked: {
            root.store.contactsStore.dismissContactRequest(senderId)
            root.store.contactsStore.blockContact(senderId)
        }
    }
}