import QtQuick 2.13

import utils 1.0

import StatusQ 0.1
import StatusQ.Core.Theme 0.1

import SortFilterProxyModel 0.2
import AppLayouts.Profile.stores 1.0 as ProfileStores
import AppLayouts.Wallet.stores 1.0 as WalletStore

QtObject {
    id: root

    property var mainModuleInst: mainModule
    property var walletSectionInst: walletSection
    property var aboutModuleInst: aboutModule
    property var communitiesModuleInst: communitiesModule
    property bool newVersionAvailable: false
    readonly property bool requirementsCheckPending: communitiesModuleInst.requirementsCheckPending
    readonly property bool checkingPermissionToJoinInProgress: communitiesModuleInst.checkingPermissionToJoinInProgress
    readonly property bool joinPermissionsCheckCompletedWithoutErrors: communitiesModuleInst.joinPermissionsCheckCompletedWithoutErrors
    readonly property bool channelsPermissionsCheckSuccessful: communitiesModuleInst.channelsPermissionsCheckSuccessful
    property string latestVersion
    property string downloadURL

    readonly property int loginType: getLoginType()
    function getLoginType() {
        if(!d.userProfileInst)
            return Constants.LoginType.Password

        if(d.userProfileInst.usingBiometricLogin)
            return Constants.LoginType.Biometrics
        if(d.userProfileInst.isKeycardUser)
            return Constants.LoginType.Keycard
        return Constants.LoginType.Password
    }

    function prepareTokenModelForCommunity(publicKey) {
        root.communitiesModuleInst.prepareTokenModelForCommunity(publicKey)
    }

    property string communityKeyToImport

    readonly property var permissionsModel: !!root.communitiesModuleInst.spectatedCommunityPermissionModel ?
                                     root.communitiesModuleInst.spectatedCommunityPermissionModel : null

    readonly property var myRevealedAddressesForCurrentCommunity: {
        try {
            let revealedAddresses = root.communitiesModuleInst.myRevealedAddressesStringForCurrentCommunity
            let revealedAddressArray = JSON.parse(revealedAddresses)
            return revealedAddressArray.map(addr => addr.toLowerCase())
        } catch (e) {
            console.error("Error parsing my revealed addresses", e)
        }
        return []
    }
    readonly property string myRevealedAirdropAddressForCurrentCommunity:
        root.communitiesModuleInst.myRevealedAirdropAddressForCurrentCommunity.toLowerCase()

    property var walletAccountsModel: WalletStore.RootStore.nonWatchAccounts
    
    readonly property var globalAssetsModel: SortFilterProxyModel {
        sourceModel: communitiesModuleInst.tokenList

        proxyRoles: FastExpressionRole {
            function tokenIcon(symbol) {
                return Constants.tokenIcon(symbol)
            }
            name: "iconSource"
            expression: !!model.icon ? model.icon : tokenIcon(model.symbol)
            expectedRoles: ["icon", "symbol"]
        }
    }

    readonly property var globalCollectiblesModel: SortFilterProxyModel {
        sourceModel: communitiesModuleInst.collectiblesModel

        proxyRoles: FastExpressionRole {
            function collectibleIcon(icon) {
                return !!icon ? icon : Theme.png("tokens/DEFAULT-TOKEN")
            }
            name: "iconSource"
            expression: collectibleIcon(model.icon)
            expectedRoles: ["icon"]
        }
    }

    property var assetsModel: SortFilterProxyModel {
        sourceModel: globalAssetsModel
        filters: [
            AnyOf {
                // We accept tokens from this community or general (empty community ID)
                ValueFilter {
                    roleName: "communityId"
                    value: ""
                }

                ValueFilter {
                    roleName: "communityId"
                    value: root.communityKeyToImport
                }
            }
        ]
    }
    property var collectiblesModel: SortFilterProxyModel {
        sourceModel: globalCollectiblesModel
        filters: [
            AnyOf {
                // We accept tokens from this community or general (empty community ID)
                ValueFilter {
                    roleName: "communityId"
                    value: ""
                }

                ValueFilter {
                    roleName: "communityId"
                    value: root.communityKeyToImport
                }
            }
        ]
    }

    function setLatestVersionInfo(newVersionAvailable, latestVersion, downloadURL) {
        root.newVersionAvailable = newVersionAvailable;
        root.latestVersion = latestVersion;
        root.downloadURL = downloadURL;
    }

    function resetLastVersion(){
        root.newVersionAvailable = false
    }

    property AppSearchStore appSearchStore: AppSearchStore {
        appSearchModule: root.mainModuleInst.appSearchModule
    }

    property ProfileStores.ProfileSectionStore profileSectionStore: ProfileStores.ProfileSectionStore {
    }

    property var chatSearchModel: mainModuleInst.chatSearchModel

    function rebuildChatSearchModel() {
        mainModuleInst.rebuildChatSearchModel()
    }

    function setActiveSectionChat(sectionId, chatId) {
        mainModuleInst.switchTo(sectionId, chatId)
    }


    readonly property var accounts: walletSectionAccounts.accounts

    property ProfileStores.ContactsStore contactStore: profileSectionStore.contactsStore
    property ProfileStores.PrivacyStore privacyStore: profileSectionStore.privacyStore
    property ProfileStores.MessagingStore messagingStore: profileSectionStore.messagingStore

    property real volume: !!appSettings ? appSettings.volume * 0.01 : 0.5
    property bool notificationSoundsEnabled: !!appSettings ? appSettings.notificationSoundsEnabled : true

    property var walletSectionSendInst: walletSectionSend

    property var savedAddressesModel: walletSectionSavedAddresses.model

    readonly property QtObject _d: QtObject {
        id: d

        readonly property var userProfileInst: userProfile
        readonly property Connections mainModuleConnections: Connections {
            target: root.mainModuleInst
            
            function onResolvedENS(resolvedPubKey, resolvedAddress, uuid) {
                root.ensNameResolved(resolvedPubKey, resolvedAddress, uuid)
            }

            function onOpenUrl(url) {
                root.openUrl(url)
            }
        }
    }

    function getEtherscanTxLink(chainID) {
        return networksModule.getBlockExplorerTxURL(chainID)
    }

    function createCommunity(communityName, communityDescription, checkedMembership, communityColor, communityTags,
                             communityImage, imageCropperModalaX, imageCropperModalaY, imageCropperModalbX, imageCropperModalbY,
                             historyArchiveSupportEnabled, pinMessagesAllowedForMembers, bannerJsonStr, encrypted) {
        communitiesModuleInst.createCommunity(communityName, communityDescription, checkedMembership, communityColor,
                                              communityTags, communityImage, imageCropperModalaX, imageCropperModalaY,
                                              imageCropperModalbX, imageCropperModalbY,
                                              historyArchiveSupportEnabled, pinMessagesAllowedForMembers,
                                              bannerJsonStr, encrypted);
    }

    function communityHasMember(communityId, pubKey)
    {
        return communitiesModuleInst.isMemberOfCommunity(communityId, pubKey)
    }

    function isMyCommunityRequestPending(id: string) {
        return communitiesModuleInst.isMyCommunityRequestPending(id)
    }

    function cancelPendingRequest(id: string) {
        communitiesModuleInst.cancelRequestToJoinCommunity(id)
    }

    property string currentCurrency: walletSection.currentCurrency

    function getFiatValue(balance, cryptoSymbol, fiatSymbol) {
        return profileSectionStore.ensUsernamesStore.getFiatValue(balance, cryptoSymbol, fiatSymbol)
    }

    function setCurrentUserStatus(newStatus) {
        if (d.userProfileInst && d.userProfileInst.currentUserStatus !== newStatus) {
            mainModuleInst.setCurrentUserStatus(newStatus)
        }
    }

    function setActiveCommunity(communityId) {
        mainModuleInst.setActiveSectionById(communityId);
    }

    function resolveENS(value, uuid = "") {
        mainModuleInst.resolveENS(value, uuid)
    }

    function windowActivated() {
        mainModuleInst.windowActivated()
    }

    function windowDeactivated() {
        mainModuleInst.windowDeactivated()
    }

    function prepareKeypairsForSigning(communityId, ensName, addressesToShare = [], airdropAddress = "", editMode = false) {
        communitiesModuleInst.prepareKeypairsForSigning(communityId, ensName, JSON.stringify(addressesToShare), airdropAddress, editMode)
    }

    function signProfileKeypairAndAllNonKeycardKeypairs() {
        communitiesModuleInst.signProfileKeypairAndAllNonKeycardKeypairs()
    }

    function signSharedAddressesForKeypair(keyUid) {
        communitiesModuleInst.signSharedAddressesForKeypair(keyUid)
    }

    function joinCommunityOrEditSharedAddresses() {
        communitiesModuleInst.joinCommunityOrEditSharedAddresses()
    }

    function cleanJoinEditCommunityData() {
        communitiesModuleInst.cleanJoinEditCommunityData()
    }

    function updatePermissionsModel(communityId, sharedAddresses) {
        communitiesModuleInst.checkPermissions(communityId, JSON.stringify(sharedAddresses))
    }

    function promoteSelfToControlNode(communityId) {
        communitiesModuleInst.promoteSelfToControlNode(communityId)
    }

    signal ensNameResolved(string resolvedPubKey, string resolvedAddress, string uuid)
    signal openUrl(string link)
}
