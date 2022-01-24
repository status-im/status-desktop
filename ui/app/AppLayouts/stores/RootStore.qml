import QtQuick 2.13

import "../Profile/stores" as ProfileStores


QtObject {
    id: root

    readonly property ProfileStores.RootStore profileStore: ProfileStores.RootStore {}

    property var mainModuleInst: mainModule
    property var profileModuleInst: profileModule

    property var chatsModelInst: chatsModel
    property var walletModelInst: walletModel
    property var userProfileInst: userProfile

    property var accounts: walletSectionAccounts.model
    property var currentAccount: walletSectionCurrent
    property var profileModelInst: profileModel

    property var assets: walletSectionAccountTokens.model
    property MessageStore messageStore: MessageStore { }

    property var contactsModuleInst: contactsModule
    property var addedContacts: contactsModuleInst.model.addedContacts


    function setCommunityMuted(communityId, checked) {
        chatsModelInst.communities.setCommunityMuted(communityId, checked);
    }

    function exportCommunity() {
        chatsModelInst.communities.exportCommunity();
    }

    function leaveCommunity(communityId) {
        chatsModelInst.communities.leaveCommunity(communityId);
    }

    function createCommunity(communityName, communityDescription, checkedMembership, ensOnlySwitchChecked, communityColor, communityImage, imageCropperModalaX, imageCropperModalaY, imageCropperModalbX, imageCropperModalbY) {
        chatsModelInst.communities.createCommunity(communityName, communityDescription, checkedMembership, ensOnlySwitchChecked, communityColor, communityImage, imageCropperModalaX, imageCropperModalaY, imageCropperModalbX, imageCropperModalbY);
    }

    function editCommunity(communityId, communityName, communityDescription, checkedMembership, ensOnlySwitchChecked, communityColor, communityImage, imageCropperModalaX, imageCropperModalaY, imageCropperModalbX, imageCropperModalbY) {
        chatsModelInst.communities.editCommunity(communityId, communityName, communityDescription, checkedMembership, ensOnlySwitchChecked, communityColor, communityImage, imageCropperModalaX, imageCropperModalaY, imageCropperModalbX, imageCropperModalbY);
    }

    function copyToClipboard(text) {
        chatsModelInst.copyToClipboard(text);
    }
}
