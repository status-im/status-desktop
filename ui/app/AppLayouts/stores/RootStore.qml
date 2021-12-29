import QtQuick 2.13

QtObject {
    id: root
    property var mainModuleInst: mainModule
    property var aboutModuleInst: aboutModule

    // Not Refactored Yet
//    property var chatsModelInst: chatsModel
    // Not Refactored Yet
//    property var walletModelInst: walletModel
    property var userProfileInst: userProfile

    property var accounts: walletSectionAccounts.model
    property var currentAccount: walletSectionCurrent
    // Not Refactored Yet
//    property var profileModelInst: profileModel

    property var assets: walletSectionAccountTokens.model
//    property MessageStore messageStore: MessageStore { }

    property var contactsModuleInst: contactsModule
    property var addedContacts: contactsModuleInst.model.addedContacts

    property real volume: !!localAccountSensitiveSettings ? localAccountSensitiveSettings.volume : 0.0
    property bool notificationSoundsEnabled: !!localAccountSensitiveSettings ? localAccountSensitiveSettings.notificationSoundsEnabled : false

    function setCommunityMuted(communityId, checked) {
        // Not Refactored Yet
//        chatsModelInst.communities.setCommunityMuted(communityId, checked);
    }

    function exportCommunity() {
        // Not Refactored Yet
//        chatsModelInst.communities.exportCommunity();
    }

    function leaveCommunity(communityId) {
        // Not Refactored Yet
//        chatsModelInst.communities.leaveCommunity(communityId);
    }

    function createCommunity(communityName, communityDescription, checkedMembership, ensOnlySwitchChecked, communityColor, communityImage, imageCropperModalaX, imageCropperModalaY, imageCropperModalbX, imageCropperModalbY) {
        // Not Refactored Yet
//        chatsModelInst.communities.createCommunity(communityName, communityDescription, checkedMembership, ensOnlySwitchChecked, communityColor, communityImage, imageCropperModalaX, imageCropperModalaY, imageCropperModalbX, imageCropperModalbY);
    }

    function editCommunity(communityId, communityName, communityDescription, checkedMembership, ensOnlySwitchChecked, communityColor, communityImage, imageCropperModalaX, imageCropperModalaY, imageCropperModalbX, imageCropperModalbY) {
        // Not Refactored Yet
//        chatsModelInst.communities.editCommunity(communityId, communityName, communityDescription, checkedMembership, ensOnlySwitchChecked, communityColor, communityImage, imageCropperModalaX, imageCropperModalaY, imageCropperModalbX, imageCropperModalbY);
    }

    function copyToClipboard(text) {
        // Not Refactored Yet
//        chatsModelInst.copyToClipboard(text);
    }
}
