import QtQuick 2.14

QtObject {
    id: root

    enum ContentType {
        Message,
        NewMessagesMarker
    }

    readonly property ListModel messagesModel: ListModel {}
    property int newMessagesCount: 0
    property bool allMessagesSeen: false
}
