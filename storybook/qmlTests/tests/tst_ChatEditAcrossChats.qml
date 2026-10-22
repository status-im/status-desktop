import QtQuick
import QtTest

import "helpers"

/*
 A message edit in progress belongs to its chat: leaving the chat keeps it,
 with what was typed so far, apart from the chat's draft, and coming back
 resumes it. The chat input is shared by the section's chats, so it shows
 each chat's own state as it becomes active.
*/
Item {
    width: 1000
    height: 700

    CommunityChatSectionHarness {
        id: harness
        anchors.fill: parent
    }

    TestCase {
        name: "ChatEditAcrossChats"
        when: windowShown

        property string chatA
        property string chatB
        property var column: null
        property var input: null
        property var messagesView: null

        function init() {
            harness.mock.joined = true
            harness.mock.membersCount = 10
            harness.mock.categoriesCount = 1
            harness.mock.channelsPerCategory = 2
            harness.mock.messagesPerChannel = 10
            harness.mock.install()

            chatA = harness.mock.activeChatId
            chatB = otherChat(chatA)

            // a draft to recognise chat a's state by once the input shows it
            preservedOf(chatA).text = "loaded"

            harness.loader.active = true
            const loader = harness.loader.item
            verify(!!loader)
            tryVerify(() => loader.status === Loader.Ready, 120000)

            const view = harness.findChildByTypePrefix(loader, "ChatView")
            verify(!!view)
            column = harness.findChildByTypePrefix(view.centerPanel, "ChatColumnView")
            verify(!!column)
            input = harness.findChildByTypePrefix(column, "StatusChatInput")
            verify(!!input)
            messagesView = harness.findChildByTypePrefix(column, "ChatMessagesView")
            verify(!!messagesView)

            // The input takes chat a's state a turn after the column gets the
            // chat, which may come after the section is ready. Until then
            // what is typed belongs to no chat.
            tryVerify(() => inputText() === "loaded", 5000, "the input shows chat a")
        }

        function cleanup() {
            harness.loader.active = false
            harness.mock.uninstall()
            column = input = messagesView = null
        }

        function otherChat(chatId) {
            const chats = harness.mock.chatsModel
            for (let i = 0; i < chats.count; ++i) {
                const row = chats.get(i)
                if (!row.isCategory && row.itemId !== chatId)
                    return row.itemId
            }
            return ""
        }

        function moduleOf(chatId) {
            return harness.mock.d.contentModuleFor(chatId)
        }

        function preservedOf(chatId) {
            return moduleOf(chatId).inputAreaModule.preservedProperties
        }

        function messageId(chatId, i) {
            return "msg-" + chatId + "-" + i
        }

        function inputText() {
            return input.getTextWithPublicKeys()
        }

        function switchTo(chatId) {
            harness.mock.setActiveChat(chatId)
        }

        // A draft in chat a, then an edit of one of its messages, typed into.
        function editInChatA() {
            input.setText("draft a")
            tryCompare(preservedOf(chatA), "text", "draft a")

            const id = messageId(chatA, 3)
            messagesView.editModeChanged(true, id)
            verify(input.isEdit, "editing")
            compare(preservedOf(chatA).editMessageId, id)
            compare(preservedOf(chatA).text, "draft a", "the draft is kept as it was")

            input.setText("edited so far")
            compare(preservedOf(chatA).editText, "edited so far")
            return id
        }

        // Switching, the input still holds the chat left while it adapts to
        // the next one: none of that may land in the next chat's draft.
        function test_eachChatKeepsItsOwnDraft() {
            input.setText("draft a")
            tryCompare(preservedOf(chatA), "text", "draft a")

            switchTo(chatB)
            tryVerify(() => inputText() === "", 5000, "chat b's input is empty")
            input.setText("draft b")

            switchTo(chatA)
            tryVerify(() => inputText() === "draft a", 5000, "chat a shows its draft")
            compare(preservedOf(chatA).text, "draft a")
            compare(preservedOf(chatB).text, "draft b")
        }

        function test_anEditIsKeptAcrossAChatSwitch() {
            const id = editInChatA()

            switchTo(chatB)
            tryVerify(() => !input.isEdit && inputText() === "", 5000,
                      "chat b shows its own, empty, input")
            input.setText("draft b")

            switchTo(chatA)
            tryVerify(() => input.isEdit && inputText() === "edited so far", 5000,
                      "back in chat a, the edit resumes as it was left")
            compare(moduleOf(chatA).messagesModule.editModeOffCalls, [],
                    "the edit was never ended")

            // and ends as any edit does, back to the draft
            input.editCancelRequested()
            verify(!input.isEdit)
            compare(inputText(), "draft a")
            compare(moduleOf(chatA).messagesModule.editModeOffCalls, [id])
            compare(preservedOf(chatA).editMessageId, "")
            compare(preservedOf(chatA).editText, "")
            compare(preservedOf(chatB).text, "draft b", "chat b's draft is its own")
        }

        // Away and straight back, before the next chat's state was shown: the
        // input never stopped showing the edit, which must stay an edit.
        function test_switchingBackAtOnceKeepsTheEdit() {
            editInChatA()

            switchTo(chatB)
            switchTo(chatA)

            tryVerify(() => input.isEdit && inputText() === "edited so far", 5000,
                      "still editing")
            compare(preservedOf(chatA).text, "draft a", "the draft is untouched")
            compare(preservedOf(chatA).editText, "edited so far")
        }

        function test_aResumedEditIsSentAndTheDraftComesBack() {
            const id = editInChatA()

            switchTo(chatB)
            tryVerify(() => !input.isEdit, 5000)
            switchTo(chatA)
            tryVerify(() => input.isEdit && inputText() === "edited so far", 5000)

            input.setText("edited at last")
            input.sendMessageRequested(false, "", false)

            compare(moduleOf(chatA).messagesModule.editedMessages,
                    [{ messageId: id, text: "edited at last" }])
            verify(!input.isEdit)
            compare(inputText(), "draft a")
            compare(preservedOf(chatA).editMessageId, "")
        }

        // Gone while the chat was not shown - deleted, say: there is nothing
        // left to edit, and the chat's draft is shown instead.
        function test_anEditWhoseMessageIsGoneIsDropped() {
            const id = editInChatA()

            switchTo(chatB)
            tryVerify(() => !input.isEdit, 5000)

            const messages = moduleOf(chatA).messagesModel
            for (let i = 0; i < messages.count; ++i) {
                if (messages.get(i).id === id) {
                    messages.remove(i)
                    break
                }
            }

            switchTo(chatA)
            tryVerify(() => inputText() === "draft a", 5000, "chat a shows its draft")
            verify(!input.isEdit)
            compare(preservedOf(chatA).editMessageId, "")
        }
    }
}
