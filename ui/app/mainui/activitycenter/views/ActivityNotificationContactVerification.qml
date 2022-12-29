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

    messageDetails.messageText: {
        if (!notification)
            return ""

        return root.isOutgoingRequest ? notification.repliedMessage.messageText : notification.message.messageText
    }

    messageSubheaderComponent: StatusBaseText {
        text: {
            if (!notification)
                return ""

            if (root.isOutgoingRequest) {
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

    ctaComponent: isOutgoingRequest ? outgoingContactVerificationCta : incomingContactVerificationCta

    Component {
        id: outgoingContactVerificationCta

        OutgoingContactVerificationCta {
            verificationStatus: notification ? notification.verificationStatus : Constants.verificationStatus.unverified
            onActivate: {
                Global.openOutgoingIDRequestPopup(root.contactId, popup => {})
                root.closeActivityCenter()
            }
        }
    }

    Component {
        id: incomingContactVerificationCta

        IncomingContactVerificationCta {
            verificationStatus: notification ? notification.verificationStatus : Constants.verificationStatus.unverified
            onActivate: {
                Global.openIncomingIDRequestPopup(root.contactId, popup => {})
                root.closeActivityCenter()
            }
        }
    }
}