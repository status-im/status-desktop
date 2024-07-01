import QtQuick 2.15
import QtQml 2.15

import utils 1.0

QtObject {
    id: root

    property var profileModule

    property string pubkey: userProfile.pubKey
    property string name: userProfile.name
    property string username: userProfile.username
    property string displayName: userProfile.displayName
    property string preferredName: userProfile.preferredName
    property string profileLargeImage: userProfile.largeImage
    property string icon: userProfile.icon
    property bool userDeclinedBackupBanner: Global.appIsReady? localAccountSensitiveSettings.userDeclinedBackupBanner : false
    property var privacyStore: profileSectionModule.privacyModule
    readonly property string keyUid: userProfile.keyUid
    readonly property bool isKeycardUser: userProfile.isKeycardUser
    readonly property int currentUserStatus: userProfile.currentUserStatus
    readonly property var thumbnailImage: userProfile.thumbnailImage
    readonly property var largeImage: userProfile.largeImage
    readonly property int colorId: Utils.colorIdForPubkey(root.pubkey)
    readonly property var colorHash: Utils.getColorHashAsJson(root.pubkey, name != "")
    readonly property string defaultDisplayName: ProfileUtils.displayName("", name, displayName, username)

    readonly property string bio: profileModule.bio
    readonly property string socialLinksJson: profileModule.socialLinksJson
    readonly property var socialLinksModel: profileModule.socialLinksModel
    readonly property var temporarySocialLinksModel: profileModule.temporarySocialLinksModel // for editing purposes
    readonly property var temporarySocialLinksJson: profileModule.temporarySocialLinksJson
    readonly property bool socialLinksDirty: profileModule.socialLinksDirty

    readonly property bool isWalletEnabled: Global.appIsReady? mainModule.sectionsModel.getItemEnabledBySectionType(Constants.appSection.wallet) : true

    readonly property var showcasePreferencesCommunitiesModel: profileModule.showcasePreferencesCommunitiesModel
    readonly property var showcasePreferencesAccountsModel: profileModule.showcasePreferencesAccountsModel
    readonly property var showcasePreferencesCollectiblesModel: profileModule.showcasePreferencesCollectiblesModel
    readonly property var showcasePreferencesAssetsModel: profileModule.showcasePreferencesAssetsModel
    readonly property var showcasePreferencesSocialLinksModel: profileModule.showcasePreferencesSocialLinksModel

    readonly property bool isFirstShowcaseInteraction: localAccountSettings.isFirstShowcaseInteraction

    property var details: Utils.getContactDetailsAsJson(pubkey)

    // The following signals wrap the settings / preferences save request responses in one unique result (identity + preferences result)
    signal profileSettingsSaveSucceeded()
    signal profileSettingsSaveFailed()

    // The following signals describe separate save request responses between identity and preferences
    signal profileIdentitySaveSucceeded()
    signal profileIdentitySaveFailed()
    signal profileShowcasePreferencesSaveSucceeded()
    signal profileShowcasePreferencesSaveFailed()

    readonly property Connections profileModuleConnections: Connections {
        target: root.profileModule

        function onProfileIdentitySaveSucceeded() {
            root.profileIdentitySaveSucceeded()
        }

        function onProfileIdentitySaveFailed() {
            root.profileIdentitySaveFailed()
        }

        function onProfileShowcasePreferencesSaveSucceeded() {
            root.profileShowcasePreferencesSaveSucceeded()
        }

        function onProfileShowcasePreferencesSaveFailed() {
            root.profileShowcasePreferencesSaveFailed()
        }
    }

    function getQrCodeSource(text) {
        return globalUtils.qrCode(text)
    }

    function copyToClipboard(value) {
        Utils.copyToClipboard(value)
    }

    function saveProfileIdentityChanges(displayName, bio, imageInfo) {
        const changes = Object.assign({},
                                      displayName !== undefined && { displayName },
                                      bio !== undefined && { bio },
                                      imageInfo !== undefined && { image: imageInfo })

        const json = JSON.stringify(changes)
        root.profileModule.saveProfileIdentityChanges(json)
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

    onUserDeclinedBackupBannerChanged: {
        if (userDeclinedBackupBanner !== localAccountSensitiveSettings.userDeclinedBackupBanner) {
            localAccountSensitiveSettings.userDeclinedBackupBanner = userDeclinedBackupBanner
        }
    }
}
