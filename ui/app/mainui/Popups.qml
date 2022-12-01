import QtQuick 2.14

import AppLayouts.Chat.popups 1.0
import shared.popups 1.0

import utils 1.0

QtObject {
    id: root

    /* required */ property var rootStore

    function openSendIDRequestPopup(publicKey, cb) {
        const contactDetails = Utils.getContactDetailsAsJson(publicKey, false)
        const popup = Global.openPopup(sendIDRequestPopupComponent, {
            userPublicKey: publicKey,
            userDisplayName: contactDetails.displayName,
            userIcon: contactDetails.largeImage,
            userIsEnsVerified: contactDetails.ensVerified,
            "header.title": qsTr("Verify %1's Identity").arg(contactDetails.displayName),
            challengeText: qsTr("Ask a question that only the real %1 will be able to answer e.g. a question about a shared experience, or ask %1 to enter a code or phrase you have sent to them via a different communication channel (phone, post, etc...).").arg(contactDetails.displayName),
            buttonText: qsTr("Send verification request")
        })
        if (cb)
            cb(popup)
    }

    function openOutgoingIDRequestPopup(publicKey, cb) {
        try {
            const verificationDetails = root.rootStore.profileSectionStore.contactsStore.getSentVerificationDetailsAsJson(publicKey)
            const popupProperties = {
                userPublicKey: publicKey,
                verificationStatus: verificationDetails.requestStatus,
                verificationChallenge: verificationDetails.challenge,
                verificationResponse: verificationDetails.response,
                verificationResponseDisplayName: verificationDetails.displayName,
                verificationResponseIcon: verificationDetails.icon,
                verificationRequestedAt: verificationDetails.requestedAt,
                verificationRepliedAt: verificationDetails.repliedAt
            }
            const popup = Global.openPopup(contactOutgoingVerificationRequestPopupComponent, popupProperties)
            if (cb)
                cb(popup)
        } catch (e) {
            console.error("Error getting or parsing verification data", e)
        }
    }

    function openIncomingIDRequestPopup(publicKey, cb) {
        try {
            const request = root.rootStore.profileSectionStore.contactsStore.getVerificationDetailsFromAsJson(publicKey)
            const popupProperties = {
                senderPublicKey: request.from,
                senderDisplayName: request.displayName,
                senderIcon: request.icon,
                challengeText: request.challenge,
                responseText: request.response,
                messageTimestamp: request.requestedAt,
                responseTimestamp: request.repliedAt
            }

            const popup = Global.openPopup(contactVerificationRequestPopupComponent, popupProperties)
            if (cb)
                cb(popup)
        } catch (e) {
            console.error("Error getting or parsing verification data", e)
        }
    }

    function openInviteFriendsToCommunityPopup(community, communitySectionModule, cb) {
        const popup = Global.openPopup(inviteFriendsToCommunityPopup, { community, communitySectionModule })
        if (cb)
            cb(popup)
    }

    function openContactRequestPopup(publicKey, cb) {
        const contactDetails = Utils.getContactDetailsAsJson(publicKey, false)
        const popupProperties = {
            userPublicKey: publicKey,
            userDisplayName: contactDetails.displayName,
            userIcon: contactDetails.largeImage,
            userIsEnsVerified: contactDetails.ensVerified
        }

        const popup = Global.openPopup(sendContactRequestPopupComponent, popupProperties)
        if (cb)
            cb(popup)
    }

    readonly property list<Component> _d: [
        Component {
            id: contactVerificationRequestPopupComponent
            ContactVerificationRequestPopup {
                onResponseSent: {
                    root.rootStore.profileSectionStore.contactsStore.acceptVerificationRequest(senderPublicKey, response)
                }
                onVerificationRefused: {
                    root.rootStore.profileSectionStore.contactsStore.declineVerificationRequest(senderPublicKey)
                }
                onClosed: destroy()
            }
        },

        Component {
            id: contactOutgoingVerificationRequestPopupComponent
            OutgoingContactVerificationRequestPopup {
                onVerificationRequestCanceled: {
                    root.rootStore.profileSectionStore.contactsStore.cancelVerificationRequest(userPublicKey)
                }
                onUntrustworthyVerified: {
                    root.rootStore.profileSectionStore.contactsStore.verifiedUntrustworthy(userPublicKey)
                }
                onTrustedVerified: {
                    root.rootStore.profileSectionStore.contactsStore.verifiedTrusted(userPublicKey)
                }
                onClosed: destroy()
            }
        },

        Component {
            id: sendIDRequestPopupComponent
            SendContactRequestModal {
                anchors.centerIn: parent
                onAccepted: root.rootStore.profileSectionStore.contactsStore.sendVerificationRequest(userPublicKey, message)
                onClosed: destroy()
            }
        },

        Component {
            id: inviteFriendsToCommunityPopup

            InviteFriendsToCommunityPopup {
                anchors.centerIn: parent
                rootStore: root.rootStore
                contactsStore: root.rootStore.contactStore
                onClosed: destroy()
            }
        },

        Component {
            id: sendContactRequestPopupComponent

            SendContactRequestModal {
                anchors.centerIn: parent
                onAccepted: root.rootStore.profileSectionStore.contactsStore.sendContactRequest(userPublicKey, message)
                onClosed: destroy()
            }
        }
    ]
}
