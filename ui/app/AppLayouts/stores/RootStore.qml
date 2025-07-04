import QtQuick

import utils

import StatusQ
import StatusQ.Core.Theme

import SortFilterProxyModel
import AppLayouts.Profile.stores as ProfileStores
import AppLayouts.Wallet.stores as WalletStore

// WIP: Previous reorganization step before refactoring `RootStore`
QtObject {
    id: root

    // Global properties that have to remain on `RootStore` (the module instances must be private properties and just used to initialize the
    // rest and specific stores
    readonly property var isProduction: production
    property var mainModuleInst: mainModule // Move inside d (convert to private)

    // Here define the needed properties that access to `Context Properties`:
    readonly property QtObject _internal: QtObject{
      id: internal // Rename to `d` when cleanup done

      // TODO:
      //readonly property var mainModuleInst: mainModule
    }

    // Here there should be all the ContextSpecificRootStore objects creation
    readonly property ProfileStores.ProfileSectionStore profileSectionStore: ProfileStores.ProfileSectionStore {
    }
    readonly property ProfileStores.ContactsStore contactStore: profileSectionStore.contactsStore // It should be extracted from `ProfileSectionStore`
    // since it's not a profile specific thing but a global store

    // readonly property ChatStores.RootStore rootChatStore: ChatStores.RootStore { ... }
    // readonly property ActivityCenterStore activityCenterStore: ActivityCenterStore { ... }
    // readonly property SharedStores.NetworkConnectionStore networkConnectionStore: SharedStores.NetworkConnectionStore { ... }
    // + all the rest of stores now created on `AppMain`

    // Here the definition of global functions
    function windowActivated() {
        mainModuleInst.windowActivated()
        //d.mainModuleInst.windowActivated()
    }

    function windowDeactivated() {
        mainModuleInst.windowDeactivated()
        //d.mainModuleInst.windowDeactivated()
    }
    // End of RootStore related stuff (Just the above code should be part of `RootStore`)

    // Settings related properties and functions that shall be moved to `SettingsRootStore`
    property var aboutModuleInst: aboutModule // To be removed. All versioning related stuff should be managed by `AboutStore`. `aboutModuleInst` should not be accessed externally.
    property bool newVersionAvailable: false

    property string latestVersion
    property string downloadURL

    function setLatestVersionInfo(newVersionAvailable, latestVersion, downloadURL) {
        root.newVersionAvailable = newVersionAvailable;
        root.latestVersion = latestVersion;
        root.downloadURL = downloadURL;
    }

    function resetLastVersion(){
        root.newVersionAvailable = false
    }

    property real volume: !!appSettings ? appSettings.volume * 0.01 : 0.5
    property bool notificationSoundsEnabled: !!appSettings ? appSettings.notificationSoundsEnabled : true

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

    function setCurrentUserStatus(newStatus) {
        if (d.userProfileInst && d.userProfileInst.currentUserStatus !== newStatus) {
            mainModuleInst.setCurrentUserStatus(newStatus)
        }
    }

    function resolveENS(value, uuid = "") {
        mainModuleInst.resolveENS(value, uuid)
    }

    signal ensNameResolved(string resolvedPubKey, string resolvedAddress, string uuid)
    signal openUrl(string link)

    // End of Settings related stuff

    // Onboarding related properties and functions that shall be moved to `OnboardingRootStore`
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
    // End of Onboarding related stuff

    // Chat related properties and functions that shall be moved to `ChatRootStore`
    property AppSearchStore appSearchStore: AppSearchStore {
        appSearchModule: root.mainModuleInst.appSearchModule
    }
    property var chatSearchModel: mainModuleInst.chatSearchModel

    function rebuildChatSearchModel() {
        mainModuleInst.rebuildChatSearchModel()
    }

    function setActiveSectionChat(sectionId, chatId) {
        mainModuleInst.switchTo(sectionId, chatId)
    }
    // End of Chat related stuff

    // Communities related properties and functions that shall be moved to `CommunitiesRootStore`
    property var communitiesModuleInst: communitiesModule // Should be removed and used only inside `CommunitiesRootStore` AND private, not accessible from outside components
    readonly property bool requirementsCheckPending: communitiesModuleInst.requirementsCheckPending
    readonly property bool checkingPermissionToJoinInProgress: communitiesModuleInst.checkingPermissionToJoinInProgress
    readonly property bool joinPermissionsCheckCompletedWithoutErrors: communitiesModuleInst.joinPermissionsCheckCompletedWithoutErrors
    readonly property bool channelsPermissionsCheckSuccessful: communitiesModuleInst.channelsPermissionsCheckSuccessful

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

    function prepareTokenModelForCommunity(publicKey) {
        root.communitiesModuleInst.prepareTokenModelForCommunity(publicKey)
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

    function setActiveCommunity(communityId) {
        mainModuleInst.setActiveSectionById(communityId);
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
    // End of Community related stuff

    // Wallet related properties and functions that shall be moved to `WalletRootStore`
    property var walletSectionSendInst: walletSectionSend
    property var savedAddressesModel: walletSectionSavedAddresses.model
    readonly property var accounts: walletSectionAccounts.accounts
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

    function getEtherscanTxLink(chainID) {
        return networksModule.getBlockExplorerTxURL(chainID)
    }


    property string currentCurrency: walletSection.currentCurrency

    function getFiatValue(balance, cryptoSymbol, fiatSymbol) {
        return profileSectionStore.ensUsernamesStore.getFiatValue(balance, cryptoSymbol, fiatSymbol)
    }
    // End of Wallet related stuff
}
