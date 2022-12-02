import QtQuick 2.14

QtObject {
    id: root

    property Model model

    property bool shouldAddNewMessagesMarker

    signal messageSent(string text)

    function sendMessage(text: string) {
        d.addMessage(text)
        messageSent(text)
    }

    function markAllMessagesAsSeen() {
        model.allMessagesSeen = true
    }

    function resetNewMessagesCount() {
        if (model.allMessagesSeen) {
            d.removeNewMessagesMarker()
            model.newMessagesCount = 0
        }
    }

    function markAsUnread(index: int) {
        d.removeNewMessagesMarker()
        d.insertNewMessagesMarkerAt(index + 1)
    }

    function receiveMessage(text: string) {
        d.messagesModel.insert(0, {contentType: Model.ContentType.Message, outgoing: false, text: text})

        if (shouldAddNewMessagesMarker && !d.hasNewMessagesMarker()) {
            d.insertNewMessagesMarkerAt(1)
            model.newMessagesCount = 1
            model.allMessagesSeen = false
        } else {
            model.newMessagesCount = Math.max(0, d.getNewMessagesMarkerIndex())
        }
    }

    readonly property QtObject _d: QtObject {
        id: d

        readonly property ListModel messagesModel: root.model.messagesModel

        function addMessage(text: string) {
            messagesModel.insert(0, {contentType: Model.ContentType.Message, outgoing: true, text: text})
            markAllMessagesAsSeen()
            d.removeNewMessagesMarker()
        }

        function insertNewMessagesMarkerAt(index: int): int {
            messagesModel.insert(index, {contentType: Model.ContentType.NewMessagesMarker, outgoing: false, text: ""})
            return index
        }

        function removeNewMessagesMarker() {
            const index = getNewMessagesMarkerIndex()
            if (index !== -1) {
                messagesModel.remove(index, 1)
            }
        }

        function getNewMessagesMarkerIndex(): int {
            for(let i = 0; i < messagesModel.count; ++i) {
                if (messagesModel.get(i).contentType === Model.ContentType.NewMessagesMarker) {
                    return i
                }
            }
            return -1
        }

        function hasNewMessagesMarker(): bool {
            return getNewMessagesMarkerIndex() !== -1
        }
    }
}
