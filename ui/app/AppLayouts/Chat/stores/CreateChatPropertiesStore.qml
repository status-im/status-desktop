import QtQuick 2.15

QtObject {
    id: root

    property string createChatInitMessage: ""
    property var createChatFileUrls: []
    property bool createChatStartSendTransactionProcess: false
    property bool createChatStartReceiveTransactionProcess: false
    property string createChatStickerHashId: ""
    property string createChatStickerPackId: ""
    property string createChatStickerUrl: ""

    function resetProperties() {
        root.createChatInitMessage = "";
        root.createChatFileUrls = [];
        root.createChatStartSendTransactionProcess = false;
        root.createChatStartReceiveTransactionProcess = false;
        root.createChatStickerHashId = "";
        root.createChatStickerPackId = "";
    }
}
