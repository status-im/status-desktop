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

    readonly property bool pending: notification && notification.message.contactRequestState === Constants.contactRequestStatePending
    readonly property bool accepted: notification && notification.message.contactRequestState === Constants.contactRequestStateAccepted
    readonly property bool dismissed: notification && notification.message.contactRequestState === Constants.contactRequestStateDismissed

    Connections {
        target: root.isOutgoingMessage ? root.store.contactsStore.sentContactRequestsModel :
                                         root.store.contactsStore.receivedContactRequestsModel

        function onItemChanged(pubKey) {
            if (pubKey === root.contactId)
                root.updateContactDetails()
        }
    }

    maximumLineCount: 5
    messageDetails.messageText: !root.isOutgoingMessage && notification ? notification.message.messageText : ""

    messageSubheaderComponent: StatusBaseText {
        text: root.isOutgoingMessage ? qsTr("Сontact request sent to %1").arg(contactName) :
                                       qsTr("Сontact request:")
        font.italic: true
        font.pixelSize: 15
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
                timestamp: notification ? notification.timestamp : 0
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
