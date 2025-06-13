import QtCore
import QtQml
import QtQuick

import QtQuick.Controls
import QtQuick.Window
import QtQuick.Layouts
import QtQml.Models

import AppLayouts.Wallet
import AppLayouts.Node
import AppLayouts.Chat
import AppLayouts.Chat.views
import AppLayouts.Profile
import AppLayouts.Communities
import AppLayouts.Market
import AppLayouts.Market.stores
import AppLayouts.Wallet.services.dapps
import AppLayouts.HomePage

import utils
import shared
import shared.controls
import shared.controls.chat.menuItems
import shared.panels
import shared.popups
import shared.popups.keycard
import shared.status
import shared.stores as SharedStores
import shared.popups.send as SendPopups
import shared.popups.send.views
import shared.stores.send

import StatusQ
import StatusQ.Core
import StatusQ.Core.Theme
import StatusQ.Core.Utils as SQUtils
import StatusQ.Components
import StatusQ.Components.private
import StatusQ.Controls
import StatusQ.Layout
import StatusQ.Popups
import StatusQ.Popups.Dialog

import AppLayouts.Chat.stores as ChatStores
import AppLayouts.Communities.stores
import AppLayouts.Profile.stores as ProfileStores
import AppLayouts.Wallet.popups as WalletPopups
import AppLayouts.Wallet.popups.dapps as DAppsPopups
import AppLayouts.Wallet.stores as WalletStores
import AppLayouts.stores as AppStores

import mainui.adaptors
import mainui.activitycenter.stores
import mainui.activitycenter.popups
import mainui.Handlers

import QtModelsToolkit
import SortFilterProxyModel

Item {
    id: appMain

    readonly property SharedStores.RootStore sharedRootStore: SharedStores.RootStore {
        currencyStore: appMain.currencyStore
    }

    property SharedStores.UtilsStore utilsStore

    readonly property SharedStores.NetworksStore networksStore: SharedStores.NetworksStore {}
    
    readonly property AppStores.RootStore rootStore: AppStores.RootStore {
        onOpenUrl: {
            Global.openLinkWithConfirmation(link, SQUtils.StringUtils.extractDomainFromLink(link))
        }
    }

    readonly property ProfileStores.AboutStore aboutStore: rootStore.profileSectionStore.aboutStore
    readonly property ProfileStores.ProfileStore profileStore: rootStore.profileSectionStore.profileStore
    readonly property ProfileStores.ContactsStore contactsStore: rootStore.profileSectionStore.contactsStore
    readonly property ProfileStores.DevicesStore devicesStore: rootStore.profileSectionStore.devicesStore
    readonly property ProfileStores.AdvancedStore advancedStore: rootStore.profileSectionStore.advancedStore
    readonly property ProfileStores.PrivacyStore privacyStore: rootStore.profileSectionStore.privacyStore
    readonly property ProfileStores.NotificationsStore notificationsStore: rootStore.profileSectionStore.notificationsStore
    readonly property ProfileStores.LanguageStore languageStore: rootStore.profileSectionStore.languageStore
    readonly property ProfileStores.KeycardStore keycardStore: rootStore.profileSectionStore.keycardStore
    readonly property ProfileStores.WalletStore walletProfileStore: rootStore.profileSectionStore.walletStore
    readonly property ProfileStores.MessagingStore messagingStore: rootStore.profileSectionStore.messagingStore
    readonly property ProfileStores.EnsUsernamesStore ensUsernamesStore: rootStore.profileSectionStore.ensUsernamesStore

    property ChatStores.RootStore rootChatStore: ChatStores.RootStore {
        contactsStore: appMain.rootStore.contactStore
        currencyStore: appMain.currencyStore
        communityTokensStore: appMain.communityTokensStore
        emojiReactionsModel: appMain.rootStore.emojiReactionsModel
        openCreateChat: createChatView.opened
        networkConnectionStore: appMain.networkConnectionStore
    }
    property ChatStores.CreateChatPropertiesStore createChatPropertiesStore: ChatStores.CreateChatPropertiesStore {}
    property ActivityCenterStore activityCenterStore: ActivityCenterStore {}
    property SharedStores.NetworkConnectionStore networkConnectionStore: SharedStores.NetworkConnectionStore {
        networksStore: appMain.networksStore
    }
    property SharedStores.CommunityTokensStore communityTokensStore: SharedStores.CommunityTokensStore {
        currencyStore: appMain.currencyStore
    }
    property CommunitiesStore communitiesStore: CommunitiesStore {}
    readonly property WalletStores.TokensStore tokensStore: WalletStores.RootStore.tokensStore
    readonly property WalletStores.WalletAssetsStore walletAssetsStore: WalletStores.RootStore.walletAssetsStore
    readonly property WalletStores.CollectiblesStore walletCollectiblesStore: WalletStores.RootStore.collectiblesStore
    readonly property SharedStores.CurrenciesStore currencyStore: SharedStores.CurrenciesStore {}
    readonly property TransactionStore transactionStore: TransactionStore {
        walletAssetStore: appMain.walletAssetsStore
        tokensStore: appMain.tokensStore
        currencyStore: appMain.currencyStore
        networksStore: appMain.networksStore
    }
    readonly property WalletStores.BuyCryptoStore buyCryptoStore: WalletStores.BuyCryptoStore {}

    required property AppStores.FeatureFlagsStore featureFlagsStore
    // TODO: Only until the  old send modal transaction store can be replaced with this one
    readonly property WalletStores.TransactionStoreNew transactionStoreNew: WalletStores.TransactionStoreNew {}

    readonly property MarketStore marketStore: MarketStore {}

    required property Keychain keychain

    required property bool isCentralizedMetricsEnabled

    AllContactsAdaptor {
        id: allContacsAdaptor

        contactsModel: appMain.rootStore.contactStore.contactsModel

        selfPubKey: appMain.profileStore.pubKey
        selfDisplayName : appMain.profileStore.displayName
        selfName: appMain.profileStore.name
        selfPreferredDisplayName: appMain.profileStore.preferredName
        selfAlias: appMain.profileStore.username
        selfUsesDefaultName: appMain.profileStore.usesDefaultName
        selfIcon: appMain.profileStore.icon
        selfColorId: appMain.profileStore.colorId
        selfColorHash: appMain.profileStore.colorHash
        selfOnlineStatus: appMain.profileStore.currentUserStatus
        selfThumbnailImage: appMain.profileStore.thumbnailImage
        selfLargeImage: appMain.profileStore.largeImage
        selfBio: appMain.profileStore.bio
    }

    ContactsModelAdaptor {
        id: contactsModelAdaptor

        allContacts: appMain.contactsStore.contactsModel
    }

    // Central UI point for managing app toasts:
    ToastsManager {
        id: toastsManager

        rootStore: appMain.rootStore
        rootChatStore: appMain.rootChatStore
        communityTokensStore: appMain.communityTokensStore
        profileStore: appMain.profileStore

        onSendRequested: popupRequestsHandler.sendModalHandler.openSend()
    }

    Connections {
        target: rootStore.mainModuleInst

        function onDisplayUserProfile(publicKey: string) {
            popups.openProfilePopup(publicKey)
        }

        function onDisplayKeycardSharedModuleForAuthenticationOrSigning() {
            keycardPopupForAuthenticationOrSigning.active = true
        }

        function onDestroyKeycardSharedModuleForAuthenticationOrSigning() {
            keycardPopupForAuthenticationOrSigning.active = false
        }

        function onDisplayKeycardSharedModuleFlow() {
            keycardPopup.active = true
        }

        function onDestroyKeycardSharedModuleFlow() {
            keycardPopup.active = false
        }

        function onPlayNotificationSound() {
            notificationSound.stop()
            notificationSound.play()
        }

        function onMailserverWorking() {
            mailserverConnectionBanner.hide()
        }

        function onMailserverNotWorking() {
            mailserverConnectionBanner.show()
        }

        function onActiveSectionChanged() {
            createChatView.opened = false
            profileLoader.settingsSubSubsection = -1
        }

        function onOpenActivityCenter() {
            d.openActivityCenterPopup()
        }

        function onShowToastAccountAdded(name: string) {
            Global.displayToastMessage(
                qsTr("\"%1\" successfully added").arg(name),
                "",
                "checkmark-circle",
                false,
                Constants.ephemeralNotificationType.success,
                ""
            )
        }

        function onShowToastAccountRemoved(name: string) {
            Global.displayToastMessage(
                        qsTr("\"%1\" successfully removed").arg(name),
                        "",
                        "checkmark-circle",
                        false,
                        Constants.ephemeralNotificationType.success,
                        ""
                        )
        }

        function onShowToastKeypairRenamed(oldName: string, newName: string) {
            Global.displayToastMessage(
                qsTr("You successfully renamed your key pair\nfrom \"%1\" to \"%2\"").arg(oldName).arg(newName),
                "",
                "checkmark-circle",
                false,
                Constants.ephemeralNotificationType.success,
                ""
            )
        }

        function onShowNetworkEndpointUpdated(name: string, isTest: bool) {
            let mainText = isTest ? qsTr("Test network settings for %1 updated").arg(name): qsTr("Live network settings for %1 updated").arg(name)
            Global.displayToastMessage(
                mainText,
                "",
                "checkmark-circle",
                false,
                Constants.ephemeralNotificationType.success,
                ""
            )
        }

        function onShowToastKeypairRemoved(keypairName: string) {
            Global.displayToastMessage(
                qsTr("“%1” key pair and its derived accounts were successfully removed from all devices").arg(keypairName),
                "",
                "checkmark-circle",
                false,
                Constants.ephemeralNotificationType.success,
                ""
            )
        }

        function onShowToastKeypairsImported(keypairName: string, keypairsCount: int, error: string) {
            let notification = qsTr("Please re-generate QR code and try importing again")
            if (error !== "") {
                if (error.startsWith("one or more expected keystore files are not found among the sent files")) {
                    notification = qsTr("Make sure you're importing the exported key pair on paired device")
                }
            }
            else {
                notification = qsTr("%1 key pair successfully imported").arg(keypairName)
                if (keypairsCount > 1) {
                    notification = qsTr("%n key pair(s) successfully imported", "", keypairsCount)
                }
            }
            Global.displayToastMessage(
                notification,
                "",
                error!==""? "info" : "checkmark-circle",
                false,
                error!==""? Constants.ephemeralNotificationType.normal : Constants.ephemeralNotificationType.success,
                ""
            )
        }

        function onShowTransactionToast(uuid: string,
                                        txType: int,
                                        fromChainId: int,
                                        toChainId: int,
                                        fromAddr: string,
                                        fromName: string,
                                        toAddr: string,
                                        toName: string,
                                        txToAddr: string,
                                        txToName: string,
                                        txHash: string,
                                        approvalTx: bool,
                                        fromAmount: string,
                                        toAmount: string,
                                        fromAsset: string,
                                        toAsset: string,
                                        username: string,
                                        publicKey: string,
                                        packId: string,
                                        communityId: string,
                                        communityName: string,
                                        communityInvolvedTokens: int,
                                        communityTotalAmount: string,
                                        communityAmount1: string,
                                        communityAmountInfinite1: bool,
                                        communityAssetName1: string,
                                        communityAssetDecimals1: int,
                                        communityAmount2: string,
                                        communityAmountInfinite2: bool,
                                        communityAssetName2: string,
                                        communityAssetDecimals2: int,
                                        communityInvolvedAddress: string,
                                        communityNubmerOfInvolvedAddresses: int,
                                        communityOwnerTokenName: string,
                                        communityMasterTokenName: string,
                                        communityDeployedTokenName: string,
                                        status: string,
                                        error: string) {

            let toastTitle = ""
            let toastSubtitle = ""
            let toastIcon = ""
            let toastLoading = false
            let toastType = Constants.ephemeralNotificationType.normal
            let toastLink = ""
            let blockExplorerUrl = ""

            const sender = !!fromName? fromName : SQUtils.Utils.elideAndFormatWalletAddress(fromAddr)
            let senderChainName = qsTr("unknown")
            let sentAmount = ""

            const recipient = !!toName? toName : SQUtils.Utils.elideAndFormatWalletAddress(toAddr)
            const txRecipient = !!txToName? txToName : SQUtils.Utils.elideAndFormatWalletAddress(txToAddr)
            let recipientChainName = qsTr("unknown")
            let receivedAmount = ""

            let assetName = qsTr("unknown")
            let ensName = d.ensName(username)
            let stickersPackName = qsTr("unknown")

            let sentCommunityAmount1 = ""
            let sentCommunityAmount2 = ""

            const fromChain = SQUtils.ModelUtils.getByKey(appMain.networksStore.activeNetworks, "chainId", fromChainId)
            if (!!fromChain) {
                senderChainName = fromChain.chainName
                blockExplorerUrl = fromChain.blockExplorerURL
            }
            const toChainName = SQUtils.ModelUtils.getByKey(appMain.networksStore.activeNetworks, "chainId", toChainId, "chainName")
            if (!!toChainName) {
                recipientChainName = toChainName
            }

            const fromToken = SQUtils.ModelUtils.getByKey(appMain.tokensStore.plainTokensBySymbolModel, "key", fromAsset)
            if (!!fromToken) {
                sentAmount = currencyStore.formatCurrencyAmountFromBigInt(fromAmount, fromToken.symbol, fromToken.decimals)
            }

            const toToken = SQUtils.ModelUtils.getByKey(appMain.tokensStore.plainTokensBySymbolModel, "key", toAsset)
            if (!!toToken) {
                receivedAmount = currencyStore.formatCurrencyAmountFromBigInt(toAmount, toToken.symbol, toToken.decimals)
            }

            if (!!txHash) {
                toastLink = "%1/tx/%2".arg(blockExplorerUrl).arg(txHash)
                toastSubtitle = qsTr("View on %1").arg(senderChainName)
            }

            if (txType === Constants.SendType.ERC721Transfer || txType === Constants.SendType.ERC1155Transfer) {
                const key = "%1+%2+%3".arg(fromChainId).arg(txToAddr).arg(fromAsset)
                const entry = SQUtils.ModelUtils.getByKey(appMain.walletCollectiblesStore.allCollectiblesModel, "symbol", key)
                if (!!entry) {
                    assetName = entry.name
                }
            }

            if (txType === Constants.SendType.StickersBuy) {
                const idx = appMain.rootChatStore.stickersModuleInst.stickerPacks.findIndexById(packId, false)
                if(idx >= 0) {
                    const entry = SQUtils.ModelUtils.get(appMain.rootChatStore.stickersModuleInst.stickerPacks, idx)
                    if (!!entry) {
                        stickersPackName = entry.name
                    }
                }
            }

            if (!!communityAmount1) {
                let bigIntCommunityAmount1 = SQUtils.AmountsArithmetic.fromString(communityAmount1)
                sentCommunityAmount1 = SQUtils.AmountsArithmetic.toNumber(bigIntCommunityAmount1, communityAssetDecimals1)
            }

            if (!!communityAmount2) {
                let bigIntCommunityAmount2 = SQUtils.AmountsArithmetic.fromString(communityAmount2)
                sentCommunityAmount2 = SQUtils.AmountsArithmetic.toNumber(bigIntCommunityAmount2, communityAssetDecimals2)
            }

            switch(status) {
            case Constants.txStatus.sending: {
                toastTitle = qsTr("Sending %1 from %2 to %3")
                toastLoading = true

                switch(txType) {
                case Constants.SendType.Transfer: {
                    toastTitle = toastTitle.arg(sentAmount).arg(sender).arg(recipient)
                    break
                }
                case Constants.SendType.ENSRegister: {
                    toastTitle = qsTr("Registering %1 ENS name using %2").arg(ensName).arg(sender)
                    break
                }
                case Constants.SendType.ENSRelease: {
                    toastTitle = qsTr("Releasing %1 ENS username using %2").arg(ensName).arg(sender)
                    break
                }
                case Constants.SendType.ENSSetPubKey: {
                    toastTitle = qsTr("Setting public key %1 using %2").arg(ensName).arg(sender)
                    break
                }
                case Constants.SendType.StickersBuy: {
                    toastTitle = qsTr("Purchasing %1 sticker pack using %2").arg(stickersPackName).arg(sender)
                    break
                }
                case Constants.SendType.Bridge: {
                    toastTitle = qsTr("Bridging %1 from %2 to %3 in %4").arg(sentAmount).arg(senderChainName).arg(recipientChainName).arg(sender)
                    if (approvalTx) {
                        toastTitle = qsTr("Setting spending cap: %1 in %2 for %3").arg(sentAmount).arg(sender).arg(txRecipient)
                    }
                    break
                }
                case Constants.SendType.ERC721Transfer: {
                    toastTitle = toastTitle.arg(assetName).arg(sender).arg(recipient)
                    break
                }
                case Constants.SendType.ERC1155Transfer: {
                    toastTitle = qsTr("Sending %1 %2 from %3 to %4").arg(fromAmount).arg(assetName).arg(sender).arg(recipient)
                    break
                }
                case Constants.SendType.Swap: {
                    toastTitle = qsTr("Swapping %1 to %2 in %3").arg(sentAmount).arg(receivedAmount).arg(sender)
                    if (approvalTx) {
                        toastTitle = qsTr("Setting spending cap: %1 in %2 for %3").arg(sentAmount).arg(sender).arg(txRecipient)
                    }
                    break
                }
                case Constants.SendType.CommunityDeployAssets: {
                    if (communityAmountInfinite1) {
                        toastTitle = qsTr("Minting infinite %1 tokens for %2 using %3").arg(communityDeployedTokenName).arg(communityName).arg(sender)
                    } else {
                        toastTitle = qsTr("Minting %1 %2 tokens for %3 using %4").arg(sentCommunityAmount1).arg(communityDeployedTokenName).arg(communityName).arg(sender)
                    }
                    break
                }
                case Constants.SendType.CommunityDeployCollectibles: {
                    if (communityAmountInfinite1) {
                        toastTitle = qsTr("Minting infinite %1 tokens for %2 using %3").arg(communityDeployedTokenName).arg(communityName).arg(sender)
                    } else {
                        toastTitle = qsTr("Minting %1 %2 tokens for %3 using %4").arg(sentCommunityAmount1).arg(communityDeployedTokenName).arg(communityName).arg(sender)
                    }
                    break
                }
                case Constants.SendType.CommunityDeployOwnerToken: {
                    toastTitle = qsTr("Minting %1 and %2 tokens for %3 using %4").arg(communityOwnerTokenName).arg(communityMasterTokenName).arg(communityName).arg(sender)
                    break
                }
                case Constants.SendType.CommunityMintTokens: {
                    if (!sentCommunityAmount2) {
                        if (communityNubmerOfInvolvedAddresses === 1 && !!communityInvolvedAddress) {
                            toastTitle = qsTr("Airdropping %1x %2 to %3 using %4").arg(sentCommunityAmount1).arg(communityAssetName1).arg(communityInvolvedAddress).arg(sender)
                        } else {
                            toastTitle = qsTr("Airdropping %1x %2 to %3 addresses using %4").arg(sentCommunityAmount1).arg(communityAssetName1).arg(communityNubmerOfInvolvedAddresses).arg(sender)
                        }
                    } else if(communityInvolvedTokens === 2) {
                        if (communityNubmerOfInvolvedAddresses === 1 && !!communityInvolvedAddress) {
                            toastTitle = qsTr("Airdropping %1x %2 and %3x %4 to %5 using %6").arg(sentCommunityAmount1).arg(communityAssetName1).arg(sentCommunityAmount2).arg(communityAssetName2).arg(communityInvolvedAddress).arg(sender)
                        } else {
                            toastTitle = qsTr("Airdropping %1x %2 and %3x %4 to %5 addresses using %6").arg(sentCommunityAmount1).arg(communityAssetName1).arg(sentCommunityAmount2).arg(communityAssetName2).arg(communityNubmerOfInvolvedAddresses).arg(sender)
                        }
                    } else {
                        toastTitle = qsTr("Airdropping %1 tokens to %2 using %3").arg(communityInvolvedTokens).arg(communityInvolvedAddress).arg(sender)
                    }
                    break
                }
                case Constants.SendType.CommunityRemoteBurn: {
                    if (communityNubmerOfInvolvedAddresses === 1 && !!communityInvolvedAddress) {
                        toastTitle = qsTr("Destroying %1x %2 at %3 using %4").arg(sentCommunityAmount1).arg(communityAssetName1).arg(communityInvolvedAddress).arg(sender)
                    } else {
                        toastTitle = qsTr("Destroying %1x %2 at %3 addresses using %4").arg(sentCommunityAmount1).arg(communityAssetName1).arg(communityNubmerOfInvolvedAddresses).arg(sender)
                    }
                    break
                }
                case Constants.SendType.CommunityBurn: {
                    toastTitle = qsTr("Burning %1x %2 for %3 using %4").arg(sentCommunityAmount1).arg(communityAssetName1).arg(communityName).arg(sender)
                    break
                }
                case Constants.SendType.CommunitySetSignerPubKey: {
                    toastTitle = qsTr("Finalizing ownership for %1 using %2").arg(communityName).arg(sender)
                    break
                }
                case Constants.SendType.Approve: {
                    console.warn("tx type approve not yet identified as a stand alone path")
                    break
                }
                default:
                    console.warn("status: sending - tx type not supproted")
                    return
                }
                break
            }
            case Constants.txStatus.pending: {
                // So far we don't display notification when it's accepted by the network and its status is pending
                // discussed in wallet group chat, we considered that pending status will be displayed almost at the
                // same time as sending and decided to skip it.
                return
            }
            case Constants.txStatus.success: {
                toastTitle = qsTr("Sent %1 from %2 to %3")
                toastIcon = "checkmark-circle"
                toastType = Constants.ephemeralNotificationType.success

                switch(txType) {
                case Constants.SendType.Transfer: {
                    toastTitle = toastTitle.arg(sentAmount).arg(sender).arg(recipient)
                    break
                }
                case Constants.SendType.ENSRegister: {
                    toastTitle = qsTr("Registered %1 ENS name using %2").arg(ensName).arg(sender)
                    break
                }
                case Constants.SendType.ENSRelease: {
                    toastTitle = qsTr("Released %1 ENS username using %2").arg(ensName).arg(sender)
                    break
                }
                case Constants.SendType.ENSSetPubKey: {
                    toastTitle = qsTr("Set public key %1 using %2").arg(ensName).arg(sender)
                    break
                }
                case Constants.SendType.StickersBuy: {
                    toastTitle = qsTr("Purchased %1 sticker pack using %2").arg(stickersPackName).arg(sender)
                    break
                }
                case Constants.SendType.Bridge: {
                    toastTitle = qsTr("Bridged %1 from %2 to %3 in %4").arg(sentAmount).arg(senderChainName).arg(recipientChainName).arg(sender)
                    if (approvalTx) {
                        toastTitle = qsTr("Spending spending cap: %1 in %2 for %3").arg(sentAmount).arg(sender).arg(txRecipient)
                    }
                    break
                }
                case Constants.SendType.ERC721Transfer: {
                    toastTitle = toastTitle.arg(assetName).arg(sender).arg(recipient)
                    break
                }
                case Constants.SendType.ERC1155Transfer: {
                    toastTitle = qsTr("Sent %1 %2 from %3 to %4").arg(fromAmount).arg(assetName).arg(sender).arg(recipient)
                    break
                }
                case Constants.SendType.Swap: {
                    toastTitle = qsTr("Swapped %1 to %2 in %3").arg(sentAmount).arg(receivedAmount).arg(sender)
                    if (approvalTx) {
                        toastTitle = qsTr("Spending cap set: %1 in %2 for %3").arg(sentAmount).arg(sender).arg(txRecipient)
                    }
                    break
                }
                case Constants.SendType.CommunityDeployAssets: {
                    if (communityAmountInfinite1){
                        toastTitle = qsTr("Minted infinite %1 tokens for %2 using %3").arg(communityDeployedTokenName).arg(communityName).arg(sender)
                    } else {
                        toastTitle = qsTr("Minted %1 %2 tokens for %3 using %4").arg(sentCommunityAmount1).arg(communityDeployedTokenName).arg(communityName).arg(sender)
                    }
                    break
                }
                case Constants.SendType.CommunityDeployCollectibles: {
                    if (communityAmountInfinite1){
                        toastTitle = qsTr("Minted infinite %1 tokens for %2 using %3").arg(communityDeployedTokenName).arg(communityName).arg(sender)
                    } else {
                        toastTitle = qsTr("Minted %1 %2 tokens for %3 using %4").arg(sentCommunityAmount1).arg(communityDeployedTokenName).arg(communityName).arg(sender)
                    }
                    break
                }
                case Constants.SendType.CommunityDeployOwnerToken: {
                    toastTitle = qsTr("Minted %1 and %2 tokens for %3 using %4").arg(communityOwnerTokenName).arg(communityMasterTokenName).arg(communityName).arg(sender)
                    break
                }
                case Constants.SendType.CommunityMintTokens: {
                    if (!sentCommunityAmount2) {
                        if (communityNubmerOfInvolvedAddresses === 1 && !!communityInvolvedAddress) {
                            toastTitle = qsTr("Airdropped %1x %2 to %3 using %4").arg(sentCommunityAmount1).arg(communityAssetName1).arg(communityInvolvedAddress).arg(sender)
                        } else {
                            toastTitle = qsTr("Airdropped %1x %2 to %3 addresses using %4").arg(sentCommunityAmount1).arg(communityAssetName1).arg(communityNubmerOfInvolvedAddresses).arg(sender)
                        }
                    } else if(communityInvolvedTokens === 2) {
                        if (communityNubmerOfInvolvedAddresses === 1 && !!communityInvolvedAddress) {
                            toastTitle = qsTr("Airdropped %1x %2 and %3x %4 to %5 using %6").arg(sentCommunityAmount1).arg(communityAssetName1).arg(sentCommunityAmount2).arg(communityAssetName2).arg(communityInvolvedAddress).arg(sender)
                        } else {
                            toastTitle = qsTr("Airdropped %1x %2 and %3x %4 to %5 addresses using %6").arg(sentCommunityAmount1).arg(communityAssetName1).arg(sentCommunityAmount2).arg(communityAssetName2).arg(communityNubmerOfInvolvedAddresses).arg(sender)
                        }
                    } else {
                        toastTitle = qsTr("Airdropped %1 tokens to %2 using %3").arg(communityInvolvedTokens).arg(communityInvolvedAddress).arg(sender)
                    }
                    break
                }
                case Constants.SendType.CommunityRemoteBurn: {
                    if (communityNubmerOfInvolvedAddresses === 1 && !!communityInvolvedAddress) {
                        toastTitle = qsTr("Destroyed %1x %2 at %3 using %4").arg(sentCommunityAmount1).arg(communityAssetName1).arg(communityInvolvedAddress).arg(sender)
                    } else {
                        toastTitle = qsTr("Destroyed %1x %2 at %3 addresses using %4").arg(sentCommunityAmount1).arg(communityAssetName1).arg(communityNubmerOfInvolvedAddresses).arg(sender)
                    }
                    break
                }
                case Constants.SendType.CommunityBurn: {
                    toastTitle = qsTr("Burned %1x %2 for %3 using %4").arg(sentCommunityAmount1).arg(communityAssetName1).arg(communityName).arg(sender)
                    break
                }
                case Constants.SendType.CommunitySetSignerPubKey: {
                    toastTitle = qsTr("Finalized ownership for %1 using %2").arg(communityName).arg(sender)
                    break
                }
                case Constants.SendType.Approve: {
                    console.warn("tx type approve not yet identified as a stand alone path")
                    break
                }
                default:
                    console.warn("status: success - tx type not supproted")
                    return
                }
                break
            }
            case Constants.txStatus.failed: {
                toastTitle = qsTr("Send failed: %1 from %2 to %3")
                toastIcon = "warning"
                toastType = Constants.ephemeralNotificationType.danger

                if (!toastSubtitle && !!error) {
                    toastSubtitle = error
                }

                switch(txType) {
                case Constants.SendType.Transfer: {
                    toastTitle = toastTitle.arg(sentAmount).arg(sender).arg(recipient)
                    break
                }
                case Constants.SendType.ENSRegister: {
                    toastTitle = qsTr("ENS username registeration failed: %1 using %2").arg(ensName).arg(sender)
                    break
                }
                case Constants.SendType.ENSRelease: {
                    toastTitle = qsTr("ENS username release failed: %1 using %2").arg(ensName).arg(sender)
                    break
                }
                case Constants.SendType.ENSSetPubKey: {
                    toastTitle = qsTr("Set public key failed: %1 using %2").arg(ensName).arg(sender)
                    break
                }
                case Constants.SendType.StickersBuy: {
                    toastTitle = qsTr("Sticker pack purchase failed: %1 using %2").arg(stickersPackName).arg(sender)
                    break
                }
                case Constants.SendType.Bridge: {
                    toastTitle = qsTr("Bridge failed: %1 from %2 to %3 in %4").arg(sentAmount).arg(senderChainName).arg(recipientChainName).arg(sender)
                    if (approvalTx) {
                        toastTitle = qsTr("Spending spending failed: %1 in %2 for %3").arg(sentAmount).arg(sender).arg(txRecipient)
                    }
                    break
                }
                case Constants.SendType.ERC721Transfer: {
                    toastTitle = toastTitle.arg(assetName).arg(sender).arg(recipient)
                    break
                }
                case Constants.SendType.ERC1155Transfer: {
                    toastTitle = qsTr("Send failed: %1 %2 from %3 to %4").arg(fromAmount).arg(assetName).arg(sender).arg(recipient)
                    break
                }
                case Constants.SendType.Swap: {
                    toastTitle = qsTr("Swap failed: %1 to %2 in %3").arg(sentAmount).arg(receivedAmount).arg(sender)
                    if (approvalTx) {
                        toastTitle = qsTr("Spending cap failed: %1 in %2 for %3").arg(sentAmount).arg(sender).arg(txRecipient)
                    }
                    break
                }
                case Constants.SendType.CommunityDeployAssets: {
                    if (communityAmountInfinite1){
                        toastTitle = qsTr("Mint failed: infinite %1 tokens for %2 using %3").arg(communityDeployedTokenName).arg(communityName).arg(sender)
                    } else {
                        toastTitle = qsTr("Mint failed: %1 %2 tokens for %3 using %4").arg(sentCommunityAmount1).arg(communityDeployedTokenName).arg(communityName).arg(sender)
                    }
                    break
                }
                case Constants.SendType.CommunityDeployCollectibles: {
                    if (communityAmountInfinite1){
                        toastTitle = qsTr("Mint failed: infinite %1 tokens for %2 using %3").arg(communityDeployedTokenName).arg(communityName).arg(sender)
                    } else {
                        toastTitle = qsTr("Mint failed: %1 %2 tokens for %3 using %4").arg(sentCommunityAmount1).arg(communityDeployedTokenName).arg(communityName).arg(sender)
                    }
                    break
                }
                case Constants.SendType.CommunityDeployOwnerToken: {
                    toastTitle = qsTr("Mint failed: %1 and %2 tokens for %3 using %4").arg(communityOwnerTokenName).arg(communityMasterTokenName).arg(communityName).arg(sender)
                    break
                }
                case Constants.SendType.CommunityMintTokens: {
                    if (!sentCommunityAmount2) {
                        if (communityNubmerOfInvolvedAddresses === 1 && !!communityInvolvedAddress) {
                            toastTitle = qsTr("Airdrop failed: %1x %2 to %3 using %4").arg(sentCommunityAmount1).arg(communityAssetName1).arg(communityInvolvedAddress).arg(sender)
                        } else {
                            toastTitle = qsTr("Airdrop failed: %1x %2 to %3 addresses using %4").arg(sentCommunityAmount1).arg(communityAssetName1).arg(communityNubmerOfInvolvedAddresses).arg(sender)
                        }
                    } else if(communityInvolvedTokens === 2) {
                        if (communityNubmerOfInvolvedAddresses === 1 && !!communityInvolvedAddress) {
                            toastTitle = qsTr("Airdrop failed: %1x %2 and %3x %4 to %5 using %6").arg(sentCommunityAmount1).arg(communityAssetName1).arg(sentCommunityAmount2).arg(communityAssetName2).arg(communityInvolvedAddress).arg(sender)
                        } else {
                            toastTitle = qsTr("Airdrop failed: %1x %2 and %3x %4 to %5 addresses using %6").arg(sentCommunityAmount1).arg(communityAssetName1).arg(sentCommunityAmount2).arg(communityAssetName2).arg(communityNubmerOfInvolvedAddresses).arg(sender)
                        }
                    } else {
                        toastTitle = qsTr("Airdrop failed: %1 tokens to %2 using %3").arg(communityInvolvedTokens).arg(communityInvolvedAddress).arg(sender)
                    }
                    break
                }
                case Constants.SendType.CommunityRemoteBurn: {
                    if (communityNubmerOfInvolvedAddresses === 1 && !!communityInvolvedAddress) {
                        toastTitle = qsTr("Destruction failed: %1x %2 at %3 using %4").arg(sentCommunityAmount1).arg(communityAssetName1).arg(communityInvolvedAddress).arg(sender)
                    } else {
                        toastTitle = qsTr("Destruction failed: %1x %2 at %3 addresses using %4").arg(sentCommunityAmount1).arg(communityAssetName1).arg(communityNubmerOfInvolvedAddresses).arg(sender)
                    }
                    break
                }
                case Constants.SendType.CommunityBurn: {
                    toastTitle = qsTr("Burn failed: %1x %2 for %3 using %4").arg(sentCommunityAmount1).arg(communityAssetName1).arg(communityName).arg(sender)
                    break
                }
                case Constants.SendType.CommunitySetSignerPubKey: {
                    toastTitle = qsTr("Finalize ownership failed: %1 using %2").arg(communityName).arg(sender)
                    break
                }
                case Constants.SendType.Approve: {
                    console.warn("tx type approve not yet identified as a stand alone path")
                    break
                }
                default:
                    const err1 = "cannot_resolve_community" // move to Constants
                    if (error === err1) {
                        Global.displayToastMessage(qsTr("Unknown error resolving community"), "", "", false, Constants.ephemeralNotificationType.normal, "")
                        return
                    }
                    console.warn("status: failed - tx type not supproted")
                    return
                }
                break
            }
            default:
                if (!error) {
                    console.warn("not supported status")
                    return
                } else {
                    const err1 = "cannot_resolve_community" // move to Constants
                    if (error === err1) {
                        Global.displayToastMessage(qsTr("Unknown error resolving community"), "", "", false, Constants.ephemeralNotificationType.normal, "")
                        return
                    }
                }
            }

            Global.displayToastMessage(toastTitle, toastSubtitle, toastIcon, toastLoading, toastType, toastLink)
        }

        function onCommunityMemberStatusEphemeralNotification(communityName: string, memberName: string, state: int) {
            var text = ""
            switch (state) {
                case Constants.CommunityMembershipRequestState.Banned:
                case Constants.CommunityMembershipRequestState.BannedWithAllMessagesDelete:
                    text = qsTr("%1 was banned from %2").arg(memberName).arg(communityName)
                    break
                case Constants.CommunityMembershipRequestState.Unbanned:
                    text = qsTr("%1 unbanned from %2").arg(memberName).arg(communityName)
                    break
                case Constants.CommunityMembershipRequestState.Kicked:
                    text = qsTr("%1 was kicked from %2").arg(memberName).arg(communityName)
                    break
                default: return
            }

            Global.displayToastMessage(
                text,
                "",
                "checkmark-circle",
                false,
                Constants.ephemeralNotificationType.success,
                ""
            )
        }

        function onShowToastPairingFallbackCompleted() {
            Global.displayToastMessage(
                qsTr("Device paired"),
                qsTr("Sync in process. Keep device powered and app open."),
                "checkmark-circle",
                false,
                Constants.ephemeralNotificationType.success,
                ""
            )
        }
    }

    QtObject {
        id: d

        property var activityCenterPopupObj: null

        function openActivityCenterPopup() {
            if (!activityCenterPopupObj) {
                activityCenterPopupObj = activityCenterPopupComponent.createObject(appMain)
            }

            if (activityCenterPopupObj.opened) {
                activityCenterPopupObj.close()
            } else {
                activityCenterPopupObj.open()
            }
        }

        function openHomePage() {
            appMain.rootStore.mainModuleInst.setActiveSectionBySectionType(Constants.appSection.homePage)
            homePageLoader.item.focusSearch()
        }

        function maybeDisplayIntroduceYourselfPopup() {
            if (!appMainLocalSettings.introduceYourselfPopupSeen && allContacsAdaptor.selfDisplayName === "")
                introduceYourselfPopupComponent.createObject(appMain).open()
        }

        function ensName(username) {
            if (!username.endsWith(".stateofus.eth") && !username.endsWith(".eth")) {
                return "%1.%2".arg(username).arg("stateofus.eth")
            }
            return username
        }
    }

    Settings {
        id: appMainLocalSettings
        category: "AppMainLocalSettings_%1".arg(allContacsAdaptor.selfPubKey)
        property var whitelistedUnfurledDomains: []
        property bool introduceYourselfPopupSeen
        property var recentEmojis
        property color skinColor
        property int theme: Theme.Style.System
        property int fontSize: Theme.FontSize.FontSizeM

        Component.onCompleted: {
            Theme.changeTheme(appMainLocalSettings.theme)
            Theme.changeFontSize(appMainLocalSettings.fontSize)
        }
    }

    Connections {
        target: Application.styleHints
        function onColorSchemeChanged() {
            Theme.changeTheme(appMainLocalSettings.theme) // re-apply the theme when the System theme/colorscheme changes
        }
    }

    Popups {
        id: popups

        sharedRootStore: appMain.sharedRootStore
        popupParent: appMain
        rootStore: appMain.rootStore
        utilsStore: appMain.utilsStore
        communityTokensStore: appMain.communityTokensStore
        communitiesStore: appMain.communitiesStore
        profileStore: appMain.profileStore
        devicesStore: appMain.rootStore.devicesStore
        currencyStore: appMain.currencyStore
        walletAssetsStore: appMain.walletAssetsStore
        walletCollectiblesStore: appMain.walletCollectiblesStore
        buyCryptoStore: appMain.buyCryptoStore
        networkConnectionStore: appMain.networkConnectionStore
        networksStore: appMain.networksStore
        activityCenterStore: appMain.activityCenterStore
        advancedStore: appMain.advancedStore
        aboutStore: appMain.aboutStore
        contactsStore: appMain.contactsStore
        privacyStore: appMain.privacyStore

        allContactsModel: allContacsAdaptor.allContactsModel
        mutualContactsModel: contactsModelAdaptor.mutualContacts

        isDevBuild: !appMain.rootStore.isProduction

        onOpenExternalLink: globalConns.onOpenLink(link)
        onSaveDomainToUnfurledWhitelist: {
            const whitelistedHostnames = appMainLocalSettings.whitelistedUnfurledDomains || []
            if (!whitelistedHostnames.includes(domain)) {
                whitelistedHostnames.push(domain)
                appMainLocalSettings.whitelistedUnfurledDomains = whitelistedHostnames
            }
        }
        onTransferOwnershipRequested: popupRequestsHandler.sendModalHandler.transferOwnership(tokenId, senderAddress)
    }

    HandlersManager {
        id: popupRequestsHandler

        popupParent: appMain

        // Stores:
        rootStore: appMain.rootStore
        featureFlagsStore: appMain.featureFlagsStore
        sharedRootStore: appMain.sharedRootStore
        currencyStore: appMain.currencyStore
        networksStore: appMain.networksStore
        walletRootStore: WalletStores.RootStore
        walletAssetsStore: appMain.walletAssetsStore
        transactionStore: appMain.transactionStore
        walletCollectiblesStore: appMain.walletCollectiblesStore
        transactionStoreNew: appMain.transactionStoreNew
        tokensStore: appMain.tokensStore
        rootChatStore: appMain.rootChatStore
    }

    Connections {
        id: globalConns
        target: Global

        function onOpenCreateChatView() {
            createChatView.opened = true
        }

        function onCloseCreateChatView() {
            createChatView.opened = false
        }

        function onOpenActivityCenterPopupRequested() {
            d.openActivityCenterPopup()
        }

        function onOpenLink(link: string) {
            // Qt sometimes inserts random HTML tags; and this will break on invalid URL inside QDesktopServices::openUrl(link)
            link = SQUtils.StringUtils.plainText(link)
            Qt.openUrlExternally(link)
        }

        function onOpenLinkWithConfirmation(link: string, domain: string) {
            if (appMainLocalSettings.whitelistedUnfurledDomains.includes(domain) || link.startsWith("mailto:"))
                globalConns.onOpenLink(link)
            else
                popups.openConfirmExternalLinkPopup(link, domain)
        }

        function onActivateDeepLink(link: string) {
            appMain.rootStore.mainModuleInst.activateStatusDeepLink(link)
        }

        function onPlaySendMessageSound() {
            sendMessageSound.stop()
            sendMessageSound.play()
        }

        function onPlayNotificationSound() {
            notificationSound.stop()
            notificationSound.play()
        }

        function onPlayErrorSound() {
            errorSound.stop()
            errorSound.play()
        }

        function onSetNthEnabledSectionActive(nthSection: int) {
            if(!appMain.rootStore.mainModuleInst)
                return
            appMain.rootStore.mainModuleInst.setNthEnabledSectionActive(nthSection)
        }

        function onAppSectionBySectionTypeChanged(sectionType, subsection, subSubsection = -1, data = {}) {
            if(!appMain.rootStore.mainModuleInst)
                return

            appMain.rootStore.mainModuleInst.setActiveSectionBySectionType(sectionType)

            if (sectionType === Constants.appSection.profile) {
                profileLoader.settingsSubsection = subsection || Constants.settingsSubsection.profile
                profileLoader.settingsSubSubsection = subSubsection
            } else if (sectionType === Constants.appSection.wallet) {
                appView.children[Constants.appViewStackIndex.wallet].item.openDesiredView(subsection, subSubsection, data)
            } else if (sectionType === Constants.appSection.swap) {
                popupRequestsHandler.swapModalHandler.launchSwap()
            } else if (sectionType === Constants.appSection.chat) {
                appMain.rootStore.setActiveSectionChat(appMain.profileStore.pubKey, subsection)
            } else if (sectionType === Constants.appSection.community && subsection !== "") {
                appMain.communitiesStore.setActiveCommunity(subsection)
            }
        }

        function onSwitchToCommunity(communityId: string) {
            appMain.communitiesStore.setActiveCommunity(communityId)
        }

        function onOpenAddEditSavedAddressesPopup(params) {
            addEditSavedAddress.open(params)
        }

        function onOpenDeleteSavedAddressesPopup(params) {
            deleteSavedAddress.open(params)
        }

        function onOpenShowQRPopup(params) {
            showQR.open(params)
        }

        function onOpenSavedAddressActivityPopup(params) {
            savedAddressActivity.open(params)
        }
    }

    Connections {
        target: appMain.communitiesStore

        function onImportingCommunityStateChanged(communityId, state, errorMsg) {
            let title = ""
            let subTitle = ""
            let loading = false
            let notificationType = Constants.ephemeralNotificationType.normal
            let icon = ""

            switch (state)
            {
            case Constants.communityImported:
                const community = appMain.communitiesStore.getCommunityDetailsAsJson(communityId)
                if(community.isControlNode) {
                    title = qsTr("This device is now the control node for the %1 Community").arg(community.name)
                    notificationType = Constants.ephemeralNotificationType.success
                    icon = "checkmark-circle"
                } else {
                    title = qsTr("'%1' community imported").arg(community.name)
                }
                break
            case Constants.communityImportingInProgress:
                title = qsTr("Importing community is in progress")
                loading = true
                break
            case Constants.communityImportingError:
                title = qsTr("Failed to import community '%1'").arg(communityId)
                subTitle = errorMsg
                break
            case Constants.communityImportingCanceled:
                title = qsTr("Import community '%1' was canceled").arg(community.name)
                break;
            default:
                console.error("unknown state while importing community: %1").arg(state)
                return
            }

            Global.displayToastMessage(title,
                                       subTitle,
                                       icon,
                                       loading,
                                       notificationType,
                                       "")
        }
    }

    Connections {
        target: Window.window

        function onActiveChanged() {
            if (Window.window.active)
                appMain.rootStore.windowActivated()
            else
                appMain.rootStore.windowDeactivated()
        }
    }

    function changeAppSectionBySectionId(sectionId) {
        appMain.rootStore.mainModuleInst.setActiveSectionById(sectionId)
    }

    StatusSoundEffect {
        id: sendMessageSound

        volume: convertVolume(rootStore.volume)
        muted: !rootStore.notificationSoundsEnabled
        source: "qrc:/imports/assets/audio/send_message.wav"

        onIsErrorChanged: {
            if(isError) {
                console.warn("Sound error:",
                             statusString)
            }
        }
    }

    StatusSoundEffect {
        id: notificationSound

        volume: convertVolume(rootStore.volume)
        muted: !rootStore.notificationSoundsEnabled
        source: "qrc:/imports/assets/audio/notification.wav"

        onIsErrorChanged: {
            if(isError) {
                console.warn("Sound error:",
                             statusString)
            }
        }
    }

    StatusSoundEffect {
        id: errorSound

        volume: convertVolume(rootStore.volume)
        muted: !rootStore.notificationSoundsEnabled
        source: "qrc:/imports/assets/audio/error.mp3"

        onIsErrorChanged: {
            if(isError) {
                console.warn("Sound error:",
                             statusString)
            }
        }
    }

    Loader {
        id: appSearch
        active: false
        asynchronous: true

        function openSearchPopup() {
            if (homePageLoader.active)
                return
            if (!active)
                active = true
            item.openSearchPopup()
        }

        function closeSearchPopup() {
            if (item)
                item.closeSearchPopup()

            active = false
        }

        sourceComponent: AppSearch {
            store: appMain.rootStore.appSearchStore
            utilsStore: appMain.utilsStore
            onClosed: appSearch.active = false
        }
    }

    Loader {
        id: statusEmojiPopup
        active: appMain.rootStore.mainModuleInst.sectionsLoaded
        sourceComponent: StatusEmojiPopup {
            height: 440
            settings: appMainLocalSettings
            emojiModel: SQUtils.Emoji.emojiModel
        }
    }

    Loader {
        id: statusStickersPopupLoader
        active: appMain.rootStore.mainModuleInst.sectionsLoaded
        sourceComponent: StatusStickersPopup {
            store: appMain.rootChatStore
            isWalletEnabled: appMain.walletProfileStore.isWalletEnabled
            onBuyClicked: popupRequestsHandler.sendModalHandler.buyStickerPack(packId, price)
        }
    }
    
    property Item navBar: StatusAppNavBar {
        visible: !homePageLoader.active
        width: visible ? implicitWidth : 0

        topSectionModel: SortFilterProxyModel {
            sourceModel: appMain.rootStore.mainModuleInst.sectionsModel
            filters: [
                AnyOf {
                    ValueFilter {
                        roleName: "sectionType"
                        value: Constants.appSection.homePage
                    }
                    ValueFilter {
                        roleName: "sectionType"
                        value: Constants.appSection.wallet
                    }
                    ValueFilter {
                        roleName: "sectionType"
                        value: Constants.appSection.swap
                        enabled: !appMain.featureFlagsStore.marketEnabled
                    }
                    ValueFilter {
                        roleName: "sectionType"
                        value: Constants.appSection.market
                        enabled: appMain.featureFlagsStore.marketEnabled
                    }
                    ValueFilter {
                        roleName: "sectionType"
                        value: Constants.appSection.chat
                    }
                },
                ValueFilter {
                    roleName: "enabled"
                    value: true
                }
            ]
        }
        topSectionDelegate: navbarButton

        communityItemsModel: SortFilterProxyModel {
            sourceModel: appMain.rootStore.mainModuleInst.sectionsModel
            filters: [
                ValueFilter {
                    roleName: "sectionType"
                    value: Constants.appSection.community
                },
                ValueFilter {
                    roleName: "enabled"
                    value: true
                }
            ]
        }
        communityItemDelegate: StatusNavBarTabButton {
            objectName: "CommunityNavBarButton"
            anchors.horizontalCenter: parent.horizontalCenter
            name: model.icon.length > 0? "" : model.name
            icon.name: model.icon
            icon.source: model.image
            identicon.asset.color: (hovered || identicon.highlighted || checked) ? model.color : icon.color
            tooltip.text: model.name
            checked: model.active
            badge.value: model.notificationsCount
            badge.visible: model.hasNotification

            stateIcon.color: Theme.palette.dangerColor1
            stateIcon.border.color: Theme.palette.baseColor2
            stateIcon.border.width: 2
            stateIcon.visible: model.amIBanned
            stateIcon.asset.name: "cancel"
            stateIcon.asset.color: Theme.palette.baseColor2
            stateIcon.asset.width: 14

            onClicked: {
                changeAppSectionBySectionId(model.id)
            }

            popupMenu: Component {
                StatusMenu {
                    id: communityContextMenu
                    property var chatCommunitySectionModule

                    readonly property bool isSpectator: model.spectated && !model.joined

                    openHandler: function () {
                        // we cannot return QVariant if we pass another parameter in a function call
                        // that's why we're using it this way
                        appMain.rootStore.mainModuleInst.prepareCommunitySectionModuleForCommunityId(model.id)
                        communityContextMenu.chatCommunitySectionModule = appMain.rootStore.mainModuleInst.getCommunitySectionModule()
                    }

                    StatusAction {
                        text: qsTr("Invite People")
                        icon.name: "share-ios"
                        objectName: "invitePeople"
                        onTriggered: {
                            popups.openInviteFriendsToCommunityPopup(model,
                                                                        communityContextMenu.chatCommunitySectionModule,
                                                                        null)
                        }
                    }

                    StatusAction {
                        text: qsTr("Community Info")
                        icon.name: "info"
                        onTriggered: popups.openCommunityProfilePopup(appMain.rootStore, model, communityContextMenu.chatCommunitySectionModule)
                    }

                    StatusAction {
                        text: qsTr("Community Rules")
                        icon.name: "text"
                        onTriggered: popups.openCommunityRulesPopup(model.name, model.introMessage, model.image, model.color)
                    }

                    StatusMenuSeparator {}

                    MuteChatMenuItem {
                        enabled: !model.muted
                        title: qsTr("Mute Community")
                        onMuteTriggered: {
                            communityContextMenu.chatCommunitySectionModule.setCommunityMuted(interval)
                            communityContextMenu.close()
                        }
                    }

                    StatusAction {
                        enabled: model.muted
                        text: qsTr("Unmute Community")
                        icon.name: "notification"
                        onTriggered: communityContextMenu.chatCommunitySectionModule.setCommunityMuted(Constants.MutingVariations.Unmuted)
                    }

                    StatusAction {
                        text: qsTr("Mark as read")
                        icon.name: "check-circle"
                        onTriggered: communityContextMenu.chatCommunitySectionModule.markAllReadInCommunity()
                    }

                    StatusAction {
                        text: qsTr("Edit Shared Addresses")
                        icon.name: "wallet"
                        enabled: {
                            if (model.memberRole === Constants.memberRole.owner || communityContextMenu.isSpectator)
                                return false
                            return true
                        }
                        onTriggered: {
                            communityContextMenu.close()
                            Global.openEditSharedAddressesFlow(model.id)
                        }
                    }

                    StatusMenuSeparator { visible: leaveCommunityMenuItem.enabled }

                    StatusAction {
                        id: leaveCommunityMenuItem
                        objectName: "leaveCommunityMenuItem"
                        // allow to leave community for the owner in non-production builds
                        enabled: model.memberRole !== Constants.memberRole.owner || !production
                        text: {
                            if (communityContextMenu.isSpectator)
                                return qsTr("Close Community")
                            return qsTr("Leave Community")
                        }
                        icon.name: communityContextMenu.isSpectator ? "close-circle" : "arrow-left"
                        type: StatusAction.Type.Danger
                        onTriggered: communityContextMenu.isSpectator ? communityContextMenu.chatCommunitySectionModule.leaveCommunity()
                                                                        : popups.openLeaveCommunityPopup(model.name, model.id, model.outroMessage)
                    }
                }
            }
        }

        regularItemsModel: SortFilterProxyModel {
            sourceModel: appMain.rootStore.mainModuleInst.sectionsModel
            filters: [
                RangeFilter {
                    roleName: "sectionType"
                    minimumValue: Constants.appSection.profile
                    maximumValue: Constants.appSection.loadingSection
                },
                ValueFilter {
                    roleName: "enabled"
                    value: true
                }
            ]
        }
        regularItemDelegate: navbarButton

        delegateHeight: 40

        profileComponent: ProfileButton {
            objectName: "statusProfileNavBarTabButton"

            name: appMain.profileStore.name
            usesDefaultName: appMain.profileStore.usesDefaultName
            pubKey: appMain.profileStore.pubKey
            compressedPubKey: appMain.profileStore.compressedPubKey
            isEnsVerified: !!appMain.profileStore.preferredName
            iconSource: appMain.profileStore.icon
            colorId: appMain.profileStore.colorId
            colorHash: appMain.profileStore.colorHash
            currentUserStatus: appMain.profileStore.currentUserStatus

            getEmojiHashFn: appMain.utilsStore.getEmojiHash
            getLinkToProfileFn: appMain.rootStore.contactStore.getLinkToProfile
            onSetCurrentUserStatusRequested: (status) => appMain.rootStore.setCurrentUserStatus(status)
            onViewProfileRequested: (pubKey) => Global.openProfilePopup(pubKey)
        }

        Component {
            id: navbarButton
            StatusNavBarTabButton {
                id: navbar
                objectName: model.name + "-navbar"
                anchors.horizontalCenter: parent.horizontalCenter
                name: model.icon.length > 0? "" : model.name
                icon.name: model.icon
                icon.source: model.image
                tooltip.text: Utils.translatedSectionName(model.sectionType, model.name, (sectionType) => {
                    if (sectionType === Constants.appSection.homePage) {
                        return homePageShortcut.nativeText
                    }
                    return ""
                })
                checked: model.active

                readonly property bool displayCreateCommunityBadge: model.sectionType === Constants.appSection.communitiesPortal && !appMain.communitiesStore.createCommunityPopupSeen
                badge.value: model.notificationsCount
                badge.visible: {
                    if (model.sectionType === Constants.appSection.profile && contactsModelAdaptor.pendingReceivedRequestContacts.ModelCount.count > 0) // pending contact request
                        return true
                    if (displayCreateCommunityBadge) // create new community badge
                        return true
                    return model.hasNotification // Otherwise, use the value coming from the model
                }

                StatusNewItemGradient { id: newGradient }
                badge.gradient: displayCreateCommunityBadge ? newGradient : undefined // gradient has precedence over a simple color

                onClicked: {
                    if(model.sectionType === Constants.appSection.swap) {
                        popupRequestsHandler.swapModalHandler.launchSwap()
                    } else {
                        changeAppSectionBySectionId(model.id)
                    }
                }
            }
        }
    }

    StatusMainLayout {
        anchors.fill: parent

        rightPanel: ColumnLayout {
            spacing: 0
            objectName: "mainRightView"

            ColumnLayout {
                id: bannersLayout

                enabled: !localAppSettings.testEnvironment
                         && appMain.rootStore.mainModuleInst.activeSection.sectionType !== Constants.appSection.homePage
                visible: enabled

                property var updateBanner: null
                property var connectedBanner: null
                readonly property bool isConnected: appMain.rootStore.mainModuleInst.isOnline

                function processUpdateAvailable() {
                    if (!updateBanner)
                        updateBanner = updateBannerComponent.createObject(this)
                }

                function processConnected() {
                    if (!connectedBanner)
                        connectedBanner = connectedBannerComponent.createObject(this)
                }

                Layout.fillWidth: true
                Layout.maximumHeight: implicitHeight
                spacing: 1

                onIsConnectedChanged: {
                    processConnected()
                }

                Component.onCompleted: {
                    if (!isConnected)
                        processConnected()
                }

                Connections {
                    target: rootStore.aboutModuleInst
                    function onAppVersionFetched(available: bool, version: string, url: string) {
                        rootStore.setLatestVersionInfo(available, version, url);
                        // TODO when we re-implement check for updates, uncomment this
                        // bannersLayout.processUpdateAvailable()
                    }
                }

                ModuleWarning {
                    id: testnetBanner
                    objectName: "testnetBanner"
                    Layout.fillWidth: true
                    text: qsTr("Testnet mode enabled. All balances, transactions and dApp interactions will be on testnets.")
                    buttonText: qsTr("Turn off")
                    type: ModuleWarning.Warning
                    iconName: "warning"
                    active: appMain.networksStore.areTestNetworksEnabled
                    delay: false
                    onClicked: Global.openTestnetPopup()
                    closeBtnVisible: false
                }

                ModuleWarning {
                    id: secureYourSeedPhrase
                    objectName: "secureYourSeedPhraseBanner"
                    Layout.fillWidth: true
                    active: !appMain.profileStore.userDeclinedBackupBanner
                              && !appMain.privacyStore.mnemonicBackedUp
                    type: ModuleWarning.Danger
                    text: qsTr("Secure your recovery phrase")
                    buttonText: qsTr("Back up now")
                    delay: false
                    onClicked: popups.openBackUpSeedPopup()

                    onCloseClicked: {
                        appMain.profileStore.userDeclinedBackupBanner = true
                    }
                }


                ModuleWarning {
                    Layout.fillWidth: true
                    readonly property int progress: appMain.communitiesStore.discordImportProgress
                    readonly property bool inProgress: (progress > 0 && progress < 100) || appMain.communitiesStore.discordImportInProgress
                    readonly property bool finished: progress >= 100
                    readonly property bool cancelled: appMain.communitiesStore.discordImportCancelled
                    readonly property bool stopped: appMain.communitiesStore.discordImportProgressStopped
                    readonly property int errors: appMain.communitiesStore.discordImportErrorsCount
                    readonly property int warnings: appMain.communitiesStore.discordImportWarningsCount
                    readonly property string communityId: appMain.communitiesStore.discordImportCommunityId
                    readonly property string communityName: appMain.communitiesStore.discordImportCommunityName
                    readonly property string channelId: appMain.communitiesStore.discordImportChannelId
                    readonly property string channelName: appMain.communitiesStore.discordImportChannelName
                    readonly property string channelOrCommunityName: channelName || communityName
                    delay: false
                    active: !cancelled && (inProgress || finished || stopped)
                    type: errors ? ModuleWarning.Type.Danger : ModuleWarning.Type.Success
                    text: {
                        if (finished || stopped) {
                            if (errors)
                                return qsTr("The import of ‘%1’ from Discord to Status was stopped: <a href='#'>Critical issues found</a>").arg(channelOrCommunityName)

                            let result = qsTr("‘%1’ was successfully imported from Discord to Status").arg(channelOrCommunityName) + "  <a href='#'>"
                            if (warnings)
                                result += qsTr("Details (%1)").arg(qsTr("%n issue(s)", "", warnings))
                            else
                                result += qsTr("Details")
                            result += "</a>"
                            return result
                        }
                        if (inProgress) {
                            let result = qsTr("Importing ‘%1’ from Discord to Status").arg(channelOrCommunityName) + "  <a href='#'>"
                            if (warnings)
                                result += qsTr("Check progress (%1)").arg(qsTr("%n issue(s)", "", warnings))
                            else
                                result += qsTr("Check progress")
                            result += "</a>"
                            return result
                        }

                        return ""
                    }
                    onLinkActivated: popups.openDiscordImportProgressPopup(!!channelId)
                    progressValue: progress
                    closeBtnVisible: finished || stopped
                    buttonText: finished && !errors ? !!channelId ? qsTr("Visit your new channel") : qsTr("Visit your Community") : ""
                    onClicked: function() {
                        if (!!channelId)
                            rootStore.setActiveSectionChat(communityId, channelId)
                        else
                            appMain.communitiesStore.setActiveCommunity(communityId)
                    }
                    onCloseClicked: hide()
                }

                ModuleWarning {
                    id: downloadingArchivesBanner
                    Layout.fillWidth: true
                    active: appMain.communitiesStore.downloadingCommunityHistoryArchives
                    type: ModuleWarning.Danger
                    text: qsTr("Downloading message history archives, DO NOT CLOSE THE APP until this banner disappears.")
                    closeBtnVisible: false
                    delay: false
                }

                ModuleWarning {
                    id: mailserverConnectionBanner
                    type: ModuleWarning.Warning
                    text: qsTr("Can not connect to store node. Retrying automatically")
                    onCloseClicked: hide()
                    Layout.fillWidth: true
                }

                Component {
                    id: connectedBannerComponent

                    ModuleWarning {
                        id: connectedBanner
                        property bool isConnected: true

                        objectName: "connectionInfoBanner"
                        Layout.fillWidth: true
                        text: isConnected ? qsTr("You are back online") : qsTr("Internet connection lost. Reconnect to ensure everything is up to date.")
                        type: isConnected ? ModuleWarning.Success : ModuleWarning.Danger

                        function updateState() {
                            if (isConnected)
                                showFor()
                            else
                                show();
                        }

                        Component.onCompleted: {
                            connectedBanner.isConnected = Qt.binding(() => bannersLayout.isConnected);
                        }
                        onIsConnectedChanged: {
                            updateState();
                        }
                        onCloseClicked: {
                            hide();
                        }
                        onHideFinished: {
                            destroy()
                            bannersLayout.connectedBanner = null
                        }
                    }
                }

                Component {
                    id: updateBannerComponent

                    ModuleWarning {
                        readonly property string version: appMain.rootStore.latestVersion
                        readonly property bool updateAvailable: appMain.rootStore.newVersionAvailable

                        objectName: "appVersionUpdateBanner"
                        Layout.fillWidth: true
                        type: ModuleWarning.Success
                        delay: false
                        text: updateAvailable ? qsTr("A new version of Status (%1) is available").arg(version)
                                              : qsTr("Your version is up to date")

                        buttonText: updateAvailable ? qsTr("Update")
                                                    : qsTr("Close")

                        function updateState() {
                            if (updateAvailable)
                                show()
                            else
                                showFor(5000)
                        }

                        Component.onCompleted: {
                            updateState()
                        }
                        onUpdateAvailableChanged: {
                            updateState();
                        }
                        onClicked: {
                            if (updateAvailable)
                                Global.openDownloadModal(appMain.rootStore.newVersionAvailable,
                                                         appMain.rootStore.latestVersion,
                                                         appMain.rootStore.downloadURL)
                            else
                                close()
                        }
                        onCloseClicked: {
                            if (updateAvailable)
                                appMain.rootStore.resetLastVersion();
                            hide()
                        }
                        onHideFinished: {
                            destroy()
                            bannersLayout.updateBanner = null
                        }
                    }
                }

                ConnectionWarnings {
                    id: walletBlockchainConnectionBanner
                    objectName: "walletBlockchainConnectionBanner"
                    Layout.fillWidth: true
                    websiteDown: Constants.walletConnections.blockchains
                    withCache: networkConnectionStore.balanceCache
                    networkConnectionStore: appMain.networkConnectionStore
                    tooltipMessage: qsTr("Pocket Network (POKT) & Infura are currently both unavailable for %1. Balances for those chains are as of %2.").arg(jointChainIdString).arg(lastCheckedAt)
                    toastText: {
                        switch(connectionState) {
                        case Constants.ConnectionStatus.Success:
                            return qsTr("Pocket Network (POKT) connection successful")
                        case Constants.ConnectionStatus.Failure:
                            if(completelyDown) {
                                if(withCache)
                                    return qsTr("POKT & Infura down. Token balances are as of %1.").arg(lastCheckedAt)
                                else
                                    return qsTr("POKT & Infura down. Token balances cannot be retrieved.")
                            }
                            else if(chainIdsDown.length > 0) {
                                if(chainIdsDown.length > 2) {
                                    return qsTr("POKT & Infura down for <a href='#'>multiple chains </a>. Token balances for those chains cannot be retrieved.")
                                }
                                else if(chainIdsDown.length === 1) {
                                    return qsTr("POKT & Infura down for %1. %1 token balances are as of %2.").arg(jointChainIdString).arg(lastCheckedAt)
                                }
                                else {
                                    return qsTr("POKT & Infura down for %1. %1 token balances cannot be retrieved.").arg(jointChainIdString)
                                }
                            }
                            else
                                return ""
                        case Constants.ConnectionStatus.Retrying:
                            return qsTr("Retrying connection to POKT Network (grove.city).")
                        default:
                            return ""
                        }
                    }
                }

                ConnectionWarnings {
                    id: walletCollectiblesConnectionBanner
                    objectName: "walletCollectiblesConnectionBanner"
                    Layout.fillWidth: true
                    websiteDown: Constants.walletConnections.collectibles
                    withCache: lastCheckedAtUnix > 0
                    networkConnectionStore: appMain.networkConnectionStore
                    tooltipMessage: {
                        if(withCache)
                            return qsTr("Collectibles providers are currently unavailable for %1. Collectibles for those chains are as of %2.").arg(jointChainIdString).arg(lastCheckedAt)
                        else
                            return qsTr("Collectibles providers are currently unavailable for %1.").arg(jointChainIdString)
                    }
                    toastText: {
                        switch(connectionState) {
                        case Constants.ConnectionStatus.Success:
                            return qsTr("Collectibles providers connection successful")
                        case Constants.ConnectionStatus.Failure:
                            if(completelyDown) {
                                if(withCache)
                                    return qsTr("Collectibles providers down. Collectibles are as of %1.").arg(lastCheckedAt)
                                else
                                    return qsTr("Collectibles providers down. Collectibles cannot be retrieved.")
                            }
                            else if(chainIdsDown.length > 0) {
                                if(chainIdsDown.length > 2) {
                                    if(withCache)
                                        return qsTr("Collectibles providers down for <a href='#'>multiple chains</a>. Collectibles for these chains are as of %1.".arg(lastCheckedAt))
                                    else
                                        return qsTr("Collectibles providers down for <a href='#'>multiple chains</a>. Collectibles for these chains cannot be retrieved.")
                                }
                                else if(chainIdsDown.length === 1) {
                                    if(withCache)
                                        return qsTr("Collectibles providers down for %1. Collectibles for this chain are as of %2.").arg(jointChainIdString).arg(lastCheckedAt)
                                    else
                                        return qsTr("Collectibles providers down for %1. Collectibles for this chain cannot be retrieved.").arg(jointChainIdString)
                                }
                                else {
                                    if(withCache)
                                        return qsTr("Collectibles providers down for %1. Collectibles for these chains are as of %2.").arg(jointChainIdString).arg(lastCheckedAt)
                                    else
                                        return qsTr("Collectibles providers down for %1. Collectibles for these chains cannot be retrieved.").arg(jointChainIdString)
                                }
                            }
                            else
                                return ""
                        case Constants.ConnectionStatus.Retrying:
                            return qsTr("Retrying connection to collectibles providers...")
                        default:
                            return ""
                        }
                    }
                }

                ConnectionWarnings {
                    id: walletMarketConnectionBanner
                    objectName: "walletMarketConnectionBanner"
                    Layout.fillWidth: true
                    websiteDown: Constants.walletConnections.market
                    withCache: networkConnectionStore.marketValuesCache
                    networkConnectionStore: appMain.networkConnectionStore
                    toastText: {
                        switch(connectionState) {
                        case Constants.ConnectionStatus.Success:
                            return qsTr("CryptoCompare and CoinGecko connection successful")
                        case Constants.ConnectionStatus.Failure: {
                            if(withCache) {
                                return qsTr("CryptoCompare and CoinGecko down. Market values are as of %1.").arg(lastCheckedAt)
                            }
                            else {
                                return qsTr("CryptoCompare and CoinGecko down. Market values cannot be retrieved.")
                            }
                        }
                        case Constants.ConnectionStatus.Retrying:
                            return qsTr("Retrying connection to CryptoCompare and CoinGecko...")
                        default:
                            return ""
                        }
                    }
                }
            }

            Item {
                Layout.fillWidth: true
                Layout.fillHeight: true

                StackLayout {
                    id: appView
                    anchors.fill: parent

                    currentIndex: {
                        const activeSectionType = appMain.rootStore.mainModuleInst.activeSection.sectionType
                        switch (activeSectionType) {
                        case Constants.appSection.homePage:
                            return Constants.appViewStackIndex.homePage
                        case Constants.appSection.chat:
                            return Constants.appViewStackIndex.chat
                        case Constants.appSection.community:
                            for (let i = this.children.length - 1; i >= 0; i--) {
                                var obj = this.children[i]
                                if (obj && obj.sectionId && obj.sectionId === appMain.rootStore.mainModuleInst.activeSection.id) {
                                    return i
                                }
                            }
                            // Should never be here, correct index must be returned from the for loop above
                            console.error("Wrong section type:", appMain.rootStore.mainModuleInst.activeSection.sectionType,
                                          "or section id: ", appMain.rootStore.mainModuleInst.activeSection.id)
                            return Constants.appViewStackIndex.community
                        case Constants.appSection.communitiesPortal:
                            return Constants.appViewStackIndex.communitiesPortal
                        case Constants.appSection.wallet:
                            return Constants.appViewStackIndex.wallet
                        case Constants.appSection.profile:
                            return Constants.appViewStackIndex.profile
                        case Constants.appSection.node:
                            return Constants.appViewStackIndex.node
                        case Constants.appSection.market:
                            return Constants.appViewStackIndex.market
                        default:
                            // We should never end up here
                            console.error("AppMain: Unknown section type")
                        }
                    }
                    onCurrentIndexChanged: {
                        const sectionType = appMain.rootStore.mainModuleInst.activeSection.sectionType
                        if (sectionType !== Constants.appSection.profile && sectionType !== Constants.appSection.wallet) {
                            d.maybeDisplayIntroduceYourselfPopup()
                        }
                    }

                    // NOTE:
                    // If we ever change stack layout component order we need to updade
                    // Constants.appViewStackIndex accordingly

                    Loader {
                        id: homePageLoader
                        focus: active
                        active: appMain.featureFlagsStore.homePageEnabled && appView.currentIndex === Constants.appViewStackIndex.homePage

                        onLoaded: {
                            rootStore.rebuildChatSearchModel()
                        }

                        sourceComponent: HomePage {
                            id: homePage

                            objectName: "homeContainer"

                            HomePageAdaptor {
                                id: homePageAdaptor
                                readonly property bool sectionsLoaded: appMain.rootStore.mainModuleInst && appMain.rootStore.mainModuleInst.sectionsLoaded

                                sectionsBaseModel: sectionsLoaded ? appMain.rootStore.mainModuleInst.sectionsModel : null
                                chatsBaseModel: sectionsLoaded ? appMain.rootStore.mainModuleInst.getChatSectionModule().model
                                                               : null
                                chatsSearchBaseModel: sectionsLoaded && !!rootStore.chatSearchModel ? rootStore.chatSearchModel : null
                                walletsBaseModel: sectionsLoaded ? WalletStores.RootStore.accounts : null
                                dappsBaseModel: dAppsServiceLoader.active && dAppsServiceLoader.item ? dAppsServiceLoader.item.dappsModel : null

                                showEnabledSectionsOnly: true
                                marketEnabled: appMain.featureFlagsStore.marketEnabled

                                syncingBadgeCount: appMain.rootStore.profileSectionStore.devicesStore.devicesModel.count -
                                                   appMain.rootStore.profileSectionStore.devicesStore.devicesModel.pairedCount
                                messagingBadgeCount: contactsModelAdaptor.pendingReceivedRequestContacts.count
                                showBackUpSeed: !appMain.rootStore.profileSectionStore.profileStore.userDeclinedBackupBanner &&
                                                !appMain.rootStore.profileSectionStore.profileStore.privacyStore.mnemonicBackedUp

                                searchPhrase: homePage.searchPhrase

                                profileId: appMain.profileStore.pubkey
                            }

                            homePageEntriesModel: homePageAdaptor.homePageEntriesModel
                            sectionsModel: homePageAdaptor.sectionsModel
                            pinnedModel: homePageAdaptor.pinnedModel

                            profileStore: appMain.profileStore

                            getEmojiHashFn: appMain.utilsStore.getEmojiHash
                            getLinkToProfileFn: appMain.rootStore.contactStore.getLinkToProfile

                            useNewDockIcons: false
                            hasUnseenACNotifications: appMain.activityCenterStore.hasUnseenNotifications
                            aCNotificationCount: appMain.activityCenterStore.unreadNotificationsCount

                            onItemActivated: function(key, sectionType, itemId) {
                                homePageAdaptor.setTimestamp(key, new Date().valueOf())

                                if (sectionType === -1) { // search
                                    const [sectionId, chatId] = key.split(";")
                                    return rootStore.setActiveSectionChat(sectionId, chatId)
                                } else if (sectionType === Constants.appSection.profile) {
                                    if (itemId == Constants.settingsSubsection.backUpSeed) {
                                        return Global.openBackUpSeedPopup()
                                    } else if (itemId == Constants.settingsSubsection.signout) {
                                        return Global.quitAppRequested()
                                    }
                                }

                                let subsection = itemId
                                let subSubsection = -1
                                let data = {}

                                if (sectionType === Constants.appSection.wallet && !!itemId) {
                                    subsection = WalletLayout.LeftPanelSelection.Address
                                    subSubsection = WalletLayout.RightPanelSelection.Assets
                                    data = { address: itemId }
                                }

                                globalConns.onAppSectionBySectionTypeChanged(sectionType, subsection, subSubsection, data)
                            }
                            onItemPinRequested: function(key, pin) {
                                homePageAdaptor.setPinned(key, pin)
                                if (pin)
                                    homePageAdaptor.setTimestamp(key, new Date().valueOf()) // update the timestamp so that the pinned dock items are sorted by their recency
                            }
                            onDappDisconnectRequested: function(dappUrl) {
                                dappMetrics.logNavigationEvent(DAppsMetrics.DAppsNavigationAction.DAppDisconnectInitiated)
                                dAppsServiceLoader.dappDisconnectRequested(dappUrl)
                            }

                            onNotificationButtonClicked: d.openActivityCenterPopup()
                            onSetCurrentUserStatusRequested: (status) => appMain.rootStore.setCurrentUserStatus(status)
                            onViewProfileRequested: (pubKey) => Global.openProfilePopup(pubKey)
                        }
                    }

                    Loader {
                        asynchronous: true
                        active: false
                        sourceComponent: {
                            if (appMain.rootStore.mainModuleInst.chatsLoadingFailed) {
                                return errorStateComponent
                            }
                            if (appMain.rootStore.mainModuleInst.sectionsLoaded) {
                                return personalChatLayoutComponent
                            }
                            return loadingStateComponent
                        }

                        // Do not unload section data from the memory in order not
                        // to reset scroll, not send text input and etc during the
                        // sections switching
                        Binding on active {
                            when: appView.currentIndex === Constants.appViewStackIndex.chat
                            value: true
                            restoreMode: Binding.RestoreNone
                        }

                        Component {
                            id: loadingStateComponent
                            Item {
                                anchors.fill: parent

                                Row {
                                    anchors.centerIn: parent
                                    spacing: 6
                                    StatusBaseText {
                                        anchors.verticalCenter: parent.verticalCenter
                                        text: qsTr("Loading sections...")
                                    }
                                    LoadingAnimation { anchors.verticalCenter: parent.verticalCenter }
                                }
                            }
                        }

                        Component {
                            id: errorStateComponent
                            Item {
                                anchors.fill: parent
                                StatusBaseText {
                                    text: qsTr("Error loading chats, try closing the app and restarting")
                                    anchors.centerIn: parent
                                }
                            }
                        }

                        Component {
                            id: personalChatLayoutComponent

                            ChatLayout {
                                id: chatLayoutContainer

                                navBar: appMain.navBar
                                rootStore: ChatStores.RootStore {
                                    contactsStore: appMain.rootStore.contactStore
                                    currencyStore: appMain.currencyStore
                                    communityTokensStore: appMain.communityTokensStore
                                    emojiReactionsModel: appMain.rootStore.emojiReactionsModel
                                    openCreateChat: createChatView.opened
                                    networkConnectionStore: appMain.networkConnectionStore

                                    chatCommunitySectionModule: appMain.rootStore.mainModuleInst.getChatSectionModule()
                                }
                                createChatPropertiesStore: appMain.createChatPropertiesStore
                                tokensStore: appMain.tokensStore
                                transactionStore: appMain.transactionStore
                                walletAssetsStore: appMain.walletAssetsStore
                                currencyStore: appMain.currencyStore
                                networksStore: appMain.networksStore
                                advancedStore: appMain.advancedStore
                                emojiPopup: statusEmojiPopup.item
                                stickersPopup: statusStickersPopupLoader.item
                                sendViaPersonalChatEnabled: featureFlagsStore.sendViaPersonalChatEnabled
                                disabledTooltipText: !appMain.networkConnectionStore.sendBuyBridgeEnabled ?
                                                         appMain.networkConnectionStore.sendBuyBridgeToolTipText : ""
                                paymentRequestFeatureEnabled: featureFlagsStore.paymentRequestEnabled

                                mutualContactsModel: contactsModelAdaptor.mutualContacts

                                // Unfurling related data:
                                gifUnfurlingEnabled: appMain.sharedRootStore.gifUnfurlingEnabled
                                neverAskAboutUnfurlingAgain: appMain.sharedRootStore.neverAskAboutUnfurlingAgain

                                // Users related data
                                usersModel: rootStore.usersStore.usersModel

                                onProfileButtonClicked: {
                                    Global.changeAppSectionBySectionType(Constants.appSection.profile);
                                }

                                onOpenAppSearch: {
                                    appSearch.openSearchPopup()
                                }

                                onBuyStickerPackRequested: popupRequestsHandler.sendModalHandler.buyStickerPack(packId, price)
                                onTokenPaymentRequested: popupRequestsHandler.sendModalHandler.openTokenPaymentRequest(recipientAddress, symbol, rawAmount, chainId)

                                // Unfurling related requests:
                                onSetNeverAskAboutUnfurlingAgain: appMain.sharedRootStore.setNeverAskAboutUnfurlingAgain(neverAskAgain)

                                onOpenGifPopupRequest: popupRequestsHandler.statusGifPopupHandler.openGifs(params, cbOnGifSelected, cbOnClose)

                                // Edit group chat members signals:
                                onGroupMembersUpdateRequested: rootStore.usersStore.groupMembersUpdateRequested(membersPubKeysList)
                            }
                        }
                    }

                    Loader {
                        active: appView.currentIndex === Constants.appViewStackIndex.communitiesPortal
                        asynchronous: true
                        CommunitiesPortalLayout {
                            anchors.fill: parent
                            createCommunityEnabled: !Constants.isMobile
                            navBar: appMain.navBar
                            communitiesStore: appMain.communitiesStore
                            assetsModel: appMain.rootStore.globalAssetsModel
                            collectiblesModel: appMain.rootStore.globalCollectiblesModel
                            notificationCount: appMain.activityCenterStore.unreadNotificationsCount
                            hasUnseenNotifications: activityCenterStore.hasUnseenNotifications
                            createCommunityBadgeVisible: !appMain.communitiesStore.createCommunityPopupSeen
                        }
                    }

                    Loader {
                        active: appView.currentIndex === Constants.appViewStackIndex.wallet
                        asynchronous: true
                        sourceComponent: WalletLayout {
                            objectName: "walletLayoutReal"
                            navBar: appMain.navBar
                            sharedRootStore: appMain.sharedRootStore
                            store: appMain.rootStore
                            contactsStore: appMain.contactsStore
                            communitiesStore: appMain.communitiesStore
                            transactionStore: appMain.transactionStore
                            emojiPopup: statusEmojiPopup.item
                            networkConnectionStore: appMain.networkConnectionStore
                            networksStore: appMain.networksStore
                            appMainVisible: appMain.visible
                            swapEnabled: featureFlagsStore.swapEnabled
                            dAppsVisible: dAppsServiceLoader.item ? dAppsServiceLoader.item.serviceAvailableToCurrentAddress : false
                            dAppsEnabled: dAppsServiceLoader.item ? dAppsServiceLoader.item.isServiceOnline : false
                            dAppsModel: dAppsServiceLoader.item ? dAppsServiceLoader.item.dappsModel : null
                            isKeycardEnabled: featureFlagsStore.keycardEnabled
                            onDappListRequested: () => dappMetrics.logNavigationEvent(DAppsMetrics.DAppsNavigationAction.DAppListOpened)
                            onDappConnectRequested: () => {
                                dappMetrics.logNavigationEvent(DAppsMetrics.DAppsNavigationAction.DAppConnectInitiated)
                                dAppsServiceLoader.dappConnectRequested()
                            }
                            onDappDisconnectRequested: (dappUrl) => {
                                dappMetrics.logNavigationEvent(DAppsMetrics.DAppsNavigationAction.DAppDisconnectInitiated)
                                dAppsServiceLoader.dappDisconnectRequested(dappUrl)
                            }
                            onSendTokenRequested: (senderAddress, tokenId, tokenType) => {
                                                      popupRequestsHandler.sendModalHandler.sendToken(senderAddress, tokenId, tokenType)
                                                  }
                            onBridgeTokenRequested: (tokenId, tokenType) => {
                                                        popupRequestsHandler.sendModalHandler.bridgeToken(tokenId, tokenType)
                                                    }
                            onOpenSwapModalRequested: popupRequestsHandler.swapModalHandler.launchSwapSpecific(swapFormData)
                        }
                        onLoaded: {
                            item.resetView()
                        }
                    }

                    Loader {
                        id: profileLoader

                        property int settingsSubsection: Constants.settingsSubsection.profile
                        onSettingsSubsectionChanged: {
                            item.settingsSubsection = settingsSubsection
                        }
                        property int settingsSubSubsection: -1
                        onSettingsSubSubsectionChanged: {
                            item.settingsSubsection = settingsSubsection
                            item.settingsSubSubsection = settingsSubSubsection
                        }

                        active: appView.currentIndex === Constants.appViewStackIndex.profile
                        asynchronous: true
                        sourceComponent: ProfileLayout {
                            navBar: appMain.navBar
                            isProduction: appMain.rootStore.isProduction

                            sharedRootStore: appMain.sharedRootStore
                            utilsStore: appMain.utilsStore

                            store: appMain.rootStore.profileSectionStore
                            aboutStore: appMain.aboutStore
                            profileStore: appMain.profileStore
                            contactsStore: appMain.contactsStore
                            devicesStore: appMain.devicesStore
                            advancedStore: appMain.advancedStore
                            privacyStore: appMain.privacyStore
                            notificationsStore: appMain.notificationsStore
                            languageStore: appMain.languageStore
                            keycardStore: appMain.keycardStore
                            walletStore: appMain.walletProfileStore
                            messagingStore: appMain.messagingStore
                            ensUsernamesStore: appMain.ensUsernamesStore

                            globalStore: appMain.rootStore
                            communitiesStore: appMain.communitiesStore
                            emojiPopup: statusEmojiPopup.item
                            networkConnectionStore: appMain.networkConnectionStore
                            tokensStore: appMain.tokensStore
                            walletAssetsStore: appMain.walletAssetsStore
                            collectiblesStore: appMain.walletCollectiblesStore
                            currencyStore: appMain.currencyStore
                            isCentralizedMetricsEnabled: appMain.isCentralizedMetricsEnabled
                            networksStore: appMain.networksStore
                            keychain: appMain.keychain

                            mutualContactsModel: contactsModelAdaptor.mutualContacts
                            blockedContactsModel: contactsModelAdaptor.blockedContacts
                            pendingContactsModel: contactsModelAdaptor.pendingContacts
                            pendingReceivedContactsCount: contactsModelAdaptor.pendingReceivedRequestContacts.count
                            dismissedReceivedRequestContactsModel: contactsModelAdaptor.dimissedReceivedRequestContacts
                            isKeycardEnabled: featureFlagsStore.keycardEnabled

                            theme: appMainLocalSettings.theme
                            fontSize: appMainLocalSettings.fontSize
                            fnAddressWasShown: WalletStores.RootStore.addressWasShown

                            onSettingsSubsectionChanged: profileLoader.settingsSubsection = settingsSubsection

                            onConnectUsernameRequested: popupRequestsHandler.sendModalHandler.connectUsername(ensName)
                            onRegisterUsernameRequested: popupRequestsHandler.sendModalHandler.registerUsername(ensName)
                            onReleaseUsernameRequested: popupRequestsHandler.sendModalHandler.releaseUsername(ensName, senderAddress, chainId)

                            onThemeChangeRequested: function(theme) {
                                appMainLocalSettings.theme = theme
                                Theme.changeTheme(theme)
                            }
                            onFontSizeChangeRequested: function(fontSize) {
                                appMainLocalSettings.fontSize = fontSize
                                Theme.changeFontSize(fontSize)
                            }
                        }
                        onLoaded: {
                            item.settingsSubsection = profileLoader.settingsSubsection
                            item.settingsSubSubsection = profileLoader.settingsSubSubsection
                        }
                    }

                    Loader {
                        active: appView.currentIndex === Constants.appViewStackIndex.node
                        asynchronous: true
                        sourceComponent: NodeLayout {
                            navBar: appMain.navBar
                        }
                    }

                    Loader {
                        active: appView.currentIndex === Constants.appViewStackIndex.market
                        asynchronous: true
                        sourceComponent: MarketLayout {
                            objectName: "marketLayout"
                            navBar: appMain.navBar

                            notificationCount: appMain.activityCenterStore.unreadNotificationsCount
                            hasUnseenNotifications:  appMain.activityCenterStore.hasUnseenNotifications
                            onNotificationButtonClicked: Global.openActivityCenterPopup()

                            tokensModel: appMain.marketStore.marketLeaderboardModel
                            totalTokensCount: appMain.marketStore.totalLeaderboardCount
                            loading: appMain.marketStore.marketLeaderboardLoading
                            currencySymbol: {
                                const symbol = SQUtils.ModelUtils.getByKey(
                                                appMain.currencyStore.currenciesModel,
                                                "shortName",
                                                appMain.currencyStore.currentCurrency,
                                                "symbol")
                                return !!symbol ? symbol: ""
                            }
                            fnFormatCurrencyAmount: function(amount, options) {
                                return appMain.currencyStore.formatCurrencyAmount(amount, appMain.currencyStore.currentCurrency, options)
                            }
                            currentPage: appMain.marketStore.currentPage
                            onRequestLaunchSwap: popupRequestsHandler.swapModalHandler.launchSwap()
                            onFetchMarketTokens: appMain.marketStore.requestMarketTokenPage(pageNumber, pageSize)
                        }
                        onActiveChanged: {
                            if(!active) {
                               appMain.marketStore.unsubscribeFromUpdates()
                            }
                        }
                        onLoaded: item.resetView()
                    }

                    Repeater {
                        model: SortFilterProxyModel {
                            sourceModel: appMain.rootStore.mainModuleInst.sectionsModel
                            filters: ValueFilter {
                                roleName: "sectionType"
                                value: Constants.appSection.community
                            }
                        }

                        delegate: Loader {
                            readonly property string sectionId: model.id

                            Layout.fillWidth: true
                            Layout.alignment: Qt.AlignLeft | Qt.AlignTop
                            Layout.fillHeight: true

                            asynchronous: true
                            active: false

                            // Do not unload section data from the memory in order not
                            // to reset scroll, not send text input and etc during the
                            // sections switching
                            Binding on active {
                                when: sectionId === appMain.rootStore.mainModuleInst.activeSection.id
                                value: true
                                restoreMode: Binding.RestoreNone
                            }

                            sourceComponent: ChatLayout {
                                id: chatLayoutComponent

                                readonly property bool isManageCommunityEnabledInAdvanced: appMain.advancedStore.isManageCommunityOnTestModeEnabled

                                Connections {
                                    target: Global
                                    function onSwitchToCommunitySettings(communityId: string) {
                                        if (communityId !== model.id)
                                            return
                                        chatLayoutComponent.currentIndex = 1 // Settings
                                    }
                                    function onSwitchToCommunityChannelsView(communityId: string) {
                                        if (communityId !== model.id)
                                            return
                                        chatLayoutComponent.currentIndex = 0
                                    }
                                }
                                
                                navBar: appMain.navBar
                                emojiPopup: statusEmojiPopup.item
                                stickersPopup: statusStickersPopupLoader.item
                                sectionItemModel: model
                                createChatPropertiesStore: appMain.createChatPropertiesStore
                                communitiesStore: appMain.communitiesStore
                                communitySettingsDisabled: !chatLayoutComponent.isManageCommunityEnabledInAdvanced &&
                                                           (appMain.rootStore.isProduction && appMain.networksStore.areTestNetworksEnabled)
                                rootStore: ChatStores.RootStore {
                                    contactsStore: appMain.rootStore.contactStore
                                    currencyStore: appMain.currencyStore
                                    communityTokensStore: appMain.communityTokensStore
                                    emojiReactionsModel: appMain.rootStore.emojiReactionsModel
                                    openCreateChat: createChatView.opened

                                    chatCommunitySectionModule: {
                                        appMain.rootStore.mainModuleInst.prepareCommunitySectionModuleForCommunityId(model.id)
                                        return appMain.rootStore.mainModuleInst.getCommunitySectionModule()
                                    }
                                }
                                tokensStore: appMain.tokensStore
                                transactionStore: appMain.transactionStore
                                walletAssetsStore: appMain.walletAssetsStore
                                currencyStore: appMain.currencyStore
                                networksStore: appMain.networksStore
                                advancedStore: appMain.advancedStore
                                paymentRequestFeatureEnabled: featureFlagsStore.paymentRequestEnabled

                                mutualContactsModel: contactsModelAdaptor.mutualContacts

                                // Unfurling related data:
                                gifUnfurlingEnabled: appMain.sharedRootStore.gifUnfurlingEnabled
                                neverAskAboutUnfurlingAgain: appMain.sharedRootStore.neverAskAboutUnfurlingAgain

                                usersModel: rootStore.usersStore.usersModel

                                onProfileButtonClicked: {
                                    Global.changeAppSectionBySectionType(Constants.appSection.profile);
                                }

                                onOpenAppSearch: {
                                    appSearch.openSearchPopup()
                                }

                                onBuyStickerPackRequested: popupRequestsHandler.sendModalHandler.buyStickerPack(packId, price)
                                onTokenPaymentRequested: popupRequestsHandler.sendModalHandler.openTokenPaymentRequest(recipientAddress, symbol, rawAmount, chainId)

                                // Unfurling related requests:
                                onSetNeverAskAboutUnfurlingAgain: appMain.sharedRootStore.setNeverAskAboutUnfurlingAgain(neverAskAgain)

                                onOpenGifPopupRequest: popupRequestsHandler.statusGifPopupHandler.openGifs(params, cbOnGifSelected, cbOnClose)
                            }
                        }
                    }
                }

                Loader {
                    id: createChatView

                    property bool opened: false
                    readonly property real defaultWidth: parent.width - Constants.chatSectionLeftColumnWidth -
                             anchors.rightMargin - anchors.leftMargin
                    active: appMain.rootStore.mainModuleInst.sectionsLoaded && opened

                    asynchronous: true
                    anchors.top: parent.top
                    anchors.topMargin: 8
                    anchors.rightMargin: 8
                    anchors.bottom: parent.bottom
                    anchors.right: parent.right

                    sourceComponent: CreateChatView {
                        width: Math.min(Math.max(implicitWidth, createChatView.defaultWidth), createChatView.parent.width)
                        utilsStore: appMain.utilsStore
                        rootStore: ChatStores.RootStore {
                            contactsStore: appMain.rootStore.contactStore
                            currencyStore: appMain.currencyStore
                            communityTokensStore: appMain.communityTokensStore
                            emojiReactionsModel: appMain.rootStore.emojiReactionsModel
                            openCreateChat: createChatView.opened
                            chatCommunitySectionModule: appMain.rootStore.mainModuleInst.getChatSectionModule()
                        }
                        createChatPropertiesStore: appMain.createChatPropertiesStore

                        mutualContactsModel: contactsModelAdaptor.mutualContacts

                        emojiPopup: statusEmojiPopup.item
                        stickersPopup: statusStickersPopupLoader.item
                    }
                }
            }
        } // ColumnLayout

        Component {
            id: activityCenterPopupComponent
            ActivityCenterPopup {
                // TODO get screen size // Taken from old code top bar height was fixed there to 56
                readonly property int _buttonSize: 56

                x: parent.width - width - Theme.smallPadding
                y: parent.y + _buttonSize
                height: appView.height - _buttonSize * 2
                store: ChatStores.RootStore {
                    contactsStore: appMain.rootStore.contactStore
                    currencyStore: appMain.currencyStore
                    communityTokensStore: appMain.communityTokensStore
                    emojiReactionsModel: appMain.rootStore.emojiReactionsModel
                    openCreateChat: createChatView.opened
                    walletStore: WalletStores.RootStore
                    chatCommunitySectionModule: appMain.rootStore.mainModuleInst.getChatSectionModule()
                }
                activityCenterStore: appMain.activityCenterStore
                privacyStore: appMain.privacyStore
                notificationsStore: appMain.notificationsStore
            }
        }

        Action {
            shortcut: "Ctrl+1"
            onTriggered: {
                Global.setNthEnabledSectionActive(0)
            }
        }
        Action {
            shortcut: "Ctrl+2"
            onTriggered: {
                Global.setNthEnabledSectionActive(1)
            }
        }
        Action {
            shortcut: "Ctrl+3"
            onTriggered: {
                Global.setNthEnabledSectionActive(2)
            }
        }
        Action {
            shortcut: "Ctrl+4"
            onTriggered: {
                Global.setNthEnabledSectionActive(3)
            }
        }
        Action {
            shortcut: "Ctrl+5"
            onTriggered: {
                Global.setNthEnabledSectionActive(4)
            }
        }
        Action {
            shortcut: "Ctrl+6"
            onTriggered: {
                Global.setNthEnabledSectionActive(5)
            }
        }
        Action {
            shortcut: "Ctrl+7"
            onTriggered: {
                Global.setNthEnabledSectionActive(6)
            }
        }
        Action {
            shortcut: "Ctrl+8"
            onTriggered: {
                Global.setNthEnabledSectionActive(7)
            }
        }
        Action {
            shortcut: "Ctrl+9"
            onTriggered: {
                Global.setNthEnabledSectionActive(8)
            }
        }

        Action {
            shortcut: "Ctrl+K"
            onTriggered: {
                if (homePageLoader.active)
                    return
                // FIXME the focus is no longer on the AppMain when the popup is opened, so this does not work to close
                if (!channelPickerLoader.active)
                    channelPickerLoader.active = true

                if (channelPickerLoader.item.opened) {
                    channelPickerLoader.item.close()
                    channelPickerLoader.active = false
                } else {
                    channelPickerLoader.item.open()
                }
            }
        }
        Action {
            shortcut: "Ctrl+F"
            onTriggered: {
                // FIXME the focus is no longer on the AppMain when the popup is opened, so this does not work to close
                if (appSearch.active) {
                    appSearch.closeSearchPopup()
                } else {
                    appSearch.openSearchPopup()
                }
            }
        }

        Loader {
            id: channelPickerLoader
            active: false
            asynchronous: true
            sourceComponent: StatusSearchListPopup {
                searchBoxPlaceholder: qsTr("Where do you want to go?")
                model: rootStore.chatSearchModel

                onAboutToShow: rootStore.rebuildChatSearchModel()
                onSelected: {
                    rootStore.setActiveSectionChat(sectionId, chatId)
                    close()
                }
            }
        }
    }

    Shortcut {
        id: homePageShortcut
        context: Qt.ApplicationShortcut
        sequence: "Ctrl+J"
        onActivated: d.openHomePage()
        enabled: appMain.featureFlagsStore.homePageEnabled
    }

    StatusListView {
        id: toastArea
        objectName: "ephemeralNotificationList"
        anchors.right: parent.right
        anchors.rightMargin: 8
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 60
        width: 374
        height: Math.min(parent.height - 120, toastArea.contentHeight)
        spacing: 8
        verticalLayoutDirection: ListView.BottomToTop
        model: appMain.rootStore.mainModuleInst.ephemeralNotificationModel
        clip: false

        delegate: StatusToastMessage {
            readonly property bool isSquare : isSquareShape(model.actionData)

            // Specific method to calculate image radius depending on if the toast represents some info about a collectible or an asset
            function isSquareShape(data) {
                // It expects the data is a JSON file containing `tokenType`
                if(data) {
                    var parsedData = JSON.parse(data)
                    var tokenType = parsedData.tokenType
                    return tokenType === Constants.TokenType.ERC721
                }
                return false
            }

            objectName: "statusToastMessage"
            width: ListView.view.width
            primaryText: model.title
            secondaryText: model.subTitle
            image: model.image
            imageRadius: model.image && isSquare ? 8 : imageSize / 2
            icon.name: model.icon
            iconColor: model.iconColor
            loading: model.loading
            type: model.ephNotifType
            linkUrl: model.url
            actionRequired: model.actionType !== ToastsManager.ActionType.None
            duration: model.durationInMs
            onClicked: {
                appMain.rootStore.mainModuleInst.ephemeralNotificationClicked(model.timestamp)
                this.open = false
            }
            onLinkActivated: {
                this.open = false
                if(actionRequired) {
                    toastsManager.doAction(model.actionType, model.actionData)
                    return
                }

                if (link.startsWith("#") && link !== "#") { // internal link to section
                    const sectionArgs = link.substring(1).split("/")
                    const section = sectionArgs[0]
                    let subsection = sectionArgs.length > 1 ? sectionArgs[1] : 0
                    let subsubsection = sectionArgs.length > 2 ? sectionArgs[2] : -1
                    Global.changeAppSectionBySectionType(section, subsection, subsubsection)
                }
                else
                    Global.openLink(link)
            }
            onClose: {
                appMain.rootStore.mainModuleInst.removeEphemeralNotification(model.timestamp)
            }
        }
    }

    Loader {
        id: keycardPopupForAuthenticationOrSigning
        active: false
        sourceComponent: KeycardPopup {
            myKeyUid: appMain.profileStore.keyUid
            sharedKeycardModule: appMain.rootStore.mainModuleInst.keycardSharedModuleForAuthenticationOrSigning
        }

        onLoaded: {
            keycardPopupForAuthenticationOrSigning.item.open()
        }
    }

    Loader {
        id: keycardPopup
        active: false
        sourceComponent: KeycardPopup {
            myKeyUid: appMain.profileStore.keyUid
            sharedKeycardModule: appMain.rootStore.mainModuleInst.keycardSharedModule
        }

        onLoaded: {
            keycardPopup.item.open()
        }
    }

    Loader {
        id: addEditSavedAddress

        active: false

        property var params

        function open(params = {}) {
            addEditSavedAddress.params = params
            addEditSavedAddress.active = true
        }

        function close() {
            addEditSavedAddress.active = false
        }

        onLoaded: {
            addEditSavedAddress.item.initWithParams(addEditSavedAddress.params)
            addEditSavedAddress.item.open()
        }

        sourceComponent: WalletPopups.AddEditSavedAddressPopup {
            store: WalletStores.RootStore
            sharedRootStore: appMain.sharedRootStore

            onClosed: {
                addEditSavedAddress.close()
            }
        }

        Connections {
            target: WalletStores.RootStore

            function onSavedAddressAddedOrUpdated(added: bool, name: string, address: string, errorMsg: string) {
                WalletStores.RootStore.addingSavedAddress = false
                WalletStores.RootStore.lastCreatedSavedAddress = { address: address, error: errorMsg }

                if (!!errorMsg) {
                    let mode = qsTr("adding")
                    if (!added) {
                        mode = qsTr("editing")
                    }

                    Global.displayToastMessage(qsTr("An error occurred while %1 %2 address").arg(mode).arg(name),
                                               "",
                                               "warning",
                                               false,
                                               Constants.ephemeralNotificationType.danger,
                                               ""
                                               )
                    return
                }

                let msg = qsTr("%1 successfully added to your saved addresses")
                if (!added) {
                    msg = qsTr("%1 saved address successfully edited")
                }
                Global.displayToastMessage(msg.arg(name),
                                           "",
                                           "checkmark-circle",
                                           false,
                                           Constants.ephemeralNotificationType.success,
                                           ""
                                           )

            }
        }
    }

    Loader {
        id: deleteSavedAddress

        active: false

        property var params

        function open(params = {}) {
            deleteSavedAddress.params = params
            deleteSavedAddress.active = true
        }

        function close() {
            deleteSavedAddress.active = false
        }

        onLoaded: {
            deleteSavedAddress.item.address = deleteSavedAddress.params.address?? ""
            deleteSavedAddress.item.ens = deleteSavedAddress.params.ens?? ""
            deleteSavedAddress.item.name = deleteSavedAddress.params.name?? ""
            deleteSavedAddress.item.colorId = deleteSavedAddress.params.colorId?? "blue"

            deleteSavedAddress.item.open()
        }

        sourceComponent: WalletPopups.RemoveSavedAddressPopup {
            onClosed: {
                deleteSavedAddress.close()
            }

            onRemoveSavedAddress: {
                WalletStores.RootStore.deleteSavedAddress(address)
                close()
            }
        }

        Connections {
            target: WalletStores.RootStore

            function onSavedAddressDeleted(name: string, address: string, errorMsg: string) {
                WalletStores.RootStore.deletingSavedAddress = false

                if (!!errorMsg) {

                    Global.displayToastMessage(qsTr("An error occurred while removing %1 address").arg(name),
                                               "",
                                               "warning",
                                               false,
                                               Constants.ephemeralNotificationType.danger,
                                               ""
                                               )
                    return
                }

                Global.displayToastMessage(qsTr("%1 was successfully removed from your saved addresses").arg(name),
                                           "",
                                           "checkmark-circle",
                                           false,
                                           Constants.ephemeralNotificationType.success,
                                           ""
                                           )
            }
        }
    }

    Loader {
        id: showQR

        active: false

        property bool showSingleAccount: false
        property bool showForSavedAddress: false
        property var params
        property var selectedAccount: ({
                                           name: "",
                                           address: "",
                                           colorId: "",
                                           emoji: ""
                                       })

        function open(params = {}) {
            showQR.showSingleAccount = params.showSingleAccount?? false
            showQR.showForSavedAddress = params.showForSavedAddress?? false
            showQR.params = params

            if (showQR.showSingleAccount || showQR.showForSavedAddress) {
                showQR.selectedAccount.name = params.name?? ""
                showQR.selectedAccount.address = params.address?? ""
                showQR.selectedAccount.colorId = params.colorId?? ""
                showQR.selectedAccount.emoji = params.emoji?? ""
            }

            showQR.active = true
        }

        function close() {
            showQR.active = false
        }

        onLoaded: {
            showQR.item.switchingAccounsEnabled = showQR.params.switchingAccounsEnabled?? true
            showQR.item.hasFloatingButtons = showQR.params.hasFloatingButtons?? true

            showQR.item.open()
        }

        sourceComponent: WalletPopups.ReceiveModal {

            ModelEntry {
                id: selectedReceiverAccount
                key: "address"
                sourceModel: appMain.transactionStore.accounts
                value: appMain.transactionStore.selectedReceiverAccountAddress
            }

            accounts: {
                if (showQR.showSingleAccount || showQR.showForSavedAddress) {
                    return null
                }
                return WalletStores.RootStore.accounts
            }

            selectedAccount: {
                if (showQR.showSingleAccount || showQR.showForSavedAddress) {
                    return showQR.selectedAccount
                }
                return selectedReceiverAccount.item ?? SQUtils.ModelUtils.get(appMain.transactionStore.accounts, 0)
            }

            onUpdateSelectedAddress: (address) => {
                if (showQR.showSingleAccount || showQR.showForSavedAddress) {
                    return
                }
                appMain.transactionStore.setReceiverAccount(address)
            }

            onClosed: {
                showQR.close()
            }
        }
    }


    Loader {
        id: savedAddressActivity

        active: false

        property var params

        function open(params = {}) {
            savedAddressActivity.params = params
            savedAddressActivity.active = true
        }

        function close() {
            savedAddressActivity.active = false
        }

        onLoaded: {
            savedAddressActivity.item.initWithParams(savedAddressActivity.params)
            savedAddressActivity.item.open()
        }

        sourceComponent: WalletPopups.SavedAddressActivityPopup {
            networkConnectionStore: appMain.networkConnectionStore
            contactsStore: appMain.rootStore.contactStore
            networksStore: appMain.networksStore

            onSendToAddressRequested: {
                Global.sendToRecipientRequested(address)
            }
            onClosed: {
                savedAddressActivity.close()
            }
        }
    }

    Component {
        id: introduceYourselfPopupComponent
        IntroduceYourselfPopup {
            visible: true
            destroyOnClose: true
            pubKey: appMain.profileStore.compressedPubKey
            colorId: appMain.profileStore.colorId
            colorHash: appMain.profileStore.colorHash
            onClosed: appMainLocalSettings.introduceYourselfPopupSeen = true
            onAccepted: Global.changeAppSectionBySectionType(Constants.appSection.profile)
        }
    }

    DAppsMetrics {
        id: dappMetrics
        metricsStore: SharedStores.MetricsStore {}
    }

    Loader {
        id: dAppsServiceLoader

        signal dappDisconnectRequested(string dappUrl)
        signal dappConnectRequested()

        // It seems some of the functionality of the dapp connector depends on the DAppsService
        active: {
            return (featureFlagsStore.dappsEnabled || featureFlagsStore.connectorEnabled) && appMain.visible
        }

        sourceComponent: DAppsService {
            id: dAppsService

            DAppsPopups.DAppsWorkflow {
                id: dappsWorkflow

                enabled: dAppsService.isServiceOnline
                visualParent: appMain
                loginType: appMain.rootStore.loginType
                selectedAccountAddress: WalletStores.RootStore.selectedAddress
                dAppsModel: dAppsService.dappsModel
                accountsModel: WalletStores.RootStore.nonWatchAccounts
                networksModel: appMain.networksStore.activeNetworks
                sessionRequestsModel: dAppsService.sessionRequestsModel
                walletConnectEnabled: featureFlagsStore.dappsEnabled
                connectorEnabled: featureFlagsStore.connectorEnabled

                formatBigNumber: (number, symbol, noSymbolOption) => WalletStores.RootStore.currencyStore.formatBigNumber(number, symbol, noSymbolOption)

                onDisconnectRequested: (connectionId) => dAppsService.disconnectDapp(connectionId)
                onPairingRequested: (uri) => dAppsService.pair(uri)
                onPairingValidationRequested: (uri) => dAppsService.validatePairingUri(uri)
                onConnectionAccepted: (pairingId, chainIds, selectedAccount) => dAppsService.approvePairSession(pairingId, chainIds, selectedAccount)
                onConnectionDeclined: (pairingId) => dAppsService.rejectPairSession(pairingId)
                onSignRequestAccepted: (connectionId, requestId) => dAppsService.sign(connectionId, requestId)
                onSignRequestRejected: (connectionId, requestId) => dAppsService.rejectSign(connectionId, requestId, false /*hasError*/)
                onSignRequestIsLive: (connectionId, requestId) => dAppsService.signRequestIsLive(connectionId, requestId)
                onPairWithConnectorRequested: (connectorId) => {
                    dappMetrics.logNavigationEvent(DAppsMetrics.DAppsNavigationAction.DAppPairInitiated, connectorId)
                    if (connectorId == Constants.DAppConnectors.WalletConnect) {
                        dappsWorkflow.openPairing()
                    } else if (connectorId == Constants.DAppConnectors.StatusConnect) {
                        Global.openLink("https://chromewebstore.google.com/detail/a-wallet-connector-by-sta/kahehnbpamjplefhpkhafinaodkkenpg")
                    }
                }

                Connections {
                    target: dAppsServiceLoader

                    function onDappConnectRequested() {
                        dappsWorkflow.chooseConnector()
                    }

                    function onDappDisconnectRequested(dappUrl) {
                        dappsWorkflow.disconnectDapp(dappUrl)
                    }
                }
            }

            // DAppsModule provides the middleware for the dapps
            dappsModule: DAppsModule {
                currenciesStore: WalletStores.RootStore.currencyStore
                groupedAccountAssetsModel: WalletStores.RootStore.walletAssetsStore.groupedAccountAssetsModel
                accountsModel: WalletStores.RootStore.nonWatchAccounts
                dappsMetrics: dappMetrics
                networksModel: SortFilterProxyModel {
                    sourceModel: appMain.networksStore.activeNetworks
                    proxyRoles: [
                        FastExpressionRole {
                            name: "isOnline"
                            expression: !appMain.networkConnectionStore.blockchainNetworksDown.map(Number).includes(model.chainId)
                            expectedRoles: "chainId"
                        }
                    ]
                }
                wcSdk: WalletConnectSDK {
                    enabled: featureFlagsStore.dappsEnabled && WalletStores.RootStore.walletSectionInst.walletReady
                    userUID: appMain.profileStore.pubKey
                    projectId: WalletStores.RootStore.appSettings.walletConnectProjectID
                }
                bcSdk: DappsConnectorSDK {
                    enabled: featureFlagsStore.connectorEnabled && WalletStores.RootStore.walletSectionInst.walletReady
                    store: SharedStores.BrowserConnectStore {
                        controller: WalletStores.RootStore.dappsConnectorController
                    }
                    networksModel: appMain.networksStore.activeNetworks
                    accountsModel: WalletStores.RootStore.nonWatchAccounts
                }
                store: SharedStores.DAppsStore {
                    controller: WalletStores.RootStore.walletConnectController
                }
            }
            selectedAddress: WalletStores.RootStore.selectedAddress
            accountsModel: WalletStores.RootStore.nonWatchAccounts
            connectorFeatureEnabled: featureFlagsStore.connectorEnabled
            walletConnectFeatureEnabled: featureFlagsStore.dappsEnabled

            onDisplayToastMessage: (message, type) => {
                const icon = type === Constants.ephemeralNotificationType.danger ? "warning" :
                            type === Constants.ephemeralNotificationType.success ? "checkmark-circle" : "info"
                Global.displayToastMessage(message, "", icon, false, type, "")
            }
            onPairingValidated: (validationState) => {
                dappsWorkflow.pairingValidated(validationState)
            }
            onApproveSessionResult: (pairingId, err, newConnectionId) => {
                if (err) {
                    dappsWorkflow.connectionFailed(pairingId)
                    return
                }

                dappsWorkflow.connectionSuccessful(pairingId, newConnectionId)
            }
            onConnectDApp: (dappChains, dappUrl, dappName, dappIcon, connectorIcon, pairingId) => {
                dappsWorkflow.connectDApp(dappChains, dappUrl, dappName, dappIcon, connectorIcon, pairingId)
            }
        }
    }

    Connections {
        target: ClipboardUtils

        function onContentChanged() {
            if (!ClipboardUtils.hasText)
                return

            const text = ClipboardUtils.text

            if (text.length === 0 || text.length > 100)
                return

            const isAddress = SQUtils.ModelUtils.contains(
                              WalletStores.RootStore.accounts, "address",
                              text, Qt.CaseInsensitive)
            if (isAddress)
                WalletStores.RootStore.addressWasShown(text)
        }
    }
}
