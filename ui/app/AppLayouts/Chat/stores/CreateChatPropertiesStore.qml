import QtQuick 2.15

QtObject {
    id: root

    property string createChatInitMessage: ""
    property var createChatFileUrls: []
    property string createChatStickerHashId: ""
    property string createChatStickerPackId: ""
    property string createChatStickerUrl: ""

    function resetProperties() {
        root.createChatInitMessage = ""
        root.createChatFileUrls = []
        root.createChatStickerHashId = ""
        root.createChatStickerPackId = ""
    }
}
