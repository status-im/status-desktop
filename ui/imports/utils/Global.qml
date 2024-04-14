pragma Singleton

import QtQml 2.14

QtObject {
    id: root

    property var dragArea
    property var applicationWindow
    property bool activityPopupOpened: false
    property int settingsSubsection: Constants.settingsSubsection.profile
    property int settingsSubSubsection: -1

    property var userProfile
    property bool appIsReady: false

    signal openPinnedMessagesPopupRequested(var store, var messageStore, var pinnedMessagesModel, string messageToPin, string chatId)
    signal openCommunityProfilePopupRequested(var store, var community, var chatCommunitySectionModule)

    signal openLinkInBrowser(string link)
    signal openChooseBrowserPopup(string link)
    signal openCreateChatView()
    signal closeCreateChatView()

    signal blockContactRequested(string publicKey, var contactDetails)
    signal unblockContactRequested(string publicKey, var contactDetails)

    signal displayToastMessage(string title, string subTitle, string icon, bool loading, int ephNotifType, string url)
    signal displayToastWithActionMessage(string title, string subTitle, string icon, string iconColor, bool loading, int ephNotifType, int actionType, string data)
    signal displayImageToastWithActionMessage(string title, string subTitle, string image, int ephNotifType, int actionType, string data)

    signal openPopupRequested(var popupComponent, var params)
    signal closePopupRequested()
    signal openNicknamePopupRequested(string publicKey, var contactDetails, var cb)
    signal openDownloadModalRequested(bool available, string version, string url)
    signal openChangeProfilePicPopup(var cb)
    signal openBackUpSeedPopup()
    signal openImagePopup(var image, string url)
    signal openProfilePopupRequested(string publicKey, var parentPopup, var cb)
    signal openActivityCenterPopupRequested()
    signal openSendIDRequestPopup(string publicKey, var contactDetails, var cb)
    signal openMarkAsIDVerifiedPopup(string publicKey, var contactDetails, var cb)
    signal openRemoveIDVerificationDialog(string publicKey, var contactDetails, var cb)
    signal openContactRequestPopup(string publicKey, var contactDetails, var cb)
    signal openReviewContactRequestPopup(string publicKey, var contactDetails, var cb)
    signal markAsUntrustedRequested(string publicKey, var contactDetails)
    signal removeContactRequested(string publicKey, var contactDetails)
    signal openInviteFriendsToCommunityPopup(var community, var communitySectionModule, var cb)
    signal openInviteFriendsToCommunityByIdPopup(string communityId, var cb)
    signal openIncomingIDRequestPopup(string publicKey, var contactDetails, var cb)
    signal openOutgoingIDRequestPopup(string publicKey, var contactDetails, var cb)
    signal openDeleteMessagePopup(string messageId, var messageStore)
    signal openDownloadImageDialog(string imageSource)
    signal openExportControlNodePopup(var community)
    signal openImportControlNodePopup(var community)
    signal openTransferOwnershipPopup(string communityId,
                                      string communityName,
                                      string communityLogo,
                                      var token,
                                      var accounts,
                                      var sendModalPopup)
    signal openFinaliseOwnershipPopup(string communityId)
    signal openDeclineOwnershipPopup(string communityId, string communityName)
    signal openFirstTokenReceivedPopup(string communityId,
                                       string communityName,
                                       string communityLogo,
                                       string tokenSymbol,
                                       string tokenName,
                                       string tokenAmount,
                                       int tokenType,
                                       string tokenImage)
    signal openConfirmHideAssetPopup(string assetSymbol, string assetName, string assetImage, bool isCommunityToken)
    signal openConfirmHideCollectiblePopup(string collectibleSymbol, string collectibleName, string collectibleImage, bool isCommunityToken)

    signal openLink(string link)
    signal openLinkWithConfirmation(string link, string domain)
    signal activateDeepLink(string link)

    signal setNthEnabledSectionActive(int nthSection)
    signal appSectionBySectionTypeChanged(int sectionType, int subsection, int subSubsection, var data)

    signal openSendModal(string address)
    signal switchToCommunity(string communityId)
    signal switchToCommunitySettings(string communityId)
    signal switchToCommunityChannelsView(string communityId)
    signal createCommunityPopupRequested(bool isDiscordImport)
    signal importCommunityPopupRequested()
    signal communityIntroPopupRequested(string communityId, string name, string introMessage,
                                        string imageSrc, bool isInvitationPending)
    signal communityShareAddressesPopupRequested(string communityId, string name, string imageSrc)
    signal leaveCommunityRequested(string community, string communityId, string outroMessage)
    signal openEditSharedAddressesFlow(string communityId)

    signal playSendMessageSound()
    signal playNotificationSound()
    signal playErrorSound()

    signal openTestnetPopup()

    signal popupWalletConnect()

    signal openAddEditSavedAddressesPopup(var params)
    signal openDeleteSavedAddressesPopup(var params)
    signal openShowQRPopup(var params)
    signal openSavedAddressActivityPopup(var params)
    signal openCommunityMemberMessagesPopupRequested(var store, var chatCommunitySectionModule, var memberPubKey, var displayName)

    function openProfilePopup(publicKey, parentPopup, cb) {
        root.openProfilePopupRequested(publicKey, parentPopup, cb)
    }

    function openActivityCenterPopup() {
        root.openActivityCenterPopupRequested();
    }

    function openPopup(popupComponent, params = {}) {
        root.openPopupRequested(popupComponent, params);
    }

    function closePopup() {
        root.closePopupRequested();
    }

    function openDownloadModal(available, version, url){
        root.openDownloadModalRequested(available, version, url);
    }

    function changeAppSectionBySectionType(sectionType, subsection = 0, subSubsection = -1, data = {}) {
        root.appSectionBySectionTypeChanged(sectionType, subsection, subSubsection, data)
    }

    function openMenu(menuComponent, menuParent, params = {}, point = undefined) {
        const menu = menuComponent.createObject(menuParent, params)
        if (point)
            menu.popup(point)
        else
            menu.popup()
        return menu
    }

    function displaySuccessToastMessage(title: string, subTitle = "") {
        root.displayToastMessage(
            title,
            subTitle,
            "checkmark-circle",
            false,
            Constants.ephemeralNotificationType.success,
            ""
        )
    }
}
