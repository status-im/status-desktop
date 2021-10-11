import QtQuick 2.13

import utils 1.0

QtObject {
    id: root
    property var messageStore
    property EmojiReactions emojiReactionsModel: EmojiReactions { }

    property var chatsModelInst: chatsModel
    property var walletModelInst: walletModel
    property var profileModelInst: profileModel

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
}
