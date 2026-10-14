import QtQuick
import QtQuick.Controls
import QtTest
import StatusQ.Popups

import "../../../ui/app/mainui" as MainUI

Item {
    id: root
    width: 900
    height: 700

    property var lastScope: []
    property var requestedScope: []
    property string locationTitle: "Status Community"
    property string locationSectionId: "section"
    property string locationIcon: "communities"
    property string chatTitle: "general"
    property string threadTitle: "Threads MVP"
    property bool noActiveChat: false

    ListModel { id: locations }
    ListModel { id: results }
    ListModel { id: threads }

    MainUI.AppSearch {
        id: search
        anchors.fill: parent
        threadsEnabled: true
        personalChatsSectionId: "personal"
        locationMenuModel: locations
        resultModel: results
        threadLocationMenuModel: threads
        searchInProgress: false
        resolveMentionsFn: text => ({})
        setSearchLocationFn: (section, chat, thread) => { root.lastScope = [section, chat, thread] }
        prepareLocationMenuModelFn: () => {}
        prepareThreadLocationMenuModelFn: chatId => {}
        getSearchLocationObjectFn: (chatId, threadId) => {
            root.requestedScope = [chatId, threadId]
            return JSON.stringify({
                location: { value: root.locationSectionId, title: root.locationTitle, iconName: root.locationIcon, imageSource: "", iconColor: "#4360DF" },
                subLocation: root.noActiveChat ? "" : { value: "parent", text: root.chatTitle, imageSource: "", iconName: "channel", iconColor: "#4360DF", isUserIcon: false, colorId: 0 },
                thread: threadId ? { value: threadId, text: root.threadTitle } : ""
            })
        }
        isChatKeyFn: () => false
        openProfilePopupFn: () => {}
    }

    ListModel {
        id: menuLocations
        ListElement {
            value: "community"
            title: "Status"
            imageSource: ""
            iconName: "communities"
            iconColor: "#4360DF"
            hasSubItems: true
            subItems: [ListElement {
                value: "channel"
                text: "general"
                imageSource: ""
                iconName: "channel"
                iconColor: "#4360DF"
                isUserIcon: false
                isImage: false
                colorId: 0
                position: 0
                lastMessageTimestamp: 0
                hasThreads: true
            }]
        }
    }
    StatusSearchLocationMenu {
        id: standaloneMenu
        locationModel: menuLocations
        personalChatsSectionId: "personal"
        threadsEnabled: true
        threadLocationModel: threads
        onThreadLocationsRequested: chatId => {
            threads.clear()
            threads.append({ value: "nested-thread", text: "Selected thread" })
        }
    }
    SignalSpy { id: menuSpy; target: standaloneMenu; signalName: "itemClicked" }
    SignalSpy { id: sectionSpy; target: standaloneMenu; signalName: "threadLocationSectionRequested" }
    SignalSpy { id: selectionSpy; target: standaloneMenu; signalName: "setSearchSelection" }

    Component {
        id: lazyMenuComponent
        StatusSearchLocationMenu {
            locationModel: menuLocations
            personalChatsSectionId: "personal"
            threadsEnabled: true
        }
    }
    Component {
        id: sectionSpyComponent
        SignalSpy { signalName: "threadLocationSectionRequested" }
    }

    SignalSpy { id: resultSpy; target: search; signalName: "resultItemClicked" }
    SignalSpy { id: searchSpy; target: search; signalName: "searchMessages" }

    TestCase {
        name: "AppSearch"
        when: windowShown

        function init() {
            root.locationTitle = "Status Community"
            root.locationSectionId = "section"
            root.locationIcon = "communities"
            root.chatTitle = "general"
            root.threadTitle = "Threads MVP"
            popup().width = 700
            root.noActiveChat = false
            root.lastScope = []
            root.requestedScope = []
            search.threadsEnabled = true
            resultSpy.clear()
            searchSpy.clear()
            menuSpy.clear()
            sectionSpy.clear()
            selectionSpy.clear()
            standaloneMenu.threadsEnabled = true
            menuLocations.setProperty(0, "title", "Status")
            menuLocations.setProperty(0, "value", "community")
            menuLocations.setProperty(0, "iconName", "communities")
            while (menuLocations.get(0).subItems.count > 1)
                menuLocations.get(0).subItems.remove(1)
            menuLocations.get(0).subItems.setProperty(0, "hasThreads", true)
        }

        function cleanup() {
            standaloneMenu.dismiss()
            search.closeSearchPopup()
            tryCompare(search, "opened", false)
        }

        function popup() { return findChild(search, "appSearchPopup") }

        function test_threadScopeAndReset_data() {
            return [{tag: "community", personal: false}, {tag: "chat", personal: true}]
        }

        function test_threadScopeAndReset(data) {
            if (data.personal) {
                root.locationTitle = "Chat"
                root.locationSectionId = "personal"
            }
            root.locationIcon = data.personal ? "communities" : "chat"
            search.openSearchPopup("parent", "thread")
            tryCompare(search, "opened", true)
            compare(root.requestedScope, ["parent", "thread"])
            compare(root.lastScope, [data.personal ? "personal" : "section", "parent", "thread"])
            compare(popup().searchSelectionButton.primaryText, data.personal ? "general" : "Status Community")
            compare(popup().searchSelectionButton.secondaryText, data.personal ? "" : "general")
            compare(popup().searchSelectionButton.threadText, "Threads MVP")
            compare(popup().emptySearchLabel, "Search messages in this thread")
            popup().resetSearchLocationClicked()
            compare(root.lastScope, ["", "", ""])
            compare(popup().searchSelectionButton.threadText, "")
            compare(popup().emptySearchLabel, "")
        }

        function test_reopeningAsChannelDoesNotKeepThreadScope() {
            search.openSearchPopup("parent", "thread")
            tryCompare(search, "opened", true)
            search.closeSearchPopup()
            tryCompare(search, "opened", false)
            search.openSearchPopup("parent", "")
            tryCompare(search, "opened", true)
            compare(root.lastScope, ["section", "parent", ""])
            compare(popup().searchSelectionButton.threadText, "")
        }

        function test_disabledThreadsPreservesChannelScope() {
            search.threadsEnabled = false
            search.openSearchPopup("parent", "thread")
            tryCompare(search, "opened", true)
            compare(root.lastScope, ["section", "parent", ""])
            compare(popup().searchSelectionButton.threadText, "")
        }

        function test_nestedMenuSelectsChannelAndThread_data() {
            return [
                {tag: "channel", thread: false, personal: false},
                {tag: "channel-thread", thread: true, personal: false},
                {tag: "chat", thread: false, personal: true},
                {tag: "chat-thread", thread: true, personal: true}
            ]
        }

        function test_nestedMenuSelectsChannelAndThread(data) {
            // A translated personal title and a community named Chat must both work.
            menuLocations.setProperty(0, "title", data.personal ? "Conversaciones" : "Chat")
            menuLocations.setProperty(0, "value", data.personal ? "personal" : "community")
            menuLocations.setProperty(0, "iconName", data.personal ? "communities" : "chat")
            standaloneMenu.popup()
            tryCompare(standaloneMenu, "opened", true)
            const section = standaloneMenu.menuAt(2)
            verify(!!section)
            section.open()
            tryCompare(section, "opened", true)
            const channel = section.menuAt(0)
            verify(!!channel)
            channel.open()
            tryCompare(channel, "opened", true)
            compare(standaloneMenu.threadLocationChatId, "channel")
            tryVerify(() => channel.actionAt(3) !== null)
            if (data.thread) {
                channel.actionAt(3).trigger()
            } else {
                const header = channel.itemAt(0)
                compare(header.objectName, "searchInParentChat")
                compare(header.Accessible.name, "general")
                compare(header.contentItem.children[0].children[0].text, "Search in")
                compare(header.contentItem.children[0].children[1].text, data.personal ? "general" : "#general")
                tryVerify(() => header.height > 0 && header.contentItem.height > 0)
                waitForRendering(header)
                mouseClick(header, header.width / 2, header.height / 2)
            }
            compare(menuSpy.count, 1)
            compare(Array.from(menuSpy.signalArguments[0]), [data.personal ? "personal" : "community", "channel", data.thread ? "nested-thread" : ""])
            compare(selectionSpy.count, 1)
            compare(selectionSpy.signalArguments[0][0], data.personal ? "general" : "Chat")
            compare(selectionSpy.signalArguments[0][1], data.personal ? "" : "general")
        }

        function test_legacyMenuSelectsChannelDirectly() {
            standaloneMenu.threadsEnabled = false
            standaloneMenu.popup()
            tryCompare(standaloneMenu, "opened", true)
            const section = standaloneMenu.menuAt(2)
            section.open()
            tryCompare(section, "opened", true)
            compare(sectionSpy.count, 0)
            verify(!!section.actionAt(0))
            section.actionAt(0).trigger()
            compare(Array.from(menuSpy.signalArguments[0]), ["community", "channel", ""])
        }

        function test_threadListsLoadOnlyWhenEnteringASection() {
            const menu = createTemporaryObject(lazyMenuComponent, root)
            const spy = createTemporaryObject(sectionSpyComponent, root, {target: menu})
            mouseMove(root, root.width - 1, root.height - 1)
            menu.popup(20, 20)
            tryCompare(menu, "opened", true)
            compare(spy.count, 0)
            const section = menu.menuAt(2)
            section.open()
            tryCompare(section, "opened", true)
            compare(spy.count, 1)
            compare(spy.signalArguments[0][0], "community")
            menu.dismiss()
        }

        function test_chatWithoutThreadsIsDirectlySelectable_data() {
            return [{tag: "channel", personal: false}, {tag: "chat", personal: true}]
        }

        function test_chatWithoutThreadsIsDirectlySelectable(data) {
            if (data.personal)
                menuLocations.setProperty(0, "title", "Chat")
            menuLocations.get(0).subItems.setProperty(0, "hasThreads", false)
            standaloneMenu.popup()
            tryCompare(standaloneMenu, "opened", true)
            const section = standaloneMenu.menuAt(2)
            section.open()
            tryCompare(section, "opened", true)
            compare(section.menuAt(0), null)
            verify(!!section.actionAt(0))
            section.actionAt(0).trigger()
            compare(menuSpy.count, 1)
            compare(Array.from(menuSpy.signalArguments[0]), ["community", "channel", ""])
        }

        function test_threadAvailabilityUpdatesAnOpenMenu() {
            menuLocations.get(0).subItems.setProperty(0, "hasThreads", false)
            standaloneMenu.popup()
            tryCompare(standaloneMenu, "opened", true)
            const section = standaloneMenu.menuAt(2)
            section.open()
            tryCompare(section, "opened", true)
            verify(!!section.actionAt(0))
            menuLocations.get(0).subItems.setProperty(0, "hasThreads", true)
            tryVerify(() => section.menuAt(0) !== null)
            menuLocations.get(0).subItems.setProperty(0, "hasThreads", false)
            tryVerify(() => section.actionAt(0) !== null)
            compare(section.menuAt(0), null)
        }

        function test_threadAvailabilityPreservesMultiChatOrder() {
            const chats = menuLocations.get(0).subItems
            chats.setProperty(0, "hasThreads", false)
            for (const [value, text, position] of [["second", "Second", 1], ["third", "Third", 2]]) {
                chats.append({ value, text, position, imageSource: "", iconName: "channel", iconColor: "#4360DF",
                               isUserIcon: false, isImage: false, colorId: 0, lastMessageTimestamp: 0, hasThreads: false })
            }
            standaloneMenu.popup()
            tryCompare(standaloneMenu, "opened", true)
            const section = standaloneMenu.menuAt(2)
            section.open()
            tryCompare(section, "opened", true)
            compare(section.actionAt(0).text, "general")
            compare(section.actionAt(1).text, "Second")
            compare(section.actionAt(2).text, "Third")
            chats.setProperty(0, "hasThreads", true)
            tryVerify(() => section.menuAt(0) !== null)
            compare(section.menuAt(0).title, "general")
            compare(section.actionAt(1).text, "Second")
            compare(section.actionAt(2).text, "Third")
            chats.setProperty(1, "hasThreads", true)
            tryVerify(() => section.menuAt(1) !== null)
            compare(section.menuAt(1).title, "Second")
            compare(section.actionAt(2).text, "Third")
            chats.setProperty(0, "hasThreads", false)
            tryVerify(() => section.actionAt(0) !== null)
            compare(section.actionAt(0).text, "general")
            compare(section.menuAt(1).title, "Second")
            compare(section.actionAt(2).text, "Third")
            compare(standaloneMenu.actionAt(0).text, "Anywhere")
            compare(standaloneMenu.menuAt(2), section)
        }

        function test_threadSearchWaitsForInputAndUsesStandardDebounce() {
            search.openSearchPopup("parent", "thread")
            tryCompare(search, "opened", true)
            compare(searchSpy.count, 0)
            const input = findChild(search, "searchPopupSearchInput")
            verify(!!input)
            input.text = "needle"
            compare(searchSpy.count, 1)
            compare(searchSpy.signalArguments[0][0], "")
            tryCompare(searchSpy, "count", 2)
            compare(searchSpy.signalArguments[1][0], "needle")
            compare(root.lastScope, ["section", "parent", "thread"])
        }

        function test_inputEditInvalidatesBeforeDebouncedSearch() {
            search.openSearchPopup("parent", "thread")
            tryCompare(search, "opened", true)
            const input = findChild(search, "searchPopupSearchInput")
            input.text = "first"
            tryCompare(searchSpy, "count", 2)
            compare(searchSpy.signalArguments[1][0], "first")
            searchSpy.clear()
            input.text = "second"
            // The old request is invalidated synchronously, before the new timer fires.
            compare(searchSpy.count, 1)
            compare(searchSpy.signalArguments[0][0], "")
            tryCompare(searchSpy, "count", 2)
            compare(searchSpy.signalArguments[1][0], "second")
        }

        function test_sectionWithoutActiveChatDefaultsToAnywhere() {
            root.noActiveChat = true
            search.openSearchPopup()
            tryCompare(search, "opened", true)
            compare(root.lastScope, ["", "", ""])
            compare(popup().searchSelectionButton.primaryText, "Anywhere")
        }

        function test_unavailableExplicitThreadDoesNotBroadenSearch() {
            root.noActiveChat = true
            search.openSearchPopup("removed-parent", "thread")
            tryCompare(search, "opened", true)
            compare(root.lastScope, ["", "removed-parent", "thread"])
            compare(popup().emptySearchLabel, "Search messages in this thread")
        }

        function test_longThreadRouteFitsNarrowPopup() {
            root.locationTitle = "Community ".repeat(20)
            root.chatTitle = "channel-".repeat(20)
            root.threadTitle = "Thread ".repeat(20)
            popup().width = 360
            search.openSearchPopup("parent", "thread")
            tryCompare(search, "opened", true)
            const scope = popup().searchSelectionButton
            verify(scope.width <= popup().width - 64)
            const threadLabel = findChild(popup(), "searchScopeThreadText")
            tryVerify(() => threadLabel.width > 0)
            tryVerify(() => threadLabel.truncated)
        }

        function test_unknownThreadMetadataKeepsExplicitScope() {
            root.threadTitle = ""
            search.openSearchPopup("parent", "thread")
            tryCompare(search, "opened", true)
            compare(root.lastScope, ["section", "parent", "thread"])
            compare(popup().searchSelectionButton.threadText, "Thread")
        }

        function test_selectingThreadFromMenuAndClickingResult() {
            search.openSearchPopup()
            tryCompare(search, "opened", true)
            const menu = findChild(search, "appSearchLocationMenu")
            menu.setSearchSelection("Status Community", "general", "", false, "communities", "#4360DF", false, 0, "Selected thread")
            menu.itemClicked("section", "parent", "selected")
            compare(root.lastScope, ["section", "parent", "selected"])
            compare(popup().searchSelectionButton.threadText, "Selected thread")
            popup().resultItemClicked("message")
            compare(resultSpy.count, 1)
            compare(resultSpy.signalArguments[0][0], "message")
        }
    }
}
