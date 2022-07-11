import QtQuick 2.13
import QtQuick.Controls 2.13
import QtQuick.Layouts 1.13
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
import StatusQ.Popups 0.1

StatusModal {
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
    property int userTrustStatus: Constants.trustStatus.unknown
    property int verificationStatus: Constants.verificationStatus.unverified
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
        userPublicKey = publicKey;
        userDisplayName = contactDetails.displayName;
        userName = contactDetails.alias;
        userNickname = contactDetails.localNickname;
        userEnsName = contactDetails.name;
        userIcon = contactDetails.largeImage;
        userIsEnsVerified = contactDetails.ensVerified;
        userIsBlocked = contactDetails.isBlocked;
        isAddedContact = contactDetails.isAdded;
        isContact = contactDetails.isContact
        userTrustStatus = contactDetails.trustStatus
        userTrustIsUnknown = contactDetails.trustStatus === Constants.trustStatus.unknown
        userIsUntrustworthy = contactDetails.trustStatus === Constants.trustStatus.untrustworthy
        verificationStatus = contactDetails.verificationStatus
        isVerificationSent = verificationStatus !== Constants.verificationStatus.unverified

        if (isContact && popup.contactsStore.hasReceivedVerificationRequestFrom(publicKey)) {
            popup.hasReceivedVerificationRequest = true
        }

        if(isContact && isVerificationSent) {
            let verificationDetails = popup.contactsStore.getSentVerificationDetailsAsJson(publicKey);

            verificationStatus = verificationDetails.requestStatus;
            verificationChallenge = verificationDetails.challenge;
            verificationResponse = verificationDetails.response;
            verificationResponseDisplayName = verificationDetails.displayName;
            verificationResponseIcon = verificationDetails.icon;
            verificationRequestedAt = verificationDetails.requestedAt;
            verificationRepliedAt = verificationDetails.repliedAt;
        }
        isTrusted = verificationStatus === Constants.verificationStatus.trusted
        isVerified = verificationStatus === Constants.verificationStatus.verified

        text = ""; // this is most likely unneeded
        isCurrentUser = popup.profileStore.pubkey === publicKey;

        showFooter = !isCurrentUser;
        popup.open();

        if (state == "openNickname") {
            nicknamePopup.open();
        } else if (state == "contactRequest") {
            sendContactRequestModal.open()
        } else if (state == "blockUser") {
            blockUser();
        } else if (state == "unblockUser") {
            unblockUser();
        }
    }

    function blockUser() {
        profileView.blockContactConfirmationDialog.contactName = userName;
        profileView.blockContactConfirmationDialog.contactAddress = userPublicKey;
        profileView.blockContactConfirmationDialog.open();
    }

    function unblockUser() {
        profileView.unblockContactConfirmationDialog.contactName = userName;
        profileView.unblockContactConfirmationDialog.contactAddress = userPublicKey;
        profileView.unblockContactConfirmationDialog.open();
    }

    width: 700

    header.title: {
        if(showVerifyIdentitySection || showVerificationPendingSection){
            return qsTr("Verify %1's Identity").arg(userIsEnsVerified ? userName : userDisplayName)
        }
        return popup.isCurrentUser ? qsTr("My Profile") :
                                     qsTr("%1's Profile").arg(userIsEnsVerified ? userName : userDisplayName)
    }
    header.subTitle: popup.isCurrentUser ? "" : userIsEnsVerified ? userName : Utils.getElidedCompressedPk(userPublicKey)
    header.subTitleElide: Text.ElideMiddle
    padding: 8

    headerActionButton:  StatusFlatRoundButton {
        type: StatusFlatRoundButton.Type.Secondary
        width: 32
        height: 32

        icon.width: 20
        icon.height: 20
        icon.name: "qr"
        onClicked: profileView.qrCodePopup.open()
    }

    SharedViews.ProfileView {
        id: profileView
        anchors.fill: parent

        profileStore: popup.profileStore
        contactsStore: popup.contactsStore

        userPublicKey: popup.userPublicKey
        userDisplayName: popup.userDisplayName
        userName: popup.userName
        userNickname: popup.userNickname
        userEnsName: popup.userEnsName
        userIcon: popup.userIcon
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
        verificationStatus: popup.verificationStatus
        
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

    // TODO: replace with StatusStackModal
    SendContactRequestModal {
        id: sendContactRequestModal
        anchors.centerIn: parent
        width: popup.width
        visible: false
        header.title: qsTr("Send Contact Request to %1").arg(userDisplayName)
        userPublicKey: popup.userPublicKey
        userDisplayName: popup.userDisplayName
        userIcon: popup.userIcon
        onAccepted: popup.contactsStore.sendContactRequest(userPublicKey, message)
        onClosed: popup.close()
    }
    
    leftButtons:[
        StatusButton {
            text: qsTr("Cancel verification")
            visible: !isVerified && isContact && isVerificationSent && showVerificationPendingSection
            onClicked: {
                popup.contactsStore.cancelVerificationRequest(userPublicKey);
                popup.close()
            }
        }
    ]

    rightButtons: [
        StatusFlatButton {
            text: userIsBlocked ?
                qsTr("Unblock User") :
                qsTr("Block User")
            type: StatusBaseButton.Type.Danger
            visible: !isAddedContact
            onClicked: userIsBlocked ? unblockUser() : blockUser()
        },

        StatusFlatButton {
            visible:  !showRemoveVerified && !showIdentityVerified && !showVerifyIdentitySection && !showVerificationPendingSection && !userIsBlocked && isAddedContact
            type: StatusBaseButton.Type.Danger
            text: qsTr('Remove Contact')
            onClicked: {
                profileView.removeContactConfirmationDialog.parentPopup = popup;
                profileView.removeContactConfirmationDialog.open();
            }
        },

        StatusButton {
            text: qsTr("Send Contact Request")
            visible: !userIsBlocked && !isAddedContact
            onClicked: sendContactRequestModal.open()
        },

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
        },

        StatusButton {
            text: qsTr("Remove 'Identity Verified' status")
            visible: isTrusted && !showIdentityVerified && !showRemoveVerified
            type: StatusBaseButton.Type.Danger
            onClicked: {
                showRemoveVerified = true
            }
        },

        StatusButton {
            text: qsTr("No")
            visible: showRemoveVerified
            type: StatusBaseButton.Type.Danger
            onClicked: {
                showRemoveVerified = false
            }
        },

        StatusButton {
            text: qsTr("Yes")
            visible: showRemoveVerified
            onClicked: {
                popup.contactsStore.removeTrustStatus(userPublicKey);
                popup.close();
            }
        },

        StatusButton {
            text: qsTr("Remove Untrustworthy Mark")
            visible: userIsUntrustworthy
            onClicked: {
                popup.contactsStore.removeTrustStatus(userPublicKey);
                popup.close();
            }
        },

        StatusButton {
            text: qsTr("Verify Identity")
            visible: !showIdentityVerifiedUntrustworthy && !showIdentityVerified &&
                !showVerifyIdentitySection && isContact  && !isVerificationSent
                && !hasReceivedVerificationRequest
            onClicked: {
                popup.showVerifyIdentitySection = true
            }
        },

        StatusButton {
            text: qsTr("Verify Identity pending...")
            visible: (!showIdentityVerifiedUntrustworthy && !showIdentityVerified && !isTrusted
                && isContact && isVerificationSent && !showVerificationPendingSection) ||
                (hasReceivedVerificationRequest && !isTrusted)
            onClicked: {
                if (hasReceivedVerificationRequest) {
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
                } else {
                    popup.showVerificationPendingSection = true
                    profileView.wizardAnimation.running = true
                }
            }
        },


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
        },

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
        },

        StatusButton {
            visible: showIdentityVerified || showIdentityVerifiedUntrustworthy
            text: qsTr("Rename")
            onClicked: {
                nicknamePopup.open()
            }
        },

        StatusButton {
            visible: showIdentityVerified || showIdentityVerifiedUntrustworthy
            text: qsTr("Close")
            onClicked: {
                popup.close();
            }
        }
    ]

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
