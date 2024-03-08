import QtQuick 2.15
import QtQml 2.15

import utils 1.0

QtObject {
    id: root

    property var profileModule

    property string pubkey: !!Global.userProfile? Global.userProfile.pubKey : ""
    property string name: !!Global.userProfile? Global.userProfile.name : ""
    property string username: !!Global.userProfile? Global.userProfile.username : ""
    property string displayName: !!Global.userProfile? Global.userProfile.displayName : ""
    property string preferredName: !!Global.userProfile? Global.userProfile.preferredName : ""
    property string profileLargeImage: !!Global.userProfile? Global.userProfile.largeImage : ""
    property string icon: !!Global.userProfile? Global.userProfile.icon : ""
    property bool userDeclinedBackupBanner: Global.appIsReady? localAccountSensitiveSettings.userDeclinedBackupBanner : false
    property var privacyStore: profileSectionModule.privacyModule
    readonly property string keyUid: !!Global.userProfile ? Global.userProfile.keyUid : ""
    readonly property bool isKeycardUser: !!Global.userProfile ? Global.userProfile.isKeycardUser : false

    readonly property string bio: profileModule.bio
    readonly property string socialLinksJson: profileModule.socialLinksJson
    readonly property var socialLinksModel: profileModule.socialLinksModel
    readonly property var temporarySocialLinksModel: profileModule.temporarySocialLinksModel // for editing purposes
    readonly property var temporarySocialLinksJson: profileModule.temporarySocialLinksJson
    readonly property bool socialLinksDirty: profileModule.socialLinksDirty

    readonly property bool isWalletEnabled: Global.appIsReady? mainModule.sectionsModel.getItemEnabledBySectionType(Constants.appSection.wallet) : true

    readonly property var collectiblesModel: profileModule.collectiblesModel

    readonly property var showcasePreferencesCommunitiesModel: profileModule.showcasePreferencesCommunitiesModel
    readonly property var showcasePreferencesAccountsModel: profileModule.showcasePreferencesAccountsModel
    readonly property var showcasePreferencesCollectiblesModel: profileModule.showcasePreferencesCollectiblesModel
    readonly property var showcasePreferencesAssetsModel: profileModule.showcasePreferencesAssetsModel
    readonly property var showcasePreferencesSocialLinksModel: profileModule.showcasePreferencesSocialLinksModel

    // TODO: remove old models
    readonly property var profileShowcaseCommunitiesModel: profileModule.profileShowcaseCommunitiesModel
    readonly property var profileShowcaseAccountsModel: profileModule.profileShowcaseAccountsModel
    readonly property var profileShowcaseCollectiblesModel: profileModule.profileShowcaseCollectiblesModel
    readonly property var profileShowcaseAssetsModel: profileModule.profileShowcaseAssetsModel

    readonly property bool isFirstShowcaseInteraction: localAccountSettings.isFirstShowcaseInteraction

    onUserDeclinedBackupBannerChanged: {
        if (userDeclinedBackupBanner !== localAccountSensitiveSettings.userDeclinedBackupBanner) {
            localAccountSensitiveSettings.userDeclinedBackupBanner = userDeclinedBackupBanner
        }
    }

    property var details: Utils.getContactDetailsAsJson(pubkey)

    function getQrCodeSource(text) {
        return globalUtils.qrCode(text)
    }

    function copyToClipboard(value) {
        globalUtils.copyToClipboard(value)
    }

    // Identity related:
    function saveIdentityInfo(displayName, bio, source, aX, aY, bX, bY) {
        // TODO: Update according to issue #13767
        _setDisplayName(displayName)
        _setBio(bio)
        if(source)
            _uploadImage(source, aX, aY, bX, bY)
        else
            _removeImage()
    }

    function _setDisplayName(displayName) {
        root.profileModule.setDisplayName(displayName)
    }

    function _setBio(bio) {
        root.profileModule.setBio(bio)
    }

    function _uploadImage(source, aX, aY, bX, bY) {
        return root.profileModule.upload(source, aX, aY, bX, bY)
    }

    function _removeImage() {
        return root.profileModule.remove()
    }

    // Preferences (Accounts, Communities, Collectibles, Assets and social links):
    // TO BE REMOVED: Deprecated --> Issue #13688
    function storeProfileShowcasePreferences() {
        root.profileModule.storeProfileShowcasePreferences()
    }

    function getProfileShowcaseEntriesLimit() {
        return root.profileModule.getProfileShowcaseEntriesLimit()
    }

    function getProfileShowcaseSocialLinksLimit() {
        return root.profileModule.getProfileShowcaseSocialLinksLimit()
    }

    function saveProfileShowcasePreferences(json) {
        root.profileModule.saveProfileShowcasePreferences(json)
    }

    function requestProfileShowcasePreferences() {
        root.profileModule.requestProfileShowcasePreferences()
    }

    function requestProfileShowcase(publicKey) {
        root.profileModule.requestProfileShowcase(publicKey)
    }

    function setIsFirstShowcaseInteraction() {
        root.profileModule.setIsFirstShowcaseInteraction()
    }

    // Social links related: All to be removed: Deprecated --> Issue #13688
    function containsSocialLink(text, url) {
        return root.profileModule.containsSocialLink(text, url)
    }

    function createLink(text, url, linkType, icon) {
        root.profileModule.createLink(text, url, linkType, icon)
    }

    function removeLink(uuid) {
        root.profileModule.removeLink(uuid)
    }

    function updateLink(uuid, text, url) {
        root.profileModule.updateLink(uuid, text, url)
    }

    function moveLink(fromRow, toRow, count) {
        root.profileModule.moveLink(fromRow, toRow)
    }

    function resetSocialLinks() {
        root.profileModule.resetSocialLinks()
    }

    function saveSocialLinks(silent = false) {
        root.profileModule.saveSocialLinks(silent)
    }
    // End of social links to be removed
}
