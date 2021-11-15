import QtQuick 2.13

import utils 1.0

QtObject {
    id: root
    objectName: "hello!"
    property var messageStore
    property EmojiReactions emojiReactionsModel: EmojiReactions { }

    property var chatsModelInst: chatsModel
    property var utilsModelInst: utilsModel
    property var walletModelInst: walletModel
    property var profileModelInst: profileModel
    property var profileModuleInst: profileModule
    property var contactsModuleInst: contactsModule

    property var activeCommunity: chatsModelInst.communities.activeCommunity

    property var contactRequests: contactsModuleInst.model.contactRequests
    property var addedContacts: contactsModuleInst.model.addedContacts
    property var allContacts: contactsModuleInst.model.list

    function copyToClipboard(text) {
        chatsModelInst.copyToClipboard(text);
    }

    function deleteMessage(messageId) {
        chatsModelInst.messageView.deleteMessage(messageId);
    }

    function lastTwoItems(nodes) {
        //% " and "
        return nodes.join(qsTrId("-and-"));
    }

    function showReactionAuthors(fromAccounts, emojiId) {
        let tooltip
        if (fromAccounts.length === 1) {
            tooltip = fromAccounts[0]
        } else if (fromAccounts.length === 2) {
            tooltip = lastTwoItems(fromAccounts);
        } else {
            var leftNode = [];
            var rightNode = [];
            const maxReactions = 12
            let maximum = Math.min(maxReactions, fromAccounts.length)

            if (fromAccounts.length > maxReactions) {
                leftNode = fromAccounts.slice(0, maxReactions);
                rightNode = fromAccounts.slice(maxReactions, fromAccounts.length);
                return (rightNode.length === 1) ?
                            lastTwoItems([leftNode.join(", "), rightNode[0]]) :
                            //% "%1 more"
                            lastTwoItems([leftNode.join(", "), qsTrId("-1-more").arg(rightNode.length)]);
            }

            leftNode = fromAccounts.slice(0, maximum - 1);
            rightNode = fromAccounts.slice(maximum - 1, fromAccounts.length);
            tooltip = lastTwoItems([leftNode.join(", "), rightNode[0]])
        }

        //% " reacted with "
        tooltip += qsTrId("-reacted-with-");
        let emojiHtml = Emoji.getEmojiFromId(emojiId);
        if (emojiHtml) {
            tooltip += emojiHtml;
        }
        return tooltip
    }

    function getCommunity(communityId) {
        try {
            const communityJson = chatsModelInst.communities.list.getCommunityByIdJson(communityId);
            if (!communityJson) {
                return null;
            }

            let community = JSON.parse(communityJson);
            if (community) {
                community.nbMembers = community.members.length;
            }
            return community
        } catch (e) {
            console.error("Error parsing community", e);
        }

       return null;
    }

    property var activeCommunityChatsModel: chatsModelInst.communities.activeCommunity.chats

    function createCommunity(communityName, communityDescription, checkedMembership, ensOnlySwitchChecked, communityColor, communityImage, imageCropperModalaX, imageCropperModalaY, imageCropperModalbX, imageCropperModalbY) {
        chatsModelInst.communities.createCommunity(communityName, communityDescription, checkedMembership, ensOnlySwitchChecked, communityColor, communityImage, imageCropperModalaX, imageCropperModalaY, imageCropperModalbX, imageCropperModalbY);
    }

    function editCommunity(communityId, communityName, communityDescription, checkedMembership, ensOnlySwitchChecked, communityColor, communityImage, imageCropperModalaX, imageCropperModalaY, imageCropperModalbX, imageCropperModalbY) {
        chatsModelInst.communities.editCommunity(communityId, communityName, communityDescription, checkedMembership, ensOnlySwitchChecked, communityColor, communityImage, imageCropperModalaX, imageCropperModalaY, imageCropperModalbX, imageCropperModalbY);
    }

    function createCommunityCategory(communityId, categoryName, channels) {
        chatsModelInst.communities.createCommunityCategory(communityId, categoryName, channels);
    }

    function editCommunityCategory(communityId, categoryId, categoryName, channels) {
        chatsModelInst.communities.editCommunityCategory(communityId, categoryId, categoryName, channels);
    }

    function deleteCommunityCategory(categoryId) {
        chatsModelInst.communities.deleteCommunityCategory(chatsModelInst.communities.activeCommunity.id, categoryId);
    }

    function leaveCommunity(communityId) {
        chatsModelInst.communities.leaveCommunity(communityId);
    }

    function setCommunityMuted(communityId, checked) {
        chatsModelInst.communities.setCommunityMuted(communityId, checked);
    }

    function exportCommunity() {
        chatsModelInst.communities.exportCommunity();
    }

    function createCommunityChannel(communityId, channelName, channelDescription, categoryId) {
        // TODO: pass the private value when private channels
        // are implemented
        //privateSwitch.checked)
        chatsModelInst.createCommunityChannel(communityId, channelName, channelDescription, categoryId);
    }

    function editCommunityChannel(communityId, channelId, channelName, channelDescription, channelCategoryId, popupPosition) {
        // TODO: pass the private value when private channels
        // are implemented
        //privateSwitch.checked)
        chatsModelInst.editCommunityChannel(communityId, channelId, channelName, channelDescription, channelCategoryId, popupPosition);
    }

    function acceptRequestToJoinCommunity(id) {
        chatsModelInst.communities.acceptRequestToJoinCommunity(id);
    }

    function declineRequestToJoinCommunity(id) {
        chatsModelInst.communities.declineRequestToJoinCommunity(id);
    }
}
