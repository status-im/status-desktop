import QtQuick 2.15
import QtQuick.Layouts 1.15
import QtQuick.Dialogs 1.3
import QtQml.Models 2.15
import QtQml 2.15

import StatusQ.Core 0.1
import StatusQ.Controls 0.1
import StatusQ.Components 0.1
import StatusQ.Popups 0.1
import StatusQ.Core.Theme 0.1

import AppLayouts.Chat.popups 1.0
import AppLayouts.Profile.popups 1.0
import AppLayouts.Communities.popups 1.0

import shared.popups 1.0
import shared.status 1.0

import utils 1.0

QtObject {
    id: root

    required property var popupParent
    required property var rootStore
    property var communitiesStore
    property bool isDevBuild

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
        Global.createCommunityPopupRequested.connect(openCreateCommunityPopup)
        Global.importCommunityPopupRequested.connect(openImportCommunityPopup)
        Global.removeContactRequested.connect(openRemoveContactConfirmationPopup)
        Global.openPopupRequested.connect(openPopup)
        Global.closePopupRequested.connect(closePopup)
        Global.openDeleteMessagePopup.connect(openDeleteMessagePopup)
        Global.openDownloadImageDialog.connect(openDownloadImageDialog)
        Global.leaveCommunityRequested.connect(openLeaveCommunityPopup)
        Global.openTestnetPopup.connect(openTestnetPopup)
    }

    property var currentPopup
    function openPopup(popupComponent, params = {}, cb = null) {
        if (activePopupComponents.includes(popupComponent)) {
            return
        }

        root.currentPopup = popupComponent.createObject(popupParent, params)
        root.currentPopup.open();
        if (cb)
            cb(root.currentPopup)

        activePopupComponents.push(popupComponent)

        root.currentPopup.closed.connect(() => {
            const removeIndex = activePopupComponents.indexOf(popupComponent)
            if (removeIndex !== -1) {
                activePopupComponents.splice(removeIndex, 1)
            }
        })
    }

    function closePopup() {
        if (!!root.currentPopup)
            root.currentPopup.close();
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

    function openImagePopup(image) {
        var popup = imagePopupComponent.createObject(popupParent)
        popup.openPopup(image)
    }

    function openProfilePopup(publicKey: string, parentPopup, cb) {
        openPopup(profilePopupComponent, {publicKey: publicKey, parentPopup: parentPopup}, cb)
    }

    function openNicknamePopup(publicKey: string, nickname: string, subtitle: string) {
        openPopup(nicknamePopupComponent, {publicKey: publicKey, nickname: nickname, "headerSettings.subTitle": subtitle})
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
            "headerSettings.title": qsTr("Verify %1's Identity").arg(contactDetails.displayName),
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

    function openPinnedMessagesPopup(store, messageStore, pinnedMessagesModel, messageToPin, chatId) {
        openPopup(pinnedMessagesPopup, {
            store: store,
            messageStore: messageStore,
            pinnedMessagesModel: pinnedMessagesModel,
            messageToPin: messageToPin,
            chatId: chatId
        })
    }

    function openCommunityPopup(store, community, chatCommunitySectionModule) {
        openPopup(communityProfilePopup, {store: store, community: community, chatCommunitySectionModule: chatCommunitySectionModule})
    }

    function openCreateCommunityPopup(isDiscordImport) {
        openPopup(createCommunitiesPopupComponent, {isDiscordImport: isDiscordImport})
    }

    function openImportCommunityPopup() {
        openPopup(importCommunitiesPopupComponent)
    }

    function openDiscordImportProgressPopup() {
        openPopup(discordImportProgressDialog)
    }

    function openRemoveContactConfirmationPopup(displayName, publicKey) {
        openPopup(removeContactConfirmationDialog, {
            displayName: displayName,
            publicKey: publicKey
        })
    }

    function openDeleteMessagePopup(messageId, messageStore) {
        openPopup(deleteMessageConfirmationDialogComponent,
                  {
                      messageId,
                      messageStore
                  })
    }

    function openDownloadImageDialog(imageSource) {
        // We don't use `openPopup`, because there's no `FileDialog::closed` signal.
        const popup = downloadImageDialogComponent.createObject(popupParent, { imageSource })
        popup.open()
    }

    function openLeaveCommunityPopup(community, communityId, outroMessage) {
        openPopup(leaveCommunityPopupComponent, {community, communityId, outroMessage})
    }

    function openTestnetPopup() {
        openPopup(testnetModal)
    }

    readonly property list<Component> _components: [
        Component {
            id: removeContactConfirmationDialog
            ConfirmationDialog {
                property string displayName
                property string publicKey
                headerSettings.title: qsTr("Remove '%1' as a contact").arg(displayName)
                confirmationText: qsTr("This will mean that you and '%1' will no longer be able to send direct messages to each other. You will need to send them a new Contact Request in order to message again. All previous direct messages between you and '%1' will be retained in read-only mode.").arg(displayName)
                showCancelButton: true
                cancelBtnType: ""
                onConfirmButtonClicked: {
                    rootStore.contactStore.removeContact(publicKey);
                    close();
                }
                onCancelButtonClicked: {
                    close();
                }
                onClosed: { destroy(); }
            }
        },
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
                rootStore: root.rootStore
                onAccepted: root.rootStore.profileSectionStore.contactsStore.sendVerificationRequest(userPublicKey, message)
                onClosed: destroy()
            }
        },

        Component {
            id: inviteFriendsToCommunityPopup

            InviteFriendsToCommunityPopup {
                rootStore: root.rootStore
                contactsStore: root.rootStore.contactStore
                onClosed: destroy()
            }
        },

        Component {
            id: sendContactRequestPopupComponent

            SendContactRequestModal {
                rootStore: root.rootStore
                onAccepted: root.rootStore.profileSectionStore.contactsStore.sendContactRequest(userPublicKey, message)
                onClosed: destroy()
            }
        },

        Component {
            id: backupSeedModalComponent
            BackupSeedModal {
                privacyStore: rootStore.profileSectionStore.privacyStore
                onClosed: destroy()
            }
        },

        Component {
            id: displayNamePopupComponent
            DisplayNamePopup {
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
                onClosed: destroy()
            }
        },

        Component {
            id: profilePopupComponent
            ProfileDialog {
                id: profilePopup
                profileStore: rootStore.profileSectionStore.profileStore
                contactsStore: rootStore.profileSectionStore.contactsStore
                communitiesModel: rootStore.profileSectionStore.communitiesList

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
                contactsStore: rootStore.contactStore
                hasAddedContacts: rootStore.hasAddedContacts

                onClosed: destroy()
            }
        },

        Component {
            id: pinnedMessagesPopup
            PinnedMessagesPopup {
                onClosed: destroy()
            }
        },

        Component {
            id: nicknamePopupComponent
            NicknamePopup {
                onEditDone: {
                    if (nickname !== newNickname) {
                        rootStore.contactStore.changeContactNickname(publicKey, newNickname)
                        Global.contactRenamed(publicKey)
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
        },

        Component {
            id: importCommunitiesPopupComponent
            ImportCommunityPopup {
                store: root.communitiesStore
                onClosed: {
                    destroy()
                }
            }
        },

        Component {
            id: createCommunitiesPopupComponent
            CreateCommunityPopup {
                store: root.communitiesStore
                isDevBuild: root.isDevBuild
                onClosed: {
                    destroy()
                }
            }
        },

        Component {
            id: discordImportProgressDialog
            DiscordImportProgressDialog {
                store: root.communitiesStore
            }
        },

        Component {
            id: deleteMessageConfirmationDialogComponent
            DeleteMessageConfirmationPopup {
                onClosed: destroy()
            }
        },

        Component {
            id: downloadImageDialogComponent
            FileDialog {
                property string imageSource
                title: qsTr("Please choose a directory")
                selectFolder: true
                selectExisting: true
                selectMultiple: false
                modality: Qt.NonModal
                onAccepted: {
                    Utils.downloadImageByUrl(imageSource, fileUrl)
                    destroy()
                }
                onRejected: {
                    destroy()
                }
            }
        },

        Component {
            id: leaveCommunityPopupComponent
            StatusModal {
                id: leavePopup

                property string community
                property string communityId
                property string outroMessage

                headerSettings.title: qsTr("Are you sure want to leave '%1'?").arg(community)
                padding: 16
                width: 640
                contentItem: ColumnLayout {
                    spacing: 16
                    StatusBaseText {
                        id: outroMessage
                        Layout.fillWidth: true
                        wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                        text: leavePopup.outroMessage
                        visible: !!text
                    }
                    StatusMenuSeparator {
                        Layout.fillWidth: true
                        visible: outroMessage.visible
                    }
                    StatusBaseText {
                        Layout.fillWidth: true
                        wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                        font.pixelSize: 13
                        text: qsTr("You will need to request to join if you want to become a member again in the future. If you joined the Community via public key ensure you have a copy of it before you go.")
                    }
                }

                rightButtons: [
                    StatusFlatButton {
                        text: qsTr("Cancel")
                        onClicked: leavePopup.close()
                    },
                    StatusButton {
                        objectName: "CommunitiesListPanel_leaveCommunityButtonInPopup"
                        type: StatusBaseButton.Type.Danger
                        text: qsTr("Leave %1").arg(leavePopup.community)
                        onClicked: {
                            leavePopup.close()
                            root.rootStore.profileSectionStore.communitiesProfileModule.leaveCommunity(leavePopup.communityId)
                        }
                    }
                ]

                onClosed: destroy()
            }
        },

        Component {
            id: testnetModal
            AlertPopup {
                width: 521
                readonly property string mainTitle: root.rootStore.profileSectionStore.walletStore.areTestNetworksEnabled ? qsTr("Turn off testnet mode") : qsTr("Turn on testnet mode")
                title: mainTitle
                alertLabel.textFormat: Text.RichText
                alertText: root.rootStore.profileSectionStore.walletStore.areTestNetworksEnabled ?
                               qsTr("Are you sure you want to turn off %1? All future transactions will be performed on live networks with real funds").arg("<html><span style='font-weight: 500;'>testnet mode</span></html>") :
                               qsTr("Are you sure you want to turn on %1? In this mode, all blockchain data displayed will come from testnets and all blockchain interactions will be with testnets. Testnet mode switches the entire app to using testnets only. Please switch this mode on only if you know exactly why you need to use it.").arg("<html><span style='font-weight: 500;'>testnet mode</span></html>")
                acceptBtnText: mainTitle
                acceptBtnType: root.rootStore.profileSectionStore.walletStore.areTestNetworksEnabled ? StatusBaseButton.Type.Normal : StatusBaseButton.Type.Warning
                asset.name: "settings"
                asset.color: Theme.palette.warningColor1
                asset.bgColor: Theme.palette.warningColor3
                onAcceptClicked: {
                    root.rootStore.profileSectionStore.walletStore.toggleTestNetworksEnabled()
                    Global.displayToastMessage(root.rootStore.profileSectionStore.walletStore.areTestNetworksEnabled ? qsTr("Testnet mode turned on") : qsTr("Testnet mode turned off") , "", "checkmark-circle", false, Constants.ephemeralNotificationType.success, "")
                }
                onCancelClicked: close()
            }
        }
    ]
}
