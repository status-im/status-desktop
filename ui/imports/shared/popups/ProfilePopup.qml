import QtQuick 2.13
import QtQuick.Controls 2.13
import QtQuick.Layouts 1.13
import QtQml.Models 2.14
import QtGraphicalEffects 1.13

import utils 1.0
import shared 1.0
import shared.popups 1.0
import shared.stores 1.0
import shared.views 1.0 as SharedViews
import shared.controls.chat 1.0
import shared.panels 1.0

import StatusQ.Core 0.1
import StatusQ.Core.Theme 0.1
import StatusQ.Components 0.1
import StatusQ.Controls 0.1
import StatusQ.Popups.Dialog 0.1

StatusDialog {
    id: popup

    property Popup parentPopup

    property var profileStore
    property var contactsStore

    property string userPublicKey: ""
    property string userDisplayName: ""
    property string userName: ""
    property string userNickname: ""
    property string userEnsName: ""
    property string userIcon: ""
    property string userBio: ""
    property string userSocialLinks: ""
    property int userTrustStatus: Constants.trustStatus.unknown
    property int outgoingVerificationStatus: Constants.verificationStatus.unverified
    property int incomingVerificationStatus: Constants.verificationStatus.unverified
    property string text: ""
    property string challenge: ""
    property string response: ""

    property bool userIsEnsVerified: false
    property bool userIsBlocked: false
    property bool userIsUntrustworthy: false
    property bool userTrustIsUnknown: false
    property bool isCurrentUser: false
    property bool isAddedContact: false
    property bool isContact: false
    property bool isVerificationSent: false
    property bool isVerified: false
    property bool isTrusted: false
    property bool hasReceivedVerificationRequest: false

    property bool showRemoveVerified: false
    property bool showVerifyIdentitySection: false
    property bool showVerificationPendingSection: false
    property bool showIdentityVerified: false
    property bool showIdentityVerifiedUntrustworthy: false

    property string verificationChallenge: ""
    property string verificationResponse: ""
    property string verificationResponseDisplayName: ""
    property string verificationResponseIcon: ""
    property string verificationRequestedAt: ""
    property string verificationRepliedAt: ""

    signal blockButtonClicked(name: string, address: string)
    signal unblockButtonClicked(name: string, address: string)
    signal removeButtonClicked(address: string)

    signal contactUnblocked(publicKey: string)
    signal contactBlocked(publicKey: string)

    function openPopup(publicKey, state = "") {
        // All this should be improved more, but for now we leave it like this.
        const contactDetails = Utils.getContactDetailsAsJson(publicKey);

        isCurrentUser = popup.profileStore.pubkey === publicKey;

        userPublicKey = publicKey;
        userDisplayName = isCurrentUser ? Qt.binding(() => { return popup.profileStore.displayName }) : contactDetails.displayName;
        userName = contactDetails.alias;
        userNickname = contactDetails.localNickname;
        userEnsName = contactDetails.name;
        userIcon = contactDetails.largeImage;
        userBio = contactDetails.bio;
        userSocialLinks = contactDetails.socialLinks;
        userIsEnsVerified = contactDetails.ensVerified;
        userIsBlocked = contactDetails.isBlocked;
        isAddedContact = contactDetails.isAdded;
        isContact = contactDetails.isContact
        userTrustStatus = contactDetails.trustStatus
        userTrustIsUnknown = contactDetails.trustStatus === Constants.trustStatus.unknown
        userIsUntrustworthy = contactDetails.trustStatus === Constants.trustStatus.untrustworthy
        outgoingVerificationStatus = contactDetails.verificationStatus
        incomingVerificationStatus = contactDetails.incomingVerificationStatus
        isVerificationSent = outgoingVerificationStatus !== Constants.verificationStatus.unverified

        if (isContact && popup.contactsStore.hasReceivedVerificationRequestFrom(publicKey)) {
            popup.hasReceivedVerificationRequest = true
        }

        if(isContact && isVerificationSent) {
            let verificationDetails = popup.contactsStore.getSentVerificationDetailsAsJson(publicKey);

            outgoingVerificationStatus = verificationDetails.requestStatus;
            verificationChallenge = verificationDetails.challenge;
            verificationResponse = verificationDetails.response;
            verificationResponseDisplayName = verificationDetails.displayName;
            verificationResponseIcon = verificationDetails.icon;
            verificationRequestedAt = verificationDetails.requestedAt;
            verificationRepliedAt = verificationDetails.repliedAt;
        }
        isTrusted = outgoingVerificationStatus === Constants.verificationStatus.trusted
            || incomingVerificationStatus === Constants.verificationStatus.trusted
        isVerified = outgoingVerificationStatus === Constants.verificationStatus.verified

        text = ""; // this is most likely unneeded

        popup.open();

        if (state === Constants.profilePopupStates.openNickname) {
            profileView.nicknamePopup.open();
        } else if (state === Constants.profilePopupStates.contactRequest) {
            d.openContactRequestPopup()
        } else if (state === Constants.profilePopupStates.blockUser) {
            blockUser();
        } else if (state === Constants.profilePopupStates.unblockUser) {
            unblockUser();
        } else if (state === Constants.profilePopupStates.verifyIdentity) {
            showVerifyIdentitySection = true;
        } else if (state === Constants.profilePopupStates.respondToPendingRequest) {
            popup.openPendingRequestPopup()
        } else if (state === Constants.profilePopupStates.showVerificationPendingSection) {
            popup.showVerificationPendingSection = true
            profileView.wizardAnimation.running = true
        }
    }

    function blockUser() {
        profileView.blockContactConfirmationDialog.contactName = userDisplayName;
        profileView.blockContactConfirmationDialog.contactAddress = userPublicKey;
        profileView.blockContactConfirmationDialog.open();
    }

    function unblockUser() {
        profileView.unblockContactConfirmationDialog.contactName = userDisplayName;
        profileView.unblockContactConfirmationDialog.contactAddress = userPublicKey;
        profileView.unblockContactConfirmationDialog.open();
    }

    function openPendingRequestPopup() {
        try {
            let request = popup.contactsStore.getVerificationDetailsFromAsJson(popup.userPublicKey)
            Global.openPopup(contactVerificationRequestPopupComponent, {
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

    QtObject {
        id: d

        function openContactRequestPopup() {
            let contactRequestPopup = Global.openContactRequestPopup(popup.userPublicKey)
            contactRequestPopup.closed.connect(popup.close)
        }
    }

    width: 700
    padding: 8

    header: StatusDialogHeader {
        id: dialogHeader
        headline.title: {
            if(showVerifyIdentitySection || showVerificationPendingSection){
                return qsTr("Verify %1's Identity").arg(userDisplayName)
            }
            return popup.isCurrentUser ? qsTr("My Profile") :
                                         qsTr("%1's Profile").arg(userDisplayName)
        }

        headline.subtitle: popup.isCurrentUser ? "" : Utils.getElidedCompressedPk(userPublicKey)

        actions {
            customButtons: ObjectModel {
                StatusFlatRoundButton {
                    type: StatusFlatRoundButton.Type.Secondary
                    width: 32
                    height: 32

                    icon.width: 20
                    icon.height: 20
                    icon.name: "qr"
                    onClicked: profileView.qrCodePopup.open()
                }
            }

            closeButton.onClicked: popup.close()
        }
    }

    footer: StatusDialogFooter {
        visible: !popup.isCurrentUser

        leftButtons: ObjectModel {
            StatusButton {
                text: qsTr("Cancel verification")
                visible: !isVerified && isContact && isVerificationSent && showVerificationPendingSection
                onClicked: {
                    popup.contactsStore.cancelVerificationRequest(userPublicKey);
                    popup.close()
                }
            }
        }

        rightButtons: ObjectModel {
            StatusFlatButton {
                text: userIsBlocked ?
                    qsTr("Unblock User") :
                    qsTr("Block User")
                type: StatusBaseButton.Type.Danger
                visible: !isAddedContact
                onClicked: userIsBlocked ? unblockUser() : blockUser()
            }

            StatusFlatButton {
                visible:  !showRemoveVerified && !showIdentityVerified && !showVerifyIdentitySection && !showVerificationPendingSection && !userIsBlocked && isAddedContact
                type: StatusBaseButton.Type.Danger
                text: qsTr('Remove Contact')
                onClicked: {
                    profileView.removeContactConfirmationDialog.parentPopup = popup;
                    profileView.removeContactConfirmationDialog.open();
                }
            }

            StatusButton {
                text: qsTr("Send Contact Request")
                visible: !userIsBlocked && !isAddedContact
                onClicked: d.openContactRequestPopup()
            }

            StatusButton {
                text: qsTr("Mark Untrustworthy")
                visible: !showIdentityVerifiedUntrustworthy && !showIdentityVerified && !showVerifyIdentitySection && userTrustIsUnknown
                enabled: !showVerificationPendingSection || verificationResponse !== ""
                type: StatusBaseButton.Type.Danger
                onClicked: {
                    if (showVerificationPendingSection) {
                        popup.showIdentityVerified = false;
                        popup.showIdentityVerifiedUntrustworthy = true;
                        popup.showVerificationPendingSection = false;
                        popup.showVerifyIdentitySection = false;
                        profileView.stepsListModel.setProperty(2, "stepCompleted", true);
                        popup.contactsStore.verifiedUntrustworthy(userPublicKey);
                    } else {
                        popup.contactsStore.markUntrustworthy(userPublicKey);
                        popup.close();
                    }
                }
            }

            StatusButton {
                text: qsTr("Remove 'Identity Verified' status")
                visible: isTrusted && !showIdentityVerified && !showRemoveVerified
                type: StatusBaseButton.Type.Danger
                onClicked: {
                    showRemoveVerified = true
                }
            }

            StatusButton {
                text: qsTr("No")
                visible: showRemoveVerified
                type: StatusBaseButton.Type.Danger
                onClicked: {
                    showRemoveVerified = false
                }
            }

            StatusButton {
                text: qsTr("Yes")
                visible: showRemoveVerified
                onClicked: {
                    popup.contactsStore.removeTrustStatus(userPublicKey);
                    popup.close();
                }
            }

            StatusButton {
                text: qsTr("Remove Untrustworthy Mark")
                visible: userIsUntrustworthy
                onClicked: {
                    popup.contactsStore.removeTrustStatus(userPublicKey);
                    popup.close();
                }
            }

            StatusButton {
                text: qsTr("Verify Identity")
                visible: !showIdentityVerifiedUntrustworthy && !showIdentityVerified &&
                    !showVerifyIdentitySection && isContact  && !isVerificationSent
                    && !hasReceivedVerificationRequest
                onClicked: {
                    popup.showVerifyIdentitySection = true
                }
            }

            StatusButton {
                text: qsTr("Verify Identity pending...")
                visible: (!showIdentityVerifiedUntrustworthy && !showIdentityVerified && !isTrusted
                    && isContact && isVerificationSent && !showVerificationPendingSection) ||
                    (hasReceivedVerificationRequest && !isTrusted)
                onClicked: {
                    if (hasReceivedVerificationRequest) {
                        popup.openPendingRequestPopup()
                    } else {
                        popup.showVerificationPendingSection = true
                        profileView.wizardAnimation.running = true
                    }
                }
            }

            StatusButton {
                text: qsTr("Send verification request")
                visible: showVerifyIdentitySection && isContact  && !isVerificationSent
                onClicked: {
                    popup.contactsStore.sendVerificationRequest(userPublicKey, Utils.escapeHtml(profileView.challengeTxt.input.text));
                    profileView.stepsListModel.setProperty(1, "stepCompleted", true);
                    Global.displayToastMessage(qsTr("Verification request sent"),
                                           "",
                                           "checkmark-circle",
                                           false,
                                           Constants.ephemeralNotificationType.normal,
                                           "");
                    popup.close();
                }
            }

            StatusButton {
                text: qsTr("Confirm Identity")
                visible: isContact  && isVerificationSent && !isTrusted && showVerificationPendingSection
                enabled: verificationChallenge !== "" && verificationResponse !== ""
                onClicked: {
                    popup.showIdentityVerified = true;
                    popup.showIdentityVerifiedUntrustworthy = false;
                    popup.showVerificationPendingSection = false;
                    popup.showVerifyIdentitySection = false;
                    profileView.stepsListModel.setProperty(2, "stepCompleted", true);
                    popup.contactsStore.verifiedTrusted(userPublicKey);
                    popup.isTrusted = true
                }
            }

            StatusButton {
                visible: showIdentityVerified || showIdentityVerifiedUntrustworthy
                text: qsTr("Rename")
                onClicked: {
                    profileView.nicknamePopup.open()
                }
            }

            StatusButton {
                visible: showIdentityVerified || showIdentityVerifiedUntrustworthy
                text: qsTr("Close")
                onClicked: {
                    popup.close();
                }
            }
        }
    }

    StatusScrollView {
        id: scrollView

        anchors.fill: parent
        padding: 0

        SharedViews.ProfileView {
            id: profileView

            width: scrollView.availableWidth

            profileStore: popup.profileStore
            contactsStore: popup.contactsStore


            userPublicKey: popup.userPublicKey
            userDisplayName: popup.userDisplayName
            userName: popup.userName
            userNickname: popup.userNickname
            userEnsName: popup.userEnsName
            userIcon: popup.userIcon
            userBio: popup.userBio
            userSocialLinks: popup.userSocialLinks
            userIsEnsVerified: popup.userIsEnsVerified
            userIsBlocked: popup.userIsBlocked
            isAddedContact: popup.isAddedContact
            isCurrentUser: popup.isCurrentUser

            isContact: popup.isContact
            isVerificationSent: popup.isVerificationSent
            isVerified: popup.isVerified
            isTrusted: popup.isTrusted
            hasReceivedVerificationRequest: popup.hasReceivedVerificationRequest

            userTrustStatus: popup.userTrustStatus
            outgoingVerificationStatus: popup.outgoingVerificationStatus

            showVerifyIdentitySection: popup.showVerifyIdentitySection
            showVerificationPendingSection: popup.showVerificationPendingSection
            showIdentityVerified: popup.showIdentityVerified
            showIdentityVerifiedUntrustworthy: popup.showIdentityVerifiedUntrustworthy

            challenge: popup.challenge
            response: popup.response

            userIsUntrustworthy: popup.userIsUntrustworthy
            userTrustIsUnknown: popup.userTrustIsUnknown

            verificationChallenge: popup.verificationChallenge
            verificationResponse: popup.verificationResponse
            verificationResponseDisplayName: popup.verificationResponseDisplayName
            verificationResponseIcon: popup.verificationResponseIcon
            verificationRequestedAt: popup.verificationRequestedAt
            verificationRepliedAt: popup.verificationRepliedAt

            onContactUnblocked: {
                popup.close()
                popup.contactUnblocked(publicKey)
            }

            onContactBlocked: {
                popup.close()
                popup.contactBlocked(publicKey)
            }

            onContactAdded: {
                popup.close()
                popup.contactAdded(publicKey)
            }

            onContactRemoved: {
                popup.close()
            }

            onNicknameEdited: {
                popup.close()
            }
        }
    }

    Component {
        id: contactVerificationRequestPopupComponent
        ContactVerificationRequestPopup {
            onResponseSent: {
                popup.contactsStore.acceptVerificationRequest(senderPublicKey, response)
            }
            onVerificationRefused: {
                popup.contactsStore.declineVerificationRequest(senderPublicKey)
            }
        }
    }
}
