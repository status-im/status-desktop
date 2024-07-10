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
import StatusQ.Core.Utils 0.1 as SQUtils

import AppLayouts.Chat.popups 1.0
import AppLayouts.Profile.popups 1.0
import AppLayouts.Communities.popups 1.0
import AppLayouts.Communities.helpers 1.0
import AppLayouts.Wallet.popups.swap 1.0
import AppLayouts.Wallet.popups 1.0

import AppLayouts.Wallet.stores 1.0 as WalletStore
import AppLayouts.Chat.stores 1.0 as ChatStore

import shared.popups 1.0
import shared.status 1.0
import shared.stores 1.0

import utils 1.0

QtObject {
    id: root

    required property var popupParent
    required property var rootStore
    required property var communityTokensStore
    property var communitiesStore
    property var devicesStore
    property CurrenciesStore currencyStore
    property WalletStore.WalletAssetsStore walletAssetsStore
    property WalletStore.CollectiblesStore walletCollectiblesStore
    property var networkConnectionStore
    property bool isDevBuild

    signal openExternalLink(string link)
    signal saveDomainToUnfurledWhitelist(string domain)
    signal ownershipDeclined(string communityId, string communityName)

    property var activePopupComponents: []

    Component.onCompleted: {
        Global.openSendIDRequestPopup.connect(openSendIDRequestPopup)
        Global.openMarkAsIDVerifiedPopup.connect(openMarkAsIDVerifiedPopup)
        Global.openRemoveIDVerificationDialog.connect(openRemoveIDVerificationDialog)
        Global.openOutgoingIDRequestPopup.connect(openOutgoingIDRequestPopup)
        Global.openIncomingIDRequestPopup.connect(openIncomingIDRequestPopup)
        Global.openInviteFriendsToCommunityPopup.connect(openInviteFriendsToCommunityPopup)
        Global.openInviteFriendsToCommunityByIdPopup.connect(openInviteFriendsToCommunityByIdPopup)
        Global.openContactRequestPopup.connect(openContactRequestPopup)
        Global.openReviewContactRequestPopup.connect(openReviewContactRequestPopup)
        Global.openChooseBrowserPopup.connect(openChooseBrowserPopup)
        Global.openDownloadModalRequested.connect(openDownloadModal)
        Global.openImagePopup.connect(openImagePopup)
        Global.openVideoPopup.connect(openVideoPopup)
        Global.openProfilePopupRequested.connect(openProfilePopup)
        Global.openNicknamePopupRequested.connect(openNicknamePopup)
        Global.markAsUntrustedRequested.connect(openMarkAsUntrustedPopup)
        Global.blockContactRequested.connect(openBlockContactPopup)
        Global.unblockContactRequested.connect(openUnblockContactPopup)
        Global.openChangeProfilePicPopup.connect(openChangeProfilePicPopup)
        Global.openBackUpSeedPopup.connect(openBackUpSeedPopup)
        Global.openPinnedMessagesPopupRequested.connect(openPinnedMessagesPopup)
        Global.openCommunityProfilePopupRequested.connect(openCommunityProfilePopup)
        Global.createCommunityPopupRequested.connect(openCreateCommunityPopup)
        Global.importCommunityPopupRequested.connect(openImportCommunityPopup)
        Global.communityShareAddressesPopupRequested.connect(openCommunityShareAddressesPopup)
        Global.communityIntroPopupRequested.connect(openCommunityIntroPopup)
        Global.removeContactRequested.connect(openRemoveContactConfirmationPopup)
        Global.openPopupRequested.connect(openPopup)
        Global.closePopupRequested.connect(closePopup)
        Global.openDeleteMessagePopup.connect(openDeleteMessagePopup)
        Global.openDownloadImageDialog.connect(openDownloadImageDialog)
        Global.leaveCommunityRequested.connect(openLeaveCommunityPopup)
        Global.openTestnetPopup.connect(openTestnetPopup)
        Global.openExportControlNodePopup.connect(openExportControlNodePopup)
        Global.openImportControlNodePopup.connect(openImportControlNodePopup)
        Global.openEditSharedAddressesFlow.connect(openEditSharedAddressesPopup)
        Global.openTransferOwnershipPopup.connect(openTransferOwnershipPopup)
        Global.openFinaliseOwnershipPopup.connect(openFinaliseOwnershipPopup)
        Global.openDeclineOwnershipPopup.connect(openDeclineOwnershipPopup)
        Global.openFirstTokenReceivedPopup.connect(openFirstTokenReceivedPopup)
        Global.openConfirmHideAssetPopup.connect(openConfirmHideAssetPopup)
        Global.openConfirmHideCollectiblePopup.connect(openConfirmHideCollectiblePopup)
        Global.openCommunityMemberMessagesPopupRequested.connect(openCommunityMemberMessagesPopup)
        Global.openSwapModalRequested.connect(openSwapModal)
        Global.openBuyCryptoModalRequested.connect(openBuyCryptoModal)
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

    function openImagePopup(image, url, plain) {
        openPopup(imagePopupComponent, {image: image, url: url, plain: plain})
    }

    function openVideoPopup(url) {
        openPopup(videoPopupComponent, { url: url })
    }

    function openProfilePopup(publicKey: string, parentPopup, cb) {
        openPopup(profilePopupComponent, {publicKey: publicKey, parentPopup: parentPopup}, cb)
    }

    function openNicknamePopup(publicKey: string, contactDetails, cb) {
        openPopup(nicknamePopupComponent, {publicKey, contactDetails}, cb)
    }

    function openMarkAsUntrustedPopup(publicKey: string, contactDetails) {
        openPopup(markAsUntrustedComponent, {publicKey, contactDetails})
    }

    function openBlockContactPopup(publicKey: string, contactDetails) {
        openPopup(blockContactConfirmationComponent, {publicKey, contactDetails})
    }

    function openUnblockContactPopup(publicKey: string, contactDetails) {
        openPopup(unblockContactConfirmationComponent, {publicKey, contactDetails})
    }

    function openChangeProfilePicPopup(cb) {
        var popup = changeProfilePicComponent.createObject(popupParent, {callback: cb});
        popup.chooseImageToCrop()
    }

    function openBackUpSeedPopup() {
        openPopup(backupSeedModalComponent)
    }

    function openCommunityProfilePopup(store, community, communitySectionModule) {
        openPopup(communityProfilePopup, { store: store, community: community, communitySectionModule: communitySectionModule})
    }

    function openSendIDRequestPopup(publicKey, contactDetails, cb) {
        openPopup(sendIDRequestPopupComponent, {
            publicKey: publicKey,
            contactDetails: contactDetails,
            title: qsTr("Request ID verification"),
            labelText: qsTr("Ask a question only they can answer"),
            challengeText: qsTr("Ask your question..."),
            buttonText: qsTr("Request ID verification")
        }, cb)
    }

    function openMarkAsIDVerifiedPopup(publicKey, contactDetails, cb) {
        openPopup(markAsIDVerifiedPopupComponent, {publicKey, contactDetails}, cb)
    }

    function openRemoveIDVerificationDialog(publicKey, contactDetails, cb) {
        openPopup(removeIDVerificationPopupComponent, {publicKey, contactDetails}, cb)
    }

    function openOutgoingIDRequestPopup(publicKey, contactDetails, cb) {
        let details = contactDetails ?? Utils.getContactDetailsAsJson(publicKey)
        try {
            const verificationDetails = rootStore.contactStore.getSentVerificationDetailsAsJson(publicKey)
            const popupProperties = {
                publicKey: publicKey,
                contactDetails: details,
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

    function openIncomingIDRequestPopup(publicKey, contactDetails, cb) {
        let details = contactDetails ?? Utils.getContactDetailsAsJson(publicKey)
        openPopup(contactVerificationRequestPopupComponent, {publicKey, contactDetails: details})
    }

    function openInviteFriendsToCommunityPopup(community, communitySectionModule, cb) {
        openPopup(inviteFriendsToCommunityPopup, { community: community, communitySectionModule: communitySectionModule }, cb)
    }

    function openInviteFriendsToCommunityByIdPopup(communityId, cb) {
        root.rootStore.mainModuleInst.prepareCommunitySectionModuleForCommunityId(communityId)
        const communitySectionModuleData = root.rootStore.mainModuleInst.getCommunitySectionModule()
        const communityData = root.communitiesStore.getCommunityDetails(communityId)

        openPopup(inviteFriendsToCommunityPopup, { community: communityData, communitySectionModule: communitySectionModuleData }, cb)
    }

    function openContactRequestPopup(publicKey, contactDetails, cb) {
        let details = contactDetails ?? Utils.getContactDetailsAsJson(publicKey, false)
        const popupProperties = {
            publicKey: publicKey,
            contactDetails: details
        }
        openPopup(sendContactRequestPopupComponent, popupProperties, cb)
    }

    function openReviewContactRequestPopup(publicKey, contactDetails, cb) {
        try {
            const crDetails = rootStore.contactStore.getLatestContactRequestForContactAsJson(publicKey)
            if (crDetails.from !== publicKey) {
                console.warn("Popups.openReviewContactRequestPopup: not matching publicKey:", publicKey)
                return
            }
            openPopup(reviewContactRequestPopupComponent, {publicKey, contactDetails, crDetails}, cb)
        } catch (e) {
            console.error("Popups.openReviewContactRequestPopup: error getting or parsing contact request data", e)
        }
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

    function openCommunityIntroPopup(communityId, name, introMessage,
                                     imageSrc, isInvitationPending) {
        openPopup(communityJoinDialogPopup,
                  {communityId: communityId,
                   communityName: name,
                   introMessage: introMessage,
                   communityIcon: imageSrc,
                   isInvitationPending: isInvitationPending
                  })
    }

    function openCommunityShareAddressesPopup(communityId, name, imageSrc) {
        openPopup(communityJoinDialogPopup,
                  {communityId: communityId,
                   stackTitle: qsTr("Share addresses with %1's owner").arg(name),
                   communityName: name,
                   introMessage: qsTr("Share addresses to rejoin %1").arg(name),
                   communityIcon: imageSrc,
                   isInvitationPending: false
                  })
    }

    function openEditSharedAddressesPopup(communityId) {
        openPopup(editSharedAddressesPopupComponent, {communityId: communityId, isEditMode: true})
    }

    function openDiscordImportProgressPopup(importingSingleChannel) {
        openPopup(discordImportProgressDialog, {importingSingleChannel: importingSingleChannel})
    }

    function openRemoveContactConfirmationPopup(publicKey, contactDetails) {
        openPopup(removeContactConfirmationDialog, {publicKey, contactDetails})
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

    function openExportControlNodePopup(community) {
        openPopup(exportControlNodePopup, { community })
    }

    function openImportControlNodePopup(community) {
        openPopup(importControlNodePopup, { community })
    }

    function openTransferOwnershipPopup(communityId, communityName, communityLogo, token, accounts, sendModalPopup) {
        openPopup(transferOwnershipPopup, { communityId, communityName, communityLogo, token, accounts, sendModalPopup })
    }

    function openConfirmExternalLinkPopup(link, domain) {
        openPopup(confirmExternalLinkPopup, {link, domain})
    }

    function openFinaliseOwnershipPopup(communityId) {
        openPopup(finaliseOwnershipPopup, { communityId: communityId })
    }

    function openDeclineOwnershipPopup(communityId, communityName) {
        openPopup(declineOwnershipPopup, { communityName: communityName, communityId: communityId })
    }

    function openFirstTokenReceivedPopup(communityId, communityName, communityLogo, tokenSymbol, tokenName, tokenAmount, tokenType, tokenImage) {
        openPopup(firstTokenReceivedPopup,
                  {
                      communityId: communityId,
                      communityName: communityName,
                      communityLogo: communityLogo,
                      tokenSymbol: tokenSymbol,
                      tokenName: tokenName,
                      tokenAmount: tokenAmount,
                      tokenType: tokenType,
                      tokenImage: tokenImage
                  })
    }

    function openConfirmHideAssetPopup(assetSymbol, assetName, assetImage, isCommunityToken) {
        openPopup(confirmHideAssetPopup, { assetSymbol, assetName, assetImage, isCommunityToken })
    }

    function openConfirmHideCollectiblePopup(collectibleSymbol, collectibleName, collectibleImage, isCommunityToken) {
        openPopup(confirmHideCollectiblePopup, { collectibleSymbol, collectibleName, collectibleImage, isCommunityToken })
    }

    function openCommunityMemberMessagesPopup(store, chatCommunitySectionModule, memberPubKey, displayName) {
        openPopup(communityMemberMessagesPopup, {
            store: store,
            chatCommunitySectionModule: chatCommunitySectionModule,
            memberPubKey: memberPubKey,
            displayName: displayName
        })
    }

    function openSwapModal(parameters) {
        openPopup(swapModal, {swapInputParamsForm: parameters})
    }

    function openBuyCryptoModal() {
        openPopup(buyCryptoModal)
    }

    readonly property list<Component> _components: [
        Component {
            id: removeContactConfirmationDialog
            RemoveContactPopup {
                onAccepted: {
                    rootStore.contactStore.removeContact(publicKey)
                    if (removeIDVerification)
                        rootStore.contactStore.removeTrustVerificationStatus(publicKey)
                    if (markAsUntrusted) {
                        rootStore.contactStore.markUntrustworthy(publicKey)
                        Global.displaySuccessToastMessage(qsTr("%1 removed from contacts and marked as untrusted").arg(mainDisplayName))
                    } else {
                        Global.displaySuccessToastMessage(qsTr("%1 removed from contacts").arg(mainDisplayName))
                    }
                    close()
                }
                onClosed: destroy()
            }
        },
        Component {
            id: contactVerificationRequestPopupComponent
            ContactVerificationRequestPopup {
                contactsStore: rootStore.contactStore
                onResponseSent: (senderPublicKey, response) => {
                    contactsStore.acceptVerificationRequest(senderPublicKey, response)
                    Global.displaySuccessToastMessage(qsTr("ID verification reply sent"))
                }
                onVerificationRefused: (senderPublicKey) => {
                    contactsStore.declineVerificationRequest(senderPublicKey)
                    Global.displaySuccessToastMessage(qsTr("ID verification request declined"))
                }
                onClosed: destroy()
            }
        },

        Component {
            id: contactOutgoingVerificationRequestPopupComponent
            OutgoingContactVerificationRequestPopup {
                onVerificationRequestCanceled: {
                    rootStore.contactStore.cancelVerificationRequest(publicKey)
                }
                onUntrustworthyVerified: {
                    rootStore.contactStore.verifiedUntrustworthy(publicKey)
                    Global.displaySuccessToastMessage(qsTr("%1 marked as untrusted").arg(mainDisplayName))
                }
                onTrustedVerified: {
                    rootStore.contactStore.verifiedTrusted(publicKey)
                    Global.displaySuccessToastMessage(qsTr("%1 ID verified").arg(mainDisplayName))
                }
                onClosed: destroy()
            }
        },

        Component {
            id: sendIDRequestPopupComponent
            SendContactRequestModal {
                rootStore: root.rootStore
                onAccepted: rootStore.contactStore.sendVerificationRequest(publicKey, message)
                onClosed: destroy()
            }
        },

        Component {
            id: markAsIDVerifiedPopupComponent
            MarkAsIDVerifiedDialog {
                onAccepted: {
                    rootStore.contactStore.markAsTrusted(publicKey)
                    Global.displaySuccessToastMessage(qsTr("%1 ID verified").arg(mainDisplayName))
                    close()
                }
                onClosed: destroy()
            }
        },

        Component {
            id: removeIDVerificationPopupComponent
            RemoveIDVerificationDialog {
                onAccepted: {
                    rootStore.contactStore.removeTrustVerificationStatus(publicKey)

                    if (markAsUntrusted && removeContact) {
                        rootStore.contactStore.markUntrustworthy(publicKey)
                        rootStore.contactStore.removeContact(publicKey)
                        Global.displaySuccessToastMessage(qsTr("%1 ID verification removed, removed from contacts and marked as untrusted").arg(mainDisplayName))
                    } else if (markAsUntrusted) {
                        rootStore.contactStore.markUntrustworthy(publicKey)
                        Global.displaySuccessToastMessage(qsTr("%1 ID verification removed and marked as untrusted").arg(mainDisplayName))
                    } else if (removeContact) {
                        rootStore.contactStore.removeContact(publicKey)
                        Global.displaySuccessToastMessage(qsTr("%1 ID verification removed and removed from contacts").arg(mainDisplayName))
                    } else {
                        Global.displaySuccessToastMessage(qsTr("%1 ID verification removed").arg(mainDisplayName))
                    }
                    close()
                }
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
                onAccepted: rootStore.contactStore.sendContactRequest(publicKey, message)
                onClosed: destroy()
            }
        },

        Component {
            id: reviewContactRequestPopupComponent
            ReviewContactRequestPopup {
                onAccepted: {
                    rootStore.contactStore.acceptContactRequest(publicKey, contactRequestId)
                    Global.displaySuccessToastMessage(qsTr("Contact request accepted"))
                    close()
                }
                onDiscarded: {
                    rootStore.contactStore.dismissContactRequest(publicKey, contactRequestId)
                    Global.displaySuccessToastMessage(qsTr("Contact request ignored"))
                    close()
                }
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
            id: videoPopupComponent
            StatusVideoModal {
                id: videoPopup
                onClosed: destroy()
            }
        },

        Component {
            id: profilePopupComponent
            ProfileDialog {
                id: profilePopup

                property bool isCurrentUser: publicKey === rootStore.profileSectionStore.profileStore.pubkey

                profileStore: rootStore.profileSectionStore.profileStore
                contactsStore: rootStore.profileSectionStore.contactsStore
                sendToAccountEnabled: root.networkConnectionStore.sendBuyBridgeEnabled

                showcaseCommunitiesModel: isCurrentUser ? rootStore.profileSectionStore.ownShowcaseCommunitiesModel : rootStore.profileSectionStore.contactShowcaseCommunitiesModel
                showcaseAccountsModel: isCurrentUser ? rootStore.profileSectionStore.ownShowcaseAccountsModel : rootStore.profileSectionStore.contactShowcaseAccountsModel
                showcaseCollectiblesModel: isCurrentUser ? rootStore.profileSectionStore.ownShowcaseCollectiblesModel : rootStore.profileSectionStore.contactShowcaseCollectiblesModel
                showcaseSocialLinksModel: isCurrentUser ? rootStore.profileSectionStore.ownShowcaseSocialLinksModel : rootStore.profileSectionStore.contactShowcaseSocialLinksModel
                
                assetsModel: rootStore.globalAssetsModel
                collectiblesModel: rootStore.globalCollectiblesModel

                onOpened: {
                    isCurrentUser ? rootStore.profileSectionStore.requestOwnShowcase()
                                  : rootStore.profileSectionStore.requestContactShowcase(publicKey)
                }
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
                        rootStore.contactStore.changeContactNickname(publicKey, newNickname, optionalDisplayName, !!nickname)
                    }
                    close()
                }
                onRemoveNicknameRequested: {
                    rootStore.contactStore.changeContactNickname(publicKey, "", optionalDisplayName, true)
                    close()
                }
                onClosed: destroy()
            }
        },

        Component {
            id: markAsUntrustedComponent
            MarkAsUntrustedPopup {
                onAccepted: {
                    rootStore.contactStore.markUntrustworthy(publicKey)
                    if (removeContact) {
                        rootStore.contactStore.removeContact(publicKey)
                        Global.displaySuccessToastMessage(qsTr("%1 removed from contacts and marked as untrusted").arg(mainDisplayName))
                    } else {
                        Global.displaySuccessToastMessage(qsTr("%1 marked as untrusted").arg(mainDisplayName))
                    }
                    close()
                }
                onClosed: destroy()
            }
        },

        Component {
            id: unblockContactConfirmationComponent
            UnblockContactConfirmationDialog {
                onAccepted: {
                    rootStore.contactStore.unblockContact(publicKey)
                    Global.displaySuccessToastMessage(qsTr("%1 unblocked").arg(mainDisplayName))
                    close()
                }
                onClosed: destroy()
            }
        },

        Component {
            id: blockContactConfirmationComponent
            BlockContactConfirmationDialog {
                onAccepted: {
                    rootStore.contactStore.blockContact(publicKey)
                    if (removeIDVerification)
                        rootStore.contactStore.removeTrustVerificationStatus(publicKey)
                    if (removeContact)
                        rootStore.contactStore.removeContact(publicKey)
                    Global.displaySuccessToastMessage(qsTr("%1 blocked").arg(mainDisplayName))
                    close()
                }
                onClosed: destroy()
            }
        },

        Component {
            id: importCommunitiesPopupComponent
            ImportCommunityPopup {
                store: root.communitiesStore
                onJoinCommunityRequested: {
                    close()
                    openCommunityIntroPopup(communityId,
                                            communityDetails.name,
                                            communityDetails.introMessage,
                                            communityDetails.image,
                                            communityDetails.access,
                                            root.rootStore.isMyCommunityRequestPending(communityId))
                }
                onClosed: destroy()
            }
        },

        Component {
            id: communityJoinDialogPopup

            CommunityMembershipSetupDialog {
                id: dialogRoot

                requirementsCheckPending: root.rootStore.requirementsCheckPending
                checkingPermissionToJoinInProgress: root.rootStore.checkingPermissionToJoinInProgress
                joinPermissionsCheckCompletedWithoutErrors: root.rootStore.joinPermissionsCheckCompletedWithoutErrors

                walletAccountsModel: root.rootStore.walletAccountsModel
                walletCollectiblesModel: WalletStore.RootStore.collectiblesStore.allCollectiblesModel

                canProfileProveOwnershipOfProvidedAddressesFn: WalletStore.RootStore.canProfileProveOwnershipOfProvidedAddresses

                walletAssetsModel: walletAssetsStore.groupedAccountAssetsModel
                permissionsModel: {
                    root.rootStore.prepareTokenModelForCommunity(dialogRoot.communityId)
                    return root.rootStore.permissionsModel
                }
                assetsModel: root.rootStore.assetsModel
                collectiblesModel: root.rootStore.collectiblesModel

                getCurrencyAmount: function (balance, symbol) {
                    return currencyStore.getCurrencyAmount(balance, symbol)
                }

                onPrepareForSigning: {
                    root.rootStore.prepareKeypairsForSigning(dialogRoot.communityId, dialogRoot.name, sharedAddresses, airdropAddress, false)

                    dialogRoot.keypairSigningModel = root.rootStore.communitiesModuleInst.keypairsSigningModel
                }

                onSignProfileKeypairAndAllNonKeycardKeypairs: {
                    root.rootStore.signProfileKeypairAndAllNonKeycardKeypairs()
                }

                onSignSharedAddressesForKeypair: {
                    root.rootStore.signSharedAddressesForKeypair(keyUid)
                }

                onJoinCommunity: {
                    root.rootStore.joinCommunityOrEditSharedAddresses()
                }

                onCancelMembershipRequest: {
                    root.rootStore.cancelPendingRequest(dialogRoot.communityId)
                }

                Connections {
                    target: root.communitiesStore.communitiesModuleInst
                    function onCommunityAccessRequested(communityId: string) {
                        if (communityId !== dialogRoot.communityId)
                            return
                        root.communitiesStore.spectateCommunity(communityId);
                        dialogRoot.close();
                    }
                    function onCommunityAccessFailed(communityId: string, error: string) {
                        if (communityId !== dialogRoot.communityId)
                            return
                        dialogRoot.close();
                    }
                }

                onSharedAddressesUpdated: {
                    root.rootStore.updatePermissionsModel(dialogRoot.communityId, sharedAddresses)
                }

                onAboutToShow: { root.rootStore.communityKeyToImport = dialogRoot.communityId; }

                onClosed: {
                    root.rootStore.communityKeyToImport = "";
                    root.rootStore.cleanJoinEditCommunityData()
                }

                Connections {
                    target: root.rootStore.communitiesModuleInst

                    function onAllSharedAddressesSigned() {
                        if (dialogRoot.profileProvesOwnershipOfSelectedAddresses) {
                            dialogRoot.joinCommunity()
                            dialogRoot.close()
                            return
                        }

                        if (dialogRoot.allAddressesToRevealBelongToSingleNonProfileKeypair) {
                            dialogRoot.joinCommunity()
                            dialogRoot.close()
                            return
                        }

                        if (!!dialogRoot.replaceItem) {
                            dialogRoot.replaceLoader.item.allSigned()
                        }
                    }
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
        },

        Component {
            id: exportControlNodePopup
            ExportControlNodePopup {
                devicesStore: root.devicesStore
                onClosed: destroy()
            }
        },

        Component {
            id: importControlNodePopup
            ImportControlNodePopup {
                onClosed: destroy()
                onImportControlNode: root.rootStore.promoteSelfToControlNode(community.id)
            }
        },

        Component {
            id: editSharedAddressesPopupComponent

            CommunityMembershipSetupDialog {
                id: editSharedAddressesPopup

                readonly property var chatStore: ChatStore.RootStore {
                    contactsStore: root.rootStore.contactStore
                    chatCommunitySectionModule: {
                        root.rootStore.mainModuleInst.prepareCommunitySectionModuleForCommunityId(editSharedAddressesPopup.communityId)
                        return root.rootStore.mainModuleInst.getCommunitySectionModule()
                    }
                }

                isEditMode: true

                currentSharedAddresses: root.rootStore.myRevealedAddressesForCurrentCommunity
                currentAirdropAddress: root.rootStore.myRevealedAirdropAddressForCurrentCommunity

                communityName: chatStore.sectionDetails.name
                communityIcon: chatStore.sectionDetails.image

                requirementsCheckPending: root.rootStore.requirementsCheckPending
                checkingPermissionToJoinInProgress: root.rootStore.checkingPermissionToJoinInProgress
                joinPermissionsCheckCompletedWithoutErrors: root.rootStore.joinPermissionsCheckCompletedWithoutErrors

                introMessage: chatStore.sectionDetails.introMessage

                canProfileProveOwnershipOfProvidedAddressesFn: WalletStore.RootStore.canProfileProveOwnershipOfProvidedAddresses

                walletAccountsModel: root.rootStore.walletAccountsModel

                walletAssetsModel: walletAssetsStore.groupedAccountAssetsModel
                walletCollectiblesModel: WalletStore.RootStore.collectiblesStore.allCollectiblesModel

                permissionsModel: {
                    root.rootStore.prepareTokenModelForCommunity(editSharedAddressesPopup.communityId)
                    return root.rootStore.permissionsModel
                }
                assetsModel: chatStore.assetsModel
                collectiblesModel: chatStore.collectiblesModel

                getCurrencyAmount: function (balance, symbol) {
                    return root.currencyStore.getCurrencyAmount(balance, symbol)
                }

                onSharedAddressesUpdated: {
                    root.rootStore.updatePermissionsModel(editSharedAddressesPopup.communityId, sharedAddresses)
                }

                onPrepareForSigning: {
                    root.rootStore.prepareKeypairsForSigning(editSharedAddressesPopup.communityId, "", sharedAddresses, airdropAddress, true)

                    editSharedAddressesPopup.keypairSigningModel = root.rootStore.communitiesModuleInst.keypairsSigningModel
                }

                onSignProfileKeypairAndAllNonKeycardKeypairs: {
                    root.rootStore.signProfileKeypairAndAllNonKeycardKeypairs()
                }

                onSignSharedAddressesForKeypair: {
                    root.rootStore.signSharedAddressesForKeypair(keyUid)
                }

                onEditRevealedAddresses: {
                    root.rootStore.joinCommunityOrEditSharedAddresses()
                }

                onClosed: {
                    root.rootStore.cleanJoinEditCommunityData()
                }

                Connections {
                    target: root.rootStore.communitiesModuleInst

                    function onAllSharedAddressesSigned() {
                        if (editSharedAddressesPopup.profileProvesOwnershipOfSelectedAddresses) {
                            editSharedAddressesPopup.editRevealedAddresses()
                            editSharedAddressesPopup.close()
                            return
                        }

                        if (editSharedAddressesPopup.allAddressesToRevealBelongToSingleNonProfileKeypair) {
                            editSharedAddressesPopup.editRevealedAddresses()
                            editSharedAddressesPopup.close()
                            return
                        }

                        if (!!editSharedAddressesPopup.replaceItem) {
                            editSharedAddressesPopup.replaceLoader.item.allSigned()
                        }
                    }
                }
            }
        },

        Component {
            id: transferOwnershipPopup
            TransferOwnershipPopup {
                onClosed: destroy()
            }
        },

        Component {
            id: confirmExternalLinkPopup
            ConfirmExternalLinkPopup {
                destroyOnClose: true
                onOpenExternalLink: root.openExternalLink(link)
                onSaveDomainToUnfurledWhitelist: root.saveDomainToUnfurledWhitelist(domain)
            }
        },

        // Components related to transfer community ownership flow:
        Component {
            id: finaliseOwnershipPopup
            FinaliseOwnershipPopup {
                id: finalisePopup

                property string communityId
                readonly property var ownerTokenDetails: root.communityTokensStore.ownerTokenDetails
                readonly property var communityData : root.communitiesStore.getCommunityDetailsAsJson(communityId)

                Component.onCompleted: root.communityTokensStore.asyncGetOwnerTokenDetails(communityId)

                communityName: communityData.name
                communityLogo: communityData.image
                communityColor: communityData.color

                tokenSymbol: ownerTokenDetails.symbol
                tokenChainName: ownerTokenDetails.chainName

                feeText: feeSubscriber.feeText
                feeErrorText: feeSubscriber.feeErrorText
                isFeeLoading: !feeSubscriber.feesResponse

                accounts: WalletStore.RootStore.nonWatchAccounts

                destroyOnClose: true

                onRejectClicked: Global.openDeclineOwnershipPopup(finalisePopup.communityId, communityData.name)
                onFinaliseOwnershipClicked: signPopup.open()

                onVisitCommunityClicked: communitiesStore.navigateToCommunity(finalisePopup.communityId)
                onOpenControlNodeDocClicked: Global.openLink(link)

                SetSignerFeesSubscriber {
                    id: feeSubscriber

                    readonly property TransactionFeesBroker feesBroker: TransactionFeesBroker {
                        communityTokensStore: root.communityTokensStore
                    }

                    chainId: finalisePopup.ownerTokenDetails.chainId
                    contractAddress: finalisePopup.ownerTokenDetails.contractAddress
                    accountAddress: finalisePopup.ownerTokenDetails.accountAddress
                    enabled: finalisePopup.visible || signPopup.visible
                    Component.onCompleted: feesBroker.registerSetSignerFeesSubscriber(feeSubscriber)
                }

                SignTransactionsPopup {
                    id: signPopup

                    title: qsTr("Sign transaction - update %1 smart contract").arg(finalisePopup.communityName)
                    totalFeeText: finalisePopup.isFeeLoading ? "" : finalisePopup.feeText
                    errorText: finalisePopup.feeErrorText
                    accountName: finalisePopup.ownerTokenDetails.accountName

                    model: QtObject {
                        readonly property string title: finalisePopup.feeLabel
                        readonly property string feeText: signPopup.totalFeeText
                        readonly property bool error: finalisePopup.feeErrorText !== ""
                    }

                    onSignTransactionClicked: {
                        finalisePopup.close()
                        root.communityTokensStore.updateSmartContract(finalisePopup.communityId, finalisePopup.ownerTokenDetails.chainId, finalisePopup.ownerTokenDetails.contractAddress, finalisePopup.ownerTokenDetails.accountAddress)
                    }
                }

                Connections {
                    target: root
                    function onOwnershipDeclined(communityId: string, communityName: string) {
                        finalisePopup.close()
                        root.communityTokensStore.ownershipDeclined(communityId, communityName)
                    }
                }
            }
        },

        Component {
            id: declineOwnershipPopup
            FinaliseOwnershipDeclinePopup {
                destroyOnClose: true

                onDeclineClicked: root.ownershipDeclined(communityId, communityName)
            }
        },
        // End of components related to transfer community ownership flow.

        Component {
            id: firstTokenReceivedPopup

            FirstTokenReceivedPopup {
                destroyOnClose: true
                communitiesStore: root.communitiesStore

                onHideClicked: (tokenSymbol, tokenName, tokenImage, isAsset) => isAsset ? root.openConfirmHideAssetPopup(tokenSymbol, tokenName, tokenImage)
                                                                                        : root.openConfirmHideCollectiblePopup(tokenSymbol, tokenName, tokenImage)
            }
        },
        Component {
            id: confirmHideAssetPopup
            ConfirmationDialog {

                property string assetSymbol
                property string assetName
                property string assetImage
                property bool isCommunityToken

                width: 520
                destroyOnClose: true
                confirmButtonLabel: qsTr("Hide asset")
                cancelBtnType: ""
                showCancelButton: true
                headerSettings.title: qsTr("Hide %1 (%2)").arg(assetName).arg(assetSymbol)
                headerSettings.asset.name: assetImage
                confirmationText: qsTr("Are you sure you want to hide %1 (%2)? You will no longer see or be able to interact with this asset anywhere inside Status.").arg(assetName).arg(assetSymbol)
                onCancelButtonClicked: close()
                onConfirmButtonClicked: {
                    if (isCommunityToken)
                        root.walletAssetsStore.assetsController.showHideCommunityToken(assetSymbol, false)
                    else
                        root.walletAssetsStore.assetsController.showHideRegularToken(assetSymbol, false)
                    close()
                    Global.displayToastMessage(qsTr("%1 (%2) successfully hidden. You can toggle asset visibility via %3.").arg(assetName).arg(assetSymbol)
                                               .arg(`<a style="text-decoration:none" href="#${Constants.appSection.profile}/${Constants.settingsSubsection.wallet}/${Constants.walletSettingsSubsection.manageHidden}">` + qsTr("Settings", "Go to Settings") + "</a>"),
                                               "",
                                               "checkmark-circle",
                                               false,
                                               Constants.ephemeralNotificationType.success,
                                               "")
                }
            }
        },
        Component {
            id: confirmHideCollectiblePopup
            ConfirmationDialog {

                property string collectibleSymbol
                property string collectibleName
                property string collectibleImage
                property bool isCommunityToken

                width: 520
                destroyOnClose: true
                confirmButtonLabel: qsTr("Hide collectible")
                cancelBtnType: ""
                showCancelButton: true
                headerSettings.title: qsTr("Hide %1").arg(collectibleName)
                headerSettings.asset.name: collectibleImage
                headerSettings.asset.bgRadius: Style.current.radius
                confirmationText: qsTr("Are you sure you want to hide %1? You will no longer see or be able to interact with this collectible anywhere inside Status.").arg(collectibleName)
                onCancelButtonClicked: close()
                onConfirmButtonClicked: {
                    if (isCommunityToken)
                        root.walletCollectiblesStore.collectiblesController.showHideCommunityToken(collectibleSymbol, false)
                    else
                        root.walletCollectiblesStore.collectiblesController.showHideRegularToken(collectibleSymbol, false)
                    close()
                    Global.displayToastMessage(qsTr("%1 successfully hidden. You can toggle collectible visibility via %2.").arg(collectibleName)
                                               .arg(`<a style="text-decoration:none" href="#${Constants.appSection.profile}/${Constants.settingsSubsection.wallet}/${Constants.walletSettingsSubsection.manageHidden}">` + qsTr("Settings", "Go to Settings") + "</a>"),
                                               "",
                                               "checkmark-circle",
                                               false,
                                               Constants.ephemeralNotificationType.success,
                                               "")
                }
            }
        },
        Component {
            id: communityMemberMessagesPopup
            CommunityMemberMessagesPopup {
                onClosed: destroy()
            }
        },
        Component {
            id: swapModal
            SwapModal {
                swapAdaptor: SwapModalAdaptor {
                    swapStore: WalletStore.SwapStore {}
                    walletAssetsStore: root.walletAssetsStore
                    currencyStore: root.currencyStore
                    swapFormData: swapInputParamsForm
                    swapOutputData: SwapOutputData{}
                }
                loginType: root.rootStore.loginType
                onClosed: destroy()
            }
        },
        Component {
            id: buyCryptoModal
            BuyCryptoModal {
                onRampProvidersModel: WalletStore.RootStore.cryptoRampServicesModel
                onClosed: destroy()
            }
        }
    ]
}
