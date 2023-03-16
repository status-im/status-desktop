import QtQuick 2.15

import AppLayouts.Chat.popups 1.0
import AppLayouts.Profile.popups 1.0

import shared.popups 1.0
import shared.status 1.0

import utils 1.0

QtObject {
    id: root

    required property var popupParent
    required property var rootStore

    property var activePopupComponents: []

    Component.onCompleted: {
        Global.openSendIDRequestPopup.connect(openSendIDRequestPopup)
        Global.openOutgoingIDRequestPopup.connect(openOutgoingIDRequestPopup)
        Global.openIncomingIDRequestPopup.connect(openIncomingIDRequestPopup)
        Global.openInviteFriendsToCommunityPopup.connect(openInviteFriendsToCommunityPopup)
        Global.openContactRequestPopup.connect(openContactRequestPopup)
        Global.openChooseBrowserPopup.connect(openChooseBrowserPopup)
        Global.openDownloadModalRequested.connect(openDownloadModal)
        Global.openImagePopup.connect(openImagePopup)
        Global.openProfilePopupRequested.connect(openProfilePopup)
        Global.openNicknamePopupRequested.connect(openNicknamePopup)
        Global.blockContactRequested.connect(openBlockContactPopup)
        Global.unblockContactRequested.connect(openUnblockContactPopup)
        Global.openChangeProfilePicPopup.connect(openChangeProfilePicPopup)
        Global.openBackUpSeedPopup.connect(openBackUpSeedPopup)
        Global.openEditDisplayNamePopup.connect(openEditDisplayNamePopup)
        Global.openPinnedMessagesPopupRequested.connect(openPinnedMessagesPopup)
        Global.openCommunityProfilePopupRequested.connect(openCommunityProfilePopup)
        Global.openPopupRequested.connect(openPopup)
    }

    function openPopup(popupComponent, params = {}, cb = null) {
        if (activePopupComponents.includes(popupComponent)) {
            return
        }

        const popup = popupComponent.createObject(popupParent, params)
        popup.open()

        if (cb)
            cb(popup)

        activePopupComponents.push(popupComponent)

        popup.closed.connect(() => {
            const removeIndex = activePopupComponents.indexOf(popupComponent)
            if (removeIndex !== -1) {
                activePopupComponents.splice(removeIndex, 1)
            }
        })
    }

    function openChooseBrowserPopup(link: string) {
        openPopup(chooseBrowserPopupComponent, {link: link})
    }

    function openDownloadModal(available: bool, version: string, url: string) {
        const popupProperties = {
            newVersionAvailable: available,
            downloadURL: url,
            currentVersion: rootStore.profileSectionStore.getCurrentVersion(),
            newVersion: version
        }
        openPopup(downloadPageComponent, popupProperties)
    }

    function openImagePopup(image, contextMenu) {
        var popup = imagePopupComponent.createObject(popupParent)
        popup.contextMenu = contextMenu
        popup.openPopup(image)
    }

    function openProfilePopup(publicKey: string, parentPopup) {
        openPopup(profilePopupComponent, {publicKey: publicKey, parentPopup: parentPopup})
    }

    function openNicknamePopup(publicKey: string, nickname: string, subtitle: string) {
        openPopup(nicknamePopupComponent, {publicKey: publicKey, nickname: nickname, "header.subTitle": subtitle})
    }

    function openBlockContactPopup(publicKey: string, contactName: string) {
        openPopup(blockContactConfirmationComponent, {contactName: contactName, contactAddress: publicKey})
    }

    function openUnblockContactPopup(publicKey: string, contactName: string) {
        openPopup(unblockContactConfirmationComponent, {contactName: contactName, contactAddress: publicKey})
    }

    function openChangeProfilePicPopup(cb) {
        var popup = changeProfilePicComponent.createObject(popupParent, {callback: cb});
        popup.chooseImageToCrop()
    }

    function openBackUpSeedPopup() {
        openPopup(backupSeedModalComponent)
    }

    function openEditDisplayNamePopup() {
        openPopup(displayNamePopupComponent)
    }

    function openCommunityProfilePopup(store, community, communitySectionModule) {
        openPopup(communityProfilePopup, { store: store, community: community, communitySectionModule: communitySectionModule})
    }

    function openSendIDRequestPopup(publicKey, cb) {
        const contactDetails = Utils.getContactDetailsAsJson(publicKey, false)
        openPopup(sendIDRequestPopupComponent, {
            userPublicKey: publicKey,
            userDisplayName: contactDetails.displayName,
            userIcon: contactDetails.largeImage,
            userIsEnsVerified: contactDetails.ensVerified,
            "header.title": qsTr("Verify %1's Identity").arg(contactDetails.displayName),
            challengeText: qsTr("Ask a question that only the real %1 will be able to answer e.g. a question about a shared experience, or ask %1 to enter a code or phrase you have sent to them via a different communication channel (phone, post, etc...).").arg(contactDetails.displayName),
            buttonText: qsTr("Send verification request")
        }, cb)
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
            openPopup(contactOutgoingVerificationRequestPopupComponent, popupProperties, cb)
        } catch (e) {
            console.error("Error getting or parsing verification data", e)
        }
    }

    function openIncomingIDRequestPopup(publicKey, cb) {
        const popupProperties = {
            contactsStore: root.rootStore.profileSectionStore.contactsStore,
            publicKey: publicKey
        }

        openPopup(contactVerificationRequestPopupComponent, popupProperties, cb)
    }

    function openInviteFriendsToCommunityPopup(community, communitySectionModule, cb) {
        openPopup(inviteFriendsToCommunityPopup, { community: community, communitySectionModule: communitySectionModule }, cb)
    }

    function openContactRequestPopup(publicKey, cb) {
        const contactDetails = Utils.getContactDetailsAsJson(publicKey, false)
        const popupProperties = {
            userPublicKey: publicKey,
            userDisplayName: contactDetails.displayName,
            userIcon: contactDetails.largeImage,
            userIsEnsVerified: contactDetails.ensVerified
        }

        openPopup(sendContactRequestPopupComponent, popupProperties, cb)
    }

    function openPinnedMessagesPopup(store, messageStore, pinnedMessagesModel, messageToPin) {
        openPopup(pinnedMessagesPopup, { store: store, messageStore: messageStore,
                      pinnedMessagesModel: pinnedMessagesModel, messageToPin: messageToPin})
    }

    function openCommunityPopup(store, community, chatCommunitySectionModule) {
        openPopup(communityProfilePopup, {store: store, community: community, chatCommunitySectionModule: chatCommunitySectionModule})
    }

    readonly property list<Component> _components: [
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
        },

        Component {
            id: backupSeedModalComponent
            BackupSeedModal {
                anchors.centerIn: parent
                privacyStore: rootStore.profileSectionStore.privacyStore
                onClosed: destroy()
            }
        },

        Component {
            id: displayNamePopupComponent
            DisplayNamePopup {
                anchors.centerIn: parent
                profileStore: rootStore.profileSectionStore.profileStore
                onClosed: destroy()
            }
        },

        Component {
            id: downloadPageComponent
            DownloadPage {
                onClosed: destroy()
            }
        },

        Component {
            id: imagePopupComponent
            StatusImageModal {
                id: imagePopup
                onClicked: {
                    if (mouse.button === Qt.LeftButton) {
                        imagePopup.close()
                    } else if(mouse.button === Qt.RightButton) {
                        contextMenu.imageSource = imagePopup.imageSource
                        contextMenu.hideEmojiPicker = true
                        contextMenu.isRightClickOnImage = true
                        contextMenu.parent = imagePopup.contentItem
                        contextMenu.show()
                    }
                }
                onClosed: destroy()
            }
        },

        Component {
            id: profilePopupComponent
            ProfileDialog {
                id: profilePopup
                profileStore: rootStore.profileSectionStore.profileStore
                contactsStore: rootStore.profileSectionStore.contactsStore

                onClosed: {
                    if (profilePopup.parentPopup) {
                        profilePopup.parentPopup.close()
                    }
                    destroy()
                }
            }
        },

        Component {
            id: changeProfilePicComponent
            ImageCropWorkflow {
                title: qsTr("Profile Picture")
                acceptButtonText: qsTr("Make this my Profile Pic")
                onImageCropped: {
                    if (callback) {
                        callback(image,
                                 cropRect.x.toFixed(),
                                 cropRect.y.toFixed(),
                                 (cropRect.x + cropRect.width).toFixed(),
                                 (cropRect.y + cropRect.height).toFixed())
                        return
                    }

                    rootStore.profileSectionStore.profileStore.uploadImage(image,
                                                  cropRect.x.toFixed(),
                                                  cropRect.y.toFixed(),
                                                  (cropRect.x + cropRect.width).toFixed(),
                                                  (cropRect.y + cropRect.height).toFixed());
                }
                onDone: destroy()
            }
        },

        Component {
            id: chooseBrowserPopupComponent
            ChooseBrowserPopup {
                onClosed: destroy()
            }
        },

        Component {
            id: communityProfilePopup

            CommunityProfilePopup {
                anchors.centerIn: parent
                contactsStore: rootStore.contactStore
                hasAddedContacts: rootStore.hasAddedContacts

                onClosed: destroy()
            }
        },

        Component {
            id: pinnedMessagesPopup
            PinnedMessagesPopup {
                emojiReactionsModel: rootStore.emojiReactionsModel
                onClosed: destroy()
            }
        },

        Component {
            id: nicknamePopupComponent
            NicknamePopup {
                onEditDone: {
                    if (nickname !== newNickname) {
                        rootStore.contactStore.changeContactNickname(publicKey, newNickname)
                    }
                    close()
                }
                onClosed: destroy()
            }
        },

        Component {
            id: unblockContactConfirmationComponent
            UnblockContactConfirmationDialog {
                onUnblockButtonClicked: {
                    rootStore.contactStore.unblockContact(contactAddress)
                    close()
                }
                onClosed: destroy()
            }
        },

        Component {
            id: blockContactConfirmationComponent
            BlockContactConfirmationDialog {
                onBlockButtonClicked: {
                    rootStore.contactStore.blockContact(contactAddress)
                    close()
                }
                onClosed: destroy()
            }
        }
    ]
}
