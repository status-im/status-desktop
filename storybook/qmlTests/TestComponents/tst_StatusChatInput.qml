import QtQuick 2.14
import QtQml 2.14
import QtTest 1.0

import utils 1.0
import shared.status 1.0
import shared.stores 1.0

Item {
    id: root
    width: 600
    height: 400

    QtObject {
        id: globalUtilsMock

        property var plainText
        property var isCompressedPubKey: function (publicKey) {
            return false
        }
    }

    QtObject {
        id: rootStoreMock

        property ListModel gifColumnA: ListModel {}

        readonly property var formationChars: (["*", "`", "~"])

        function getSelectedTextWithFormationChars(messageInputField) {
            let i = 1
            let text = ""
            while (true) {
                if (messageInputField.selectionStart - i < 0 && messageInputField.selectionEnd + i > messageInputField.length) {
                    break
                }

                text = messageInputField.getText(messageInputField.selectionStart - i, messageInputField.selectionEnd + i)

                if (!formationChars.includes(text.charAt(0)) ||
                        !formationChars.includes(text.charAt(text.length - 1))) {
                    break
                }
                i++
            }
            return text
        }

        Component.onCompleted: {
            RootStore.isGifWidgetEnabled = true
            RootStore.isWalletEnabled = true
            RootStore.isTenorWarningAccepted = true
            RootStore.getSelectedTextWithFormationChars = rootStoreMock.getSelectedTextWithFormationChars
            RootStore.gifColumnA = rootStoreMock.gifColumnA
        }
    }

    StatusChatInput {
        id: controlUnderTest
        width: parent.width
        property var globalUtils: globalUtilsMock
        Component.onCompleted: {
            Global.dragArea = root
        }
    }

    TestCase {
        name: "TestChatInputInitialization"
        when: windowShown

        function test_empty_chat_input() {
            globalUtilsMock.plainText = (htmlText) => {
                return ""
            }
            verify(controlUnderTest.textInput.length == 0, `Expected 0 text length, received: ${controlUnderTest.textInput.length}`)
            verify(controlUnderTest.getPlainText() == "", `Expected empty string, received: ${controlUnderTest.getPlainText()}`)
        }
    }
}
