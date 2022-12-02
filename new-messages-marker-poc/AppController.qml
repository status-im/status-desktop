import QtQuick 2.14

QtObject {
    id: root

    property ChatController leftChatController
    property ChatController rightChatController

    readonly property Item _d: Item {
        Connections {
            target: leftChatController
            function onMessageSent(text) {
                rightChatController.receiveMessage(text)
            }
        }

        Connections {
            target: rightChatController
            function onMessageSent(text) {
                leftChatController.receiveMessage(text)
            }
        }
    }

    function sendTestMessages() {
        leftChatController.sendMessage("Hi")
        leftChatController.sendMessage("how are you?")
        rightChatController.sendMessage("I am fine, thank you")
        rightChatController.sendMessage("And how are you?")
        leftChatController.sendMessage("also fine :)")
        leftChatController.sendMessage("working on new messages marker for Status App")
    }
}
