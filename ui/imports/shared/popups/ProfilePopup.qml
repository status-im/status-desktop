import QtQuick 2.13
import QtQuick.Controls 2.13
import QtQuick.Layouts 1.13
import QtGraphicalEffects 1.13

import utils 1.0
import shared 1.0
import shared.popups 1.0
import shared.stores 1.0
import shared.controls.chat 1.0
import shared.panels 1.0


import StatusQ.Core 0.1
import StatusQ.Core.Theme 0.1
import StatusQ.Components 0.1
import StatusQ.Controls 0.1
import StatusQ.Popups 0.1

StatusModal {
    id: popup
    anchors.centerIn: parent

    property Popup parentPopup

    property var profileStore
    property var contactsStore

    property string userPublicKey: ""
    property string userDisplayName: ""
    property string userName: ""
    property string userNickname: ""
    property string userEnsName: ""
    property string userIcon: ""
    property bool isUserIconIdenticon: true
    property int userTrustStatus: Constants.trustStatus.unknown
    property int verificationStatus: Constants.verificationStatus.unverified
    property string text: ""
    property string challenge: ""
    property string response: ""

    readonly property int innerMargin: 20

    property bool userIsEnsVerified: false
    property bool userIsBlocked: false
    property bool userIsUntrustworthy: false
    property bool userTrustIsUnknown: false
    property bool isCurrentUser: false
    property bool isAddedContact: false
    property bool isMutualContact: false
    property bool isVerificationSent: false
    property bool isVerified: false

    property bool showVerifyIdentitySection: false
    property bool showVerificationPendingSection: false
    property bool showIdentityVerified: false
    property bool showIdentityVerifiedUntrustworthy: false

    property string verificationChallenge: ""
    property string verificationResponse: ""

    signal blockButtonClicked(name: string, address: string)
    signal unblockButtonClicked(name: string, address: string)
    signal removeButtonClicked(address: string)

    signal contactUnblocked(publicKey: string)
    signal contactBlocked(publicKey: string)
    signal contactAdded(publicKey: string)

    function openPopup(publicKey, openNicknamePopup) {
        // All this should be improved more, but for now we leave it like this.
        let contactDetails = Utils.getContactDetailsAsJson(publicKey)
        userPublicKey = publicKey
        userDisplayName = contactDetails.displayName
        userName = contactDetails.alias
        userNickname = contactDetails.localNickname
        userEnsName = contactDetails.name

        if (contactDetails.isDisplayIconIdenticon || (!contactDetails.isContact &&
            Global.privacyModuleInst.profilePicturesVisibility !==
            Constants.profilePicturesVisibility.everyone)) {
            userIcon = contactDetails.identicon
        } else {
            userIcon = contactDetails.displayIcon
        }
        isUserIconIdenticon = contactDetails.isDisplayIconIdenticon
        userIsEnsVerified = contactDetails.ensVerified
        userIsBlocked = contactDetails.isBlocked
        isAddedContact = contactDetails.isContact
        isMutualContact = contactDetails.isContact && contactDetails.hasAddedUs
        userTrustStatus = contactDetails.trustStatus
        userTrustIsUnknown = contactDetails.trustStatus === Constants.trustStatus.unknown
        userIsUntrustworthy = contactDetails.trustStatus === Constants.trustStatus.untrustworthy
        verificationStatus = contactDetails.verificationStatus

        isVerificationSent = verificationStatus !== Constants.verificationStatus.unverified
        isVerified = verificationStatus === Constants.verificationStatus.verified

        if(isVerificationSent) {
            let verificationDetails = popup.contactsStore.getSentVerificationDetailsAsJson(publicKey);
            verificationChallenge = verificationDetails.challenge;
            verificationResponse = verificationDetails.response;
        }
        stepsListModel.setProperty(0, "stepCompleted", true);
        stepsListModel.setProperty(1, "stepCompleted", isVerificationSent && verificationResponse != "");

        text = "" // this is most likely unneeded
        isCurrentUser = popup.profileStore.pubkey === publicKey
        showFooter = !isCurrentUser
        popup.open()

        if (openNicknamePopup) {
            nicknamePopup.open()
        }
    }

    width:700

    header.title: {
        if(showVerifyIdentitySection || showVerificationPendingSection){
            return qsTr("Verify %1's Identity").arg(userIsEnsVerified ? userName : userDisplayName)
        }
        return qsTr("%1's Profile").arg(userIsEnsVerified ? userName : userDisplayName)
    }

    contentItem: Item {
        width: popup.width
        height: modalContent.height

        property alias qrCodePopup: qrCodePopup
        property alias unblockContactConfirmationDialog: unblockContactConfirmationDialog
        property alias blockContactConfirmationDialog: blockContactConfirmationDialog
        property alias removeContactConfirmationDialog: removeContactConfirmationDialog

        Column {
            id: modalContent
            anchors.top: parent.top
            width: parent.width

            Item {
                height: 16
                width: parent.width
            }

            ProfileHeader {
                width: parent.width

                displayName: popup.userDisplayName
                pubkey: popup.userPublicKey
                icon: popup.isCurrentUser ? popup.profileStore.icon : popup.userIcon
                isIdenticon: popup.isCurrentUser ? popup.profileStore.isIdenticon : popup.isUserIconIdenticon
                trustStatus: popup.userTrustStatus
                isContact: isAddedContact
                store: profileStore
                displayNameVisible: false
                pubkeyVisible: false
                displayNamePlusIconsVisible: true
                pubkeyVisibleWithCopy: true
                onEditClicked: {
                    if(!isCurrentUser){
                        nicknamePopup.open()
                    } else {
                        Global.openEditDisplayNamePopup()
                    }
                }

                emojiSize: "20x20"
                imageWidth: 80
                imageHeight: 80

                imageOverlay: Item {
                    visible: popup.isCurrentUser

                    StatusFlatRoundButton {
                        width: 24
                        height: 24

                        anchors {
                            right: parent.right
                            bottom: parent.bottom
                            rightMargin: -8
                        }

                        type: StatusFlatRoundButton.Type.Secondary
                        icon.name: "pencil"
                        icon.color: Theme.palette.directColor1
                        icon.width: 12.5
                        icon.height: 12.5

                        onClicked: Global.openChangeProfilePicPopup()
                    }
                }
            }

            StatusBanner {
                width: parent.width
                visible: popup.userIsBlocked
                type: StatusBanner.Type.Danger
                statusText: qsTr("Blocked")
            }

            Item {
                height: 16
                width: parent.width
            }

            ListModel {
                id: stepsListModel
                ListElement {description:"Send Request"; loadingTime: 0; stepCompleted: true}
                ListElement {description:"Receive Response"; loadingTime: 0; stepCompleted: false}
                ListElement {description:"Confirm Identity"; loadingTime: 0; stepCompleted: false}
            }

            StatusWizardStepper {
                id: wizardStepper
                visible: showVerifyIdentitySection || showVerificationPendingSection || showIdentityVerified || showIdentityVerifiedUntrustworthy
                width: parent.width
                stepsModel: stepsListModel
            }

            StyledText {
                id: confirmLbl
                visible: showIdentityVerified
                text: qsTr("You have confirmed %1’s identity. From now on this verification emblem will always be displayed alongside %1’s nickname.").arg(userIsEnsVerified ? userEnsName : userDisplayName)
                font.pixelSize: Style.current.asideTextFontSize
                Layout.alignment: Qt.AlignHCenter
                width: parent.width
                wrapMode: Text.WordWrap
            }

             StyledText {
                id: confirmUntrustworthyLbl
                visible: showIdentityVerifiedUntrustworthy
                text: qsTr("You have marked %1 as Untrustworthy. From now on this Untrustworthy emblem will always be displayed alongside %1’s nickname.").arg(userIsEnsVerified ? userEnsName : userDisplayName)
                font.pixelSize: Style.current.asideTextFontSize
                Layout.alignment: Qt.AlignHCenter
                width: parent.width
                wrapMode: Text.WordWrap
            }

            StatusInput {
                id: challengeTxt
                visible: showVerifyIdentitySection
                charLimit: 280
                input.text: popup.challenge
                width: parent.width
                input.multiline: true
                input.implicitHeight: 152
                input.placeholderText: qsTr("Ask a question that only the real %1 will be able to answer e.g. a question about a shared experience, or ask Mark to enter a code or phrase you have sent to them via a different communication channel (phone, post, etc...).").arg(userIsEnsVerified ? userEnsName : userDisplayName)
            }

            StyledText {
                id: challengeLbl
                visible: showVerificationPendingSection
                text: verificationChallenge
            }

            StyledText {
                id: responseLbl
                visible: showVerificationPendingSection && verificationResponse !== ""
                text: verificationResponse
            }

            Item {
                visible: !isCurrentUser
                width: parent.width
                height: 16
            }
        }

        // TODO: replace with StatusModal
        ModalPopup {
            id: qrCodePopup
            width: 320
            height: 320
            Image {
                asynchronous: true
                fillMode: Image.PreserveAspectFit
                source: globalUtils.qrCode(userPublicKey)
                anchors.horizontalCenter: parent.horizontalCenter
                height: 212
                width: 212
                mipmap: true
                smooth: false
            }
        }

        UnblockContactConfirmationDialog {
            id: unblockContactConfirmationDialog
            onUnblockButtonClicked: {
                popup.contactsStore.unblockContact(userPublicKey)
                unblockContactConfirmationDialog.close();
                popup.close()
                popup.contactUnblocked(userPublicKey)
            }
        }

        BlockContactConfirmationDialog {
            id: blockContactConfirmationDialog
            onBlockButtonClicked: {
                popup.contactsStore.blockContact(userPublicKey)
                blockContactConfirmationDialog.close();
                popup.close()

                popup.contactBlocked(userPublicKey)
            }
        }

        ConfirmationDialog {
            id: removeContactConfirmationDialog
            header.title: qsTr("Remove contact")
            confirmationText: qsTr("Are you sure you want to remove this contact?")
            onConfirmButtonClicked: {
                if (isAddedContact) {
                    popup.contactsStore.removeContact(userPublicKey);
                }
                removeContactConfirmationDialog.close();
                popup.close();
            }
        }

        NicknamePopup {
            id: nicknamePopup
            nickname: popup.userNickname
            header.subTitle: popup.header.subTitle
            header.subTitleElide: popup.header.subTitleElide
            onEditDone: {
                if(popup.userNickname !== newNickname)
                {
                    popup.userNickname = newNickname;
                    popup.contactsStore.changeContactNickname(userPublicKey, newNickname);
                }
                popup.close()
            }
        }
    }

    leftButtons:[
        StatusButton {
            text: qsTr("Cancel verification")
            visible: !isVerified && isMutualContact && isVerificationSent && showVerificationPendingSection
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
            onClicked: {
                if (userIsBlocked) {
                    contentItem.unblockContactConfirmationDialog.contactName = userName;
                    contentItem.unblockContactConfirmationDialog.contactAddress = userPublicKey;
                    contentItem.unblockContactConfirmationDialog.open();
                    return;
                }
                contentItem.blockContactConfirmationDialog.contactName = userName;
                contentItem.blockContactConfirmationDialog.contactAddress = userPublicKey;
                contentItem.blockContactConfirmationDialog.open();
            }
        },

        StatusFlatButton {
            visible:  !showIdentityVerified && !showVerifyIdentitySection && !showVerificationPendingSection && !userIsBlocked && isAddedContact
            type: StatusBaseButton.Type.Danger
            text: qsTr('Remove Contact')
            onClicked: {
                contentItem.removeContactConfirmationDialog.parentPopup = popup;
                contentItem.removeContactConfirmationDialog.open();
            }
        },

        StatusButton {
            text: qsTr("Mark Untrustworthy")
            visible:!showIdentityVerifiedUntrustworthy && !showIdentityVerified && !showVerifyIdentitySection && userTrustIsUnknown
            enabled: !showVerificationPendingSection || verificationResponse !== ""
            type: StatusBaseButton.Type.Danger
            onClicked: {
                if (showVerificationPendingSection) {
                    popup.showIdentityVerified = false;
                    popup.showIdentityVerifiedUntrustworthy = true;
                    popup.showVerificationPendingSection = false;
                    popup.showVerifyIdentitySection = false;
                    stepsListModel.setProperty(2, "stepCompleted", true);
                    popup.contactsStore.verifiedUntrustworthy(userPublicKey);
                } else {
                    popup.contactsStore.markUntrustworthy(userPublicKey);
                    popup.close();
                }
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
            visible: !showIdentityVerifiedUntrustworthy && !showIdentityVerified && !showVerifyIdentitySection && isMutualContact  && !isVerificationSent
            onClicked: {
                popup.showVerifyIdentitySection = true
            }
        },

        StatusButton {
            text: qsTr("Verify Identity pending...")
            visible: !showIdentityVerifiedUntrustworthy && !showIdentityVerified && !isVerified && isMutualContact && isVerificationSent && !showVerificationPendingSection
            onClicked: {
                popup.showVerificationPendingSection = true
            }
        },


        StatusButton {
            text: qsTr("Send verification request")
            visible: showVerifyIdentitySection && isMutualContact  && !isVerificationSent
            onClicked: {
                popup.contactsStore.sendVerificationRequest(userPublicKey, challengeTxt.input.text);
                popup.close();
            }
        },

        StatusButton {
            text: qsTr("Confirm Identity")
            visible: isMutualContact  && isVerificationSent && !isVerified && showVerificationPendingSection
            enabled: verificationChallenge !== "" && verificationResponse !== ""
            onClicked: {
                popup.showIdentityVerified = true;
                popup.showIdentityVerifiedUntrustworthy = false;
                popup.showVerificationPendingSection = false;
                popup.showVerifyIdentitySection = false;
                stepsListModel.setProperty(2, "stepCompleted", true);
                popup.contactsStore.verifiedTrusted(userPublicKey);
            }
        },

        StatusButton {
            text: qsTr("Add to contacts")
            visible: !userIsBlocked && !isAddedContact
            onClicked: {
                popup.contactsStore.addContact(userPublicKey);
                popup.contactAdded(userPublicKey);
                popup.close();
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
}
