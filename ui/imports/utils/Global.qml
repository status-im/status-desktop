pragma Singleton

import QtQuick 2.13
import AppLayouts.Chat.popups 1.0

import shared.popups 1.0

Item {
    id: root

    property var applicationWindow
    property var appMain
    property var dragArea
    property bool popupOpened: false
    property int settingsSubsection: Constants.settingsSubsection.profile

    property var mainModuleInst
    property var privacyModuleInst
    property var toastMessage
    property var pinnedMessagesPopup
    property var communityProfilePopup
    property bool profilePopupOpened: false

    property bool activityCenterPopupOpened: false

    property var sendMessageSound
    property var notificationSound
    property var errorSound

    signal openImagePopup(var image, var contextMenu)
    signal openLinkInBrowser(string link)
    signal openChooseBrowserPopup(string link)
    signal openDownloadModalRequested(bool available, string version, string url)
    signal settingsLoaded()
    signal openBackUpSeedPopup()
    signal openCreateChatView()
    signal closeCreateChatView()

    signal openProfilePopupRequested(string publicKey, var parentPopup)

    signal openNicknamePopupRequested(string publicKey, string nickname, string subtitle)
    signal nickNameChanged(string publicKey, string nickname)

    signal blockContactRequested(string publicKey, string contactName)
    signal contactBlocked(string publicKey)
    signal unblockContactRequested(string publicKey, string contactName)
    signal contactUnblocked(string publicKey)

    signal openChangeProfilePicPopup()
    signal displayToastMessage(string title, string subTitle, string icon, bool loading, int ephNotifType, string url)
    signal openEditDisplayNamePopup()
    signal openActivityCenterPopupRequested

    function openContactRequestPopup(publicKey) {
        const contactDetails = Utils.getContactDetailsAsJson(publicKey);
        return openPopup(sendContactRequestPopupComponent, {
            userPublicKey: publicKey,
            userDisplayName: contactDetails.displayName,
            userIcon: contactDetails.largeImage,
            userIsEnsVerified: contactDetails.ensVerified
        })
    }

    function openInviteFriendsToCommunityPopup(community, communitySectionModule) {
        return openPopup(inviteFriendsToCommunityPopup, {
                             community,
                             communitySectionModule
                         })
    }

    function openSendIDRequestPopup(publicKey) {
        const contactDetails = Utils.getContactDetailsAsJson(publicKey);
        return openPopup(sendIDRequestPopupComponent, {
            userPublicKey: publicKey,
            userDisplayName: contactDetails.displayName,
            userIcon: contactDetails.largeImage,
            userIsEnsVerified: contactDetails.ensVerified,
            "header.title": qsTr("Verify %1's Identity").arg(contactDetails.displayName),
            challengeText: qsTr("Ask a question that only the real %1 will be able to answer e.g. a question about a shared experience, or ask %1 to enter a code or phrase you have sent to them via a different communication channel (phone, post, etc...).").arg(contactDetails.displayName),
            buttonText: qsTr("Send verification request")
        })
    }

    function openIncomingIDRequestPopup(publicKey) {
        try {
            const request = appMain.rootStore.profileSectionStore.contactsStore.getVerificationDetailsFromAsJson(publicKey)
            return openPopup(contactVerificationRequestPopupComponent, {
                                 senderPublicKey: request.from,
                                 senderDisplayName: request.displayName,
                                 senderIcon: request.icon,
                                 challengeText: request.challenge,
                                 responseText: request.response,
                                 messageTimestamp: request.requestedAt,
                                 responseTimestamp: request.repliedAt
                             })
        } catch (e) {
            console.error("Error getting or parsing verification data", e)
        }
    }

    function openOutgoingIDRequestPopup(publicKey) {
        try {
            const verificationDetails = appMain.rootStore.profileSectionStore.contactsStore.getSentVerificationDetailsAsJson(publicKey)
            return openPopup(contactOutgoingVerificationRequestPopupComponent, {
                                 userPublicKey: publicKey,
                                 verificationStatus: verificationDetails.requestStatus,
                                 verificationChallenge: verificationDetails.challenge,
                                 verificationResponse: verificationDetails.response,
                                 verificationResponseDisplayName: verificationDetails.displayName,
                                 verificationResponseIcon: verificationDetails.icon,
                                 verificationRequestedAt: verificationDetails.requestedAt,
                                 verificationRepliedAt: verificationDetails.repliedAt
                             })
        } catch (e) {
            console.error("Error getting or parsing verification data", e)
        }
    }

    function openProfilePopup(publicKey, parentPopup) {
        openProfilePopupRequested(publicKey, parentPopup)
    }

    function openActivityCenterPopup() {
        openActivityCenterPopupRequested()
    }

    function openPopup(popupComponent, params = {}) {
        const popup = popupComponent.createObject(root.appMain, params);
        popup.open();
        return popup;
    }

    function openDownloadModal(available, version, url){
        openDownloadModalRequested(available, version, url);
    }

    function changeAppSectionBySectionType(sectionType, subsection = 0) {
        if(!root.mainModuleInst)
            return

        mainModuleInst.setActiveSectionBySectionType(sectionType)
        if (sectionType === Constants.appSection.profile) {
            settingsSubsection = subsection;
        }
    }

    function setNthEnabledSectionActive(nthSection) {
        if(!root.mainModuleInst)
            return
        mainModuleInst.setNthEnabledSectionActive(nthSection)
    }

    function getProfileImage(pubkey, isCurrentUser, useLargeImage) {
        if (isCurrentUser || (isCurrentUser === undefined && pubkey === userProfile.pubKey)) {
            return userProfile.icon;
        }

        let contactDetails = Utils.getContactDetailsAsJson(pubkey)
        return contactDetails.displayIcon
    }

    function openLink(link) {
        // Qt sometimes inserts random HTML tags; and this will break on invalid URL inside QDesktopServices::openUrl(link)
        link = globalUtils.plainText(link);
        if (localAccountSensitiveSettings.showBrowserSelector) {
            openChooseBrowserPopup(link);
        } else {
            if (localAccountSensitiveSettings.openLinksInStatus) {
                changeAppSectionBySectionType(Constants.appSection.browser);
                openLinkInBrowser(link);
            } else {
                Qt.openUrlExternally(link);
            }
        }
    }

    function playErrorSound() {
        if(errorSound)
            errorSound.play();
    }

    Component {
        id: sendContactRequestPopupComponent

        SendContactRequestModal {
            anchors.centerIn: parent
            onAccepted: appMain.rootStore.profileSectionStore.contactsStore.sendContactRequest(userPublicKey, message)
            onClosed: destroy()
        }
    }

    Component {
        id: inviteFriendsToCommunityPopup

        InviteFriendsToCommunityPopup {
            anchors.centerIn: parent
            rootStore: appMain.rootStore
            contactsStore: appMain.rootStore.contactStore
            onClosed: destroy()
        }
    }

    Component {
        id: sendIDRequestPopupComponent
        SendContactRequestModal {
            anchors.centerIn: parent
            onAccepted: appMain.rootStore.profileSectionStore.contactsStore.sendVerificationRequest(userPublicKey, message)
            onClosed: destroy()
        }
    }

    Component {
        id: contactVerificationRequestPopupComponent
        ContactVerificationRequestPopup {
            onResponseSent: {
                appMain.rootStore.profileSectionStore.contactsStore.acceptVerificationRequest(senderPublicKey, response)
            }
            onVerificationRefused: {
                appMain.rootStore.profileSectionStore.contactsStore.declineVerificationRequest(senderPublicKey)
            }
            onClosed: destroy()
        }
    }

    Component {
        id: contactOutgoingVerificationRequestPopupComponent
        OutgoingContactVerificationRequestPopup {
            onVerificationRequestCanceled: {
                appMain.rootStore.profileSectionStore.contactsStore.cancelVerificationRequest(userPublicKey)
            }
            onUntrustworthyVerified: {
                appMain.rootStore.profileSectionStore.contactsStore.verifiedUntrustworthy(userPublicKey)
            }
            onTrustedVerified: {
                appMain.rootStore.profileSectionStore.contactsStore.verifiedTrusted(userPublicKey)
            }
            onClosed: destroy()
        }
    }
}
