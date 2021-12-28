import QtQuick 2.13
import utils 1.0

QtObject {
    id: root

    property var notificationsModule

    property var mutedContactsModel: notificationsModule.mutedContactsModel
    property var mutedChatsModel: notificationsModule.mutedChatsModel

    function unmuteChat(chatId) {
        return root.notificationsModule.unmuteChat(chatId)
    }
}
