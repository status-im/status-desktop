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

    readonly property bool isOutgoingRequest: notification && notification.message.senderId === root.store.contactsStore.myPublicKey
    readonly property string contactId: notification ? isOutgoingRequest ? notification.chatId : notification.author : ""
    readonly property var contactDetails: notification ? Utils.getContactDetailsAsJson(contactId, false) : null

    messageDetails.messageText: {
        if (!notification)
            return ""

        return root.isOutgoingRequest ? notification.repliedMessage.messageText : notification.message.messageText
    }
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