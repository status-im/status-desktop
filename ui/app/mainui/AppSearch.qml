import QtQuick

import StatusQ.Core
import StatusQ.Core.Backpressure
import StatusQ.Popups

Item {
    id: root

    property bool threadsEnabled: false
    property string personalChatsSectionId
    property var threadLocationMenuModel
    property bool threadLocationsLoading: false
    property bool threadLocationsError: false
    property var prepareThreadLocationMenuModelFn
    property var prepareThreadLocationsForSectionFn

    QtObject {
        id: d
        property string initialChatId
        property string initialThreadId
        property string selectedThreadId
    }

    required property var locationMenuModel
    required property var resultModel
    required property bool searchInProgress
    required property var setSearchLocationFn
    required property var prepareLocationMenuModelFn
    required property var getSearchLocationObjectFn
    required property var isChatKeyFn
    required property var openProfilePopupFn

    readonly property var searchMessagesDebounced: Backpressure.debounce(searchPopup, 400, function () {
        if (!searchPopup.opened || searchPopup.searchText === "")
            return

        root.searchMessages(searchPopup.searchText)
    })
    property alias opened: searchPopup.opened

    signal closed()
    signal searchMessages(string searchTerm)
    signal resultItemClicked(string itemId)

    function clearSearchResults() {
        root.searchMessages("")
    }

    function openSearchPopup(chatId = "", threadId = "") {
        d.initialChatId = chatId
        d.initialThreadId = threadId
        searchPopup.open()
    }

    function closeSearchPopup(){
        searchPopup.close()
    }

    Connections {
        target: root.locationMenuModel
        function onModelAboutToBeReset() {
             while (searchPopupMenu.takeItem(searchPopupMenu.numDefaultItems)) {
                // Delete the item right after the default items
                // If takeItem returns null, it means there was nothing to remove
            }
        }
    }

    StatusSearchLocationMenu {
        id: searchPopupMenu
        objectName: "appSearchLocationMenu"
        
        locationModel: root.locationMenuModel
        personalChatsSectionId: root.personalChatsSectionId
        threadsEnabled: root.threadsEnabled
        threadLocationModel: root.threadLocationMenuModel
        threadLocationsLoading: root.threadLocationsLoading
        threadLocationsError: root.threadLocationsError
        onThreadLocationsRequested: chatId => root.prepareThreadLocationMenuModelFn(chatId)
        onThreadLocationSectionRequested: sectionId => {
            if (root.prepareThreadLocationsForSectionFn)
                root.prepareThreadLocationsForSectionFn(sectionId)
        }

        onItemClicked: (firstLevelItemValue, secondLevelItemValue, threadId) => {
            d.selectedThreadId = threadId
            root.clearSearchResults()
            root.setSearchLocationFn(firstLevelItemValue, secondLevelItemValue, threadId)
            searchPopup.forceActiveFocus()
            if(searchPopup.searchText !== "")
                root.searchMessagesDebounced()
        }

        onResetSearchSelection: {
            searchPopup.resetSearchSelection()
        }

        onSetSearchSelection: (text, secondaryText, imageSource, isIdenticon, iconName, iconColor, isUserIcon, colorId, threadText) => {
            searchPopup.setSearchSelection(text,
                                            secondaryText,
                                            imageSource,
                                            isIdenticon,
                                            iconName,
                                            iconColor,
                                            isUserIcon,
                                            colorId,
                                            threadText)
        }
    }

    StatusSearchPopup {
        id: searchPopup
        objectName: "appSearchPopup"
        fillHeightOnBottomSheet: true
        noResultsLabel: qsTr("No results")
        emptySearchLabel: d.selectedThreadId ? qsTr("Search messages in this thread") : ""
        defaultSearchLocationText: qsTr("Anywhere")
        searchOptionsPopupMenu: searchPopupMenu
        searchResults: root.resultModel
        loading: root.searchInProgress
        formatTimestampFn: function (ts) {
            return LocaleUtils.formatDateTime(parseInt(ts, 10), Locale.ShortFormat)
        }
        onSearchTextChanged: {
            root.clearSearchResults()
            if (searchPopup.searchText !== "")
                root.searchMessagesDebounced()
        }
        onAboutToHide: {
            if (searchPopupMenu.visible) {
                searchPopupMenu.close();
            }
        }
        onClosed: {
            searchPopupMenu.dismiss();
            root.clearSearchResults();
            root.closed();
        }
        onResetSearchLocationClicked: {
            d.selectedThreadId = ""
            root.clearSearchResults()
            searchPopup.resetSearchSelection();
            root.setSearchLocationFn("", "", "")
            root.searchMessagesDebounced()
        }
        onOpened: {
            searchPopup.resetSearchSelection()
            d.selectedThreadId = ""
            root.prepareLocationMenuModelFn()
            const json = root.getSearchLocationObjectFn(d.initialChatId, d.initialThreadId)
            if (!json)
                return

            const scope = JSON.parse(json)
            const location = scope.location
            const chat = scope.subLocation
            const thread = root.threadsEnabled ? scope.thread : null
            if (!chat) {
                // Keep an unavailable explicit thread from broadening into an Anywhere search.
                d.selectedThreadId = root.threadsEnabled ? d.initialThreadId : ""
                root.setSearchLocationFn("", d.selectedThreadId ? d.initialChatId : "", d.selectedThreadId)
                if (d.selectedThreadId)
                    searchPopup.setSearchSelection(qsTr("Thread"), "", "", false, "thread")
                return
            }
            d.selectedThreadId = thread?.value ?? ""
            root.setSearchLocationFn(location?.value ?? "", chat.value, d.selectedThreadId)

            const belongsToPersonalChatsSection = !location || location.value === root.personalChatsSectionId
            searchPopup.setSearchSelection(belongsToPersonalChatsSection ? chat.text : location.title,
                                           belongsToPersonalChatsSection ? "" : chat.text,
                                           belongsToPersonalChatsSection ? chat.imageSource : location.imageSource,
                                           false,
                                           belongsToPersonalChatsSection ? chat.iconName : location.iconName,
                                           belongsToPersonalChatsSection ? chat.iconColor : location.iconColor,
                                           belongsToPersonalChatsSection && chat.isUserIcon,
                                           chat.colorId ?? 0,
                                           thread?.value ? (thread.text || qsTr("Thread")) : "")
        }
        onResultItemClicked: (itemId) => {
            searchPopup.close()
            root.resultItemClicked(itemId)
        }
        acceptsTitleClick: function (titleId) {
            return root.isChatKeyFn(titleId)
        }
        onResultItemTitleClicked: (titleId) => {
            root.openProfilePopupFn(titleId, searchPopup)
        }
    }
}
