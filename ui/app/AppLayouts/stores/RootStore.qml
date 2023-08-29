import QtQuick 2.13

import utils 1.0

import SortFilterProxyModel 0.2
import AppLayouts.Wallet.stores 1.0 as WalletStore

import "../Profile/stores"

QtObject {
    id: root

    property var mainModuleInst: mainModule
    property var walletSectionInst: walletSection
    property var aboutModuleInst: aboutModule
    property var communitiesModuleInst: communitiesModule
    property bool newVersionAvailable: false
    property string latestVersion
    property string downloadURL

    readonly property int loginType: getLoginType()
    function getLoginType() {
        if(!userProfileInst)
            return Constants.LoginType.Password

        if(userProfileInst.usingBiometricLogin)
            return Constants.LoginType.Biometrics
        if(userProfileInst.isKeycardUser)
            return Constants.LoginType.Keycard
        return Constants.LoginType.Password
    }

    function prepareTokenModelForCommunity(publicKey) {
        root.communitiesModuleInst.prepareTokenModelForCommunity(publicKey)
    }

    property string communityKeyToImport
    onCommunityKeyToImportChanged: {
        if (!!communityKeyToImport)
            root.prepareTokenModelForCommunity(communityKeyToImport);
    }

    readonly property var permissionsModel: !!root.communitiesModuleInst.spectatedCommunityPermissionModel ?
                                     root.communitiesModuleInst.spectatedCommunityPermissionModel : null
    property var walletAccountsModel: WalletStore.RootStore.nonWatchAccounts
    property var assetsModel: SortFilterProxyModel {
        sourceModel: communitiesModuleInst.tokenList
        proxyRoles: ExpressionRole {
            function tokenIcon(symbol) {
                return Constants.tokenIcon(symbol)
            }
            name: "iconSource"
            expression: !!model.icon ? model.icon : tokenIcon(model.symbol)
        }
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
        sourceModel: communitiesModuleInst.collectiblesModel
        proxyRoles: ExpressionRole {
            function collectibleIcon(icon) {
                return !!icon ? icon : Style.png("tokens/DEFAULT-TOKEN")
            }
            name: "iconSource"
            expression: collectibleIcon(model.icon)
        }
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

    property ProfileSectionStore profileSectionStore: ProfileSectionStore {
    }

    property EmojiReactions emojiReactionsModel: EmojiReactions {
    }

    property var chatSearchModel: mainModuleInst.chatSearchModel

    function rebuildChatSearchModel() {
        mainModuleInst.rebuildChatSearchModel()
    }

    function setActiveSectionChat(sectionId, chatId) {
        mainModuleInst.switchTo(sectionId, chatId)
    }

    // Not Refactored Yet
//    property var chatsModelInst: chatsModel
    // Not Refactored Yet
//    property var walletModelInst: walletModel
    property var userProfileInst: userProfile

    property var accounts: walletSectionSendInst.accounts
    // Not Refactored Yet
//    property var profileModelInst: profileModel
    property var tokensModelWallet//TODO this is not available yet

    property var contactStore: profileSectionStore.contactsStore
    property var privacyStore: profileSectionStore.privacyStore
    property var messagingStore: profileSectionStore.messagingStore
    property bool hasAddedContacts: contactStore.myContactsModel.count > 0

//    property MessageStore messageStore: MessageStore { }

    property real volume: !!appSettings ? appSettings.volume * 0.01 : 0.5
    property bool notificationSoundsEnabled: !!appSettings ? appSettings.notificationSoundsEnabled : true

    property var walletSectionSendInst: walletSectionSend

    property var savedAddressesModel: walletSectionSavedAddresses.model

    readonly property bool showBrowserSelector: localAccountSensitiveSettings.showBrowserSelector
    readonly property bool openLinksInStatus: localAccountSensitiveSettings.openLinksInStatus

    property var allNetworks: networksModule.all

    function getEtherscanLink() {
        return profileSectionModule.ensUsernamesModule.getEtherscanLink()
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

    function isCommunityRequestPending(id: string) {
        return communitiesModuleInst.isCommunityRequestPending(id)
    }

    function cancelPendingRequest(id: string) {
        communitiesModuleInst.cancelRequestToJoinCommunity(id)
    }

    function copyToClipboard(text) {
        globalUtils.copyToClipboard(text)
    }

    function plainText(text) {
        return globalUtils.plainText(text);
    }

    function generateAlias(pk) {
        return globalUtils.generateAlias(pk);
    }

    property string currentCurrency: walletSection.currentCurrency
    property string signingPhrase: walletSection.signingPhrase
    function getFiatValue(balance, cryptoSymbol, fiatSymbol) {
        return profileSectionStore.ensUsernamesStore.getFiatValue(balance, cryptoSymbol, fiatSymbol)
    }
    function getGasEthValue(gweiValue, gasLimit) {
        return profileSectionStore.ensUsernamesStore.getGasEthValue(gweiValue, gasLimit)
    }

    function suggestedFees(chainId) {
        return JSON.parse(walletSectionSendInst.suggestedFees(chainId))
    }

    function getEstimatedTime(chainId, maxFeePerGas) {
       return walletSectionSendInst.getEstimatedTime(chainId, maxFeePerGas)
    }

    function hex2Eth(value) {
        return globalUtils.hex2Eth(value)
    }

    function setCurrentUserStatus(newStatus) {
        if (userProfileInst && userProfileInst.currentUserStatus !== newStatus) {
            mainModuleInst.setCurrentUserStatus(newStatus)
        }
    }

    function setActiveCommunity(communityId) {
        mainModuleInst.setActiveSectionById(communityId);
    }

    function resolveENS(value) {
        mainModuleInst.resolveENS(value, "")
    }

    function windowActivated() {
        mainModuleInst.windowActivated()
    }

    function windowDeactivated() {
        mainModuleInst.windowDeactivated()
    }

    function requestToJoinCommunityWithAuthentication(communityId, ensName, addressesToShare = [], airdropAddress = "") {
        communitiesModuleInst.requestToJoinCommunityWithAuthenticationWithSharedAddresses(
            communityId, ensName, JSON.stringify(addressesToShare), airdropAddress)
    }

    function editSharedAddressesWithAuthentication(communityId, addressesToShare = [], airdropAddress = "") {
        communitiesModuleInst.editSharedAddressesWithAuthentication(
            communityId, JSON.stringify(addressesToShare), airdropAddress)
    }

    function updatePermissionsModel(communityId, sharedAddresses) {
        communitiesModuleInst.checkPermissions(communityId, JSON.stringify(sharedAddresses))
    }
}
