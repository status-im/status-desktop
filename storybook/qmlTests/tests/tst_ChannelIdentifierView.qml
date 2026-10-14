import QtQuick
import QtTest

import utils
import shared.views.chat

Item {
    id: root
    width: 400
    height: 300

    Component {
        id: viewComponent

        ChannelIdentifierView {
            width: 360
        }
    }

    TestCase {
        name: "ChannelIdentifierView"
        when: windowShown

        function descriptionText(chatType, chatName) {
            const view = createTemporaryObject(viewComponent, root, {
                chatType: chatType,
                chatName: chatName
            })
            verify(!!view)
            const desc = findChild(view, "channelIdentifierDescriptionText")
            verify(!!desc)
            return desc.text
        }

        function test_privateGroupWelcomeMessage() {
            const chatName = "Alpha&Beta"
            const text = descriptionText(Constants.chatType.privateGroupChat, chatName)
            verify(text.startsWith("Welcome to the beginning of the "))
            verify(text.endsWith(" group!"))
            verify(text.indexOf(chatName) >= 0)
        }

        function test_oneToOneHasNoGroupWelcomeSuffix() {
            const text = descriptionText(Constants.chatType.oneToOne, "Alpha&Beta")
            verify(!text.endsWith(" group!"))
        }
    }
}
