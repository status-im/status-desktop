import QtQuick 2.13

import "../Profile/stores"

QtObject {
    id: root
    property var mainModuleInst: mainModule
    property var aboutModuleInst: aboutModule
    property var communitiesModuleInst: communitiesModule
    property var observedCommunity: communitiesModuleInst.observedCommunity

    property ProfileSectionStore profileSectionStore: ProfileSectionStore {
    }

    property EmojiReactions emojiReactionsModel: EmojiReactions {
    }

    // Not Refactored Yet
//    property var chatsModelInst: chatsModel
    // Not Refactored Yet
//    property var walletModelInst: walletModel
    property var userProfileInst: userProfile

    property var accounts: walletSectionAccounts.model
    property var currentAccount: walletSectionCurrent
    // Not Refactored Yet
//    property var profileModelInst: profileModel

    property var contactStore: profileSectionStore.contactsStore
    property bool hasAddedContacts: contactStore.myContactsModel.count > 0

    property var assets: walletSectionAccountTokens.model
//    property MessageStore messageStore: MessageStore { }

    property real volume: !!localAccountSensitiveSettings ? localAccountSensitiveSettings.volume : 0.0
    property bool notificationSoundsEnabled: !!localAccountSensitiveSettings ? localAccountSensitiveSettings.notificationSoundsEnabled : false

    function setObservedCommunity(communityId) {
        communitiesModuleInst.setObservedCommunity(communityId);
    }

    function createCommunity(communityName, communityDescription, checkedMembership, ensOnlySwitchChecked, communityColor, communityImage, imageCropperModalaX, imageCropperModalaY, imageCropperModalbX, imageCropperModalbY) {
        communitiesModuleInst.createCommunity(communityName, communityDescription, checkedMembership, ensOnlySwitchChecked, communityColor, communityImage, imageCropperModalaX, imageCropperModalaY, imageCropperModalbX, imageCropperModalbY);
    }

    function copyToClipboard(text) {
        globalUtils.copyToClipboard(text)
    }

    function generateAlias(pk) {
        return globalUtils.generateAlias(pk);
    }

    function generateIdenticon(pk) {
        return globalUtils.generateIdenticon(pk);
    }
}
