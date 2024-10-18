import QtQuick 2.13
import utils 1.0

import StatusQ 0.1

QtObject {
    id: root

    property var contactsModule

    property var globalUtilsInst: globalUtils
    property var mainModuleInst: Global.appIsReady? mainModule : null

    property string myPublicKey: userProfile.pubKey

    // contactsModel holds all available contacts
    property var contactsModel: contactsModule.contactsModel
    property var myContactsModel: contactsModule.myMutualContactsModel
    property var blockedContactsModel: contactsModule.blockedContactsModel
    property var receivedContactRequestsModel: contactsModule.receivedContactRequestsModel
    property var sentContactRequestsModel: contactsModule.sentContactRequestsModel

    readonly property var showcasePublicKey: contactsModule.showcasePublicKey

    // Showcase models for a contact with showcasePublicKey
    readonly property var showcaseContactCommunitiesModel: contactsModule.showcaseContactCommunitiesModel
    readonly property var showcaseContactAccountsModel: contactsModule.showcaseContactAccountsModel
    readonly property var showcaseContactCollectiblesModel: contactsModule.showcaseContactCollectiblesModel
    readonly property var showcaseContactAssetsModel: contactsModule.showcaseContactAssetsModel
    readonly property var showcaseContactSocialLinksModel: contactsModule.showcaseContactSocialLinksModel

    readonly property bool isShowcaseForAContactLoading: contactsModule.showcaseForAContactLoading

    // Support models for showcase for a contact with showcasePublicKey
    readonly property var showcaseCollectiblesModel: contactsModule.showcaseCollectiblesModel

    // Sets showcasePublicKey and updates showcase models with corresponding data
    function requestProfileShowcase(publicKey) {
        root.contactsModule.requestProfileShowcase(publicKey)
    }

    // Temporary commented until we provide appropriate flags on the `status-go` side to cover all sections.
//    property var receivedButRejectedContactRequestsModel: contactsModule.receivedButRejectedContactRequestsModel
//    property var sentButRejectedContactRequestsModel: contactsModule.sentButRejectedContactRequestsModel

    function resolveENS(value) {
        root.mainModuleInst.resolveENS(value, "")
    }

    function generateAlias(pubKey) {
        return root.globalUtilsInst.generateAlias(pubKey)
    }

    function isMyMutualContact(pubKey) {
        return root.contactsModule.isMyMutualContact(pubKey)
    }

    function isBlockedContact(pubKey) {
        return root.contactsModule.isBlockedContact(pubKey)
    }

    function hasPendingContactRequest(pubKey) {
        return root.contactsModule.hasPendingContactRequest(pubKey)
    }

    function joinPrivateChat(pubKey) {
        Global.changeAppSectionBySectionType(Constants.appSection.chat)
        root.contactsModule.switchToOrCreateOneToOneChat(pubKey)
    }

    function unblockContact(pubKey) {
        root.contactsModule.unblockContact(pubKey)
    }

    function blockContact(pubKey) {
        root.contactsModule.blockContact(pubKey)
    }

    function removeContact(pubKey) {
        root.contactsModule.removeContact(pubKey)
    }

    function changeContactNickname(pubKey, nickname, displayName, isEdit) {
        root.contactsModule.changeContactNickname(pubKey, nickname)

        let message = ""
        if (nickname === "") { // removed nickname
            message = qsTr("Nickname for %1 removed").arg(displayName)
        } else {
            if (isEdit)
                message = qsTr("Nickname for %1 changed").arg(displayName) // changed nickname
            else
                message = qsTr("Nickname for %1 added").arg(displayName) // added a new nickname
        }
        if (!!message) {
            Global.displaySuccessToastMessage(message)
        }
    }

    function sendContactRequest(pubKey, message) {
        root.contactsModule.sendContactRequest(pubKey, message)
        Global.displaySuccessToastMessage(qsTr("Contact request sent"))
    }

    function acceptContactRequest(pubKey, contactRequestId) {
        root.contactsModule.acceptContactRequest(pubKey, contactRequestId)
    }

    function dismissContactRequest(pubKey, contactRequestId) {
        root.contactsModule.dismissContactRequest(pubKey, contactRequestId)
    }

    function getLatestContactRequestForContactAsJson(pubKey) {
        let resp = root.contactsModule.getLatestContactRequestForContactAsJson(pubKey)
        return JSON.parse(resp)
    }

    function markAsTrusted(pubKey) {
        root.contactsModule.markAsTrusted(pubKey)
    }

    function markUntrustworthy(pubKey) {
        root.contactsModule.markUntrustworthy(pubKey)
    }

    function removeTrustStatus(pubKey) {
        root.contactsModule.removeTrustStatus(pubKey)
    }

    function requestContactInfo(publicKey) {
        root.contactsModule.requestContactInfo(publicKey)
    }

    function getContactPublicKeyByAddress(address) {
        return "" // TODO retrive contact public key from address
    }

    function getLinkToProfile(publicKey) {
        return root.contactsModule.shareUserUrlWithData(publicKey)
    }
    function getProfileContext(publicKey, isBridgedAccount = false) {
        const contactDetails = Utils.getContactDetailsAsJson(publicKey, true, true)
        if (!contactDetails)
            return {
                profileType: getProfileType(publicKey, isBridgedAccount, false),
                trustStatus: Constants.trustStatus.unknown,
                contactType: getContactType(Constants.ContactRequestState.None, false),
                ensVerified: false,
                onlineStatus: Constants.onlineStatus.unknown,
                hasLocalNickname: false
            }

        const isBlocked = contactDetails.isBlocked
        const profileType = getProfileType(publicKey, isBridgedAccount, isBlocked)
        const contactType = getContactType(contactDetails.contactRequestState, contactDetails.isContact)
        const trustStatus = contactDetails.trustStatus
        const ensVerified = contactDetails.ensVerified
        const onlineStatus = contactDetails.onlineStatus
        const hasLocalNickname = !!contactDetails.localNickname

        return { profileType, trustStatus, contactType, ensVerified, onlineStatus, hasLocalNickname }
    }

    function getProfileType(publicKey, isBridgedAccount, isBlocked) {
        if (publicKey === root.myPublicKey) return Constants.profileType.self
        if (isBridgedAccount) return Constants.profileType.bridged
        if (isBlocked) return Constants.profileType.blocked
        return Constants.profileType.regular
    }

    function getContactType(contactRequestState, isContact) {
        switch (contactRequestState) {
            case Constants.ContactRequestState.Received:
                return Constants.contactType.contactRequestReceived
            case Constants.ContactRequestState.Sent:
                return Constants.contactType.contactRequestSent
            default:
                return isContact ? Constants.contactType.contact : Constants.contactType.nonContact
        }
    }
}
