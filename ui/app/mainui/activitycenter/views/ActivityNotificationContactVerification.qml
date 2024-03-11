import QtQuick 2.14
import QtQuick.Layouts 1.14

import StatusQ.Core 0.1
import StatusQ.Core.Theme 0.1
import StatusQ.Core.Utils 0.1 as CoreUtils
import StatusQ.Components 0.1

import shared 1.0
import shared.panels 1.0
import utils 1.0

import "../panels"

ActivityNotificationMessage {
    id: root

    Connections {
        target: root.isOutgoingMessage ? root.store.contactsStore.sentContactRequestsModel :
                                         root.store.contactsStore.receivedContactRequestsModel

        function onItemChanged(pubKey) {
            if (pubKey === root.contactId)
                root.updateContactDetails()
        }
    }

    messageDetails.messageText: {
        if (!notification)
            return ""

        return root.isOutgoingMessage ? notification.repliedMessage.messageText : notification.message.messageText
    }

    messageSubheaderComponent: StatusBaseText {
        text: {
            if (!notification)
                return ""

            if (root.isOutgoingMessage) {
                return qsTr("To verify their identity you asked: %1").arg(CoreUtils.Utils.stripHtmlTags(notification.message.messageText))
            }

            return qsTr("Identity Verification Question:")
        }
        wrapMode: Text.Wrap
        color: Theme.palette.baseColor1
        font.weight: Font.Medium
        font.italic: true
        font.pixelSize: 15
    }

    ctaComponent: isOutgoingMessage ? outgoingContactVerificationCta : incomingContactVerificationCta

    onMessageClicked: {
        root.openProfilePopup()
    }

    Component {
        id: outgoingContactVerificationCta

        OutgoingContactVerificationCta {
            verificationStatus: notification ? notification.verificationStatus : Constants.verificationStatus.unverified
            onActivate: {
                Global.openOutgoingIDRequestPopup(root.contactId, root.contactDetails, null)
                root.closeActivityCenter()
            }
        }
    }

    Component {
        id: incomingContactVerificationCta

        IncomingContactVerificationCta {
            verificationStatus: notification ? notification.verificationStatus : Constants.verificationStatus.unverified
            onActivate: {
                Global.openIncomingIDRequestPopup(root.contactId, root.contactDetails, null)
                root.closeActivityCenter()
            }
        }
    }
}
