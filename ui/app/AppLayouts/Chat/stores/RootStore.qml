import QtQuick 2.13

QtObject {
    id: root
    property var messageStore
    property EmojiReactions emojiReactionsModel: EmojiReactions { }

    property var chatsModelInst: chatsModel
    property var walletModelInst: walletModel
    property var profileModelInst: profileModel
}
