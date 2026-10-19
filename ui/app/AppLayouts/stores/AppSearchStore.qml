import QtQuick

QtObject {
    id: root

    property var appSearchModule

    property var locationMenuModel: root.appSearchModule.locationMenuModel
    readonly property var threadLocationMenuModel: root.appSearchModule.threadLocationMenuModel
    readonly property bool threadLocationsLoading: root.appSearchModule.threadLocationsLoading
    readonly property bool threadLocationsError: root.appSearchModule.threadLocationsError
    property var resultModel: root.appSearchModule.resultModel
    property bool searchInProgress: false

    readonly property Connections appSearchModuleConnections: Connections {
        target: root.appSearchModule
        function onAppSearchCompleted() {
            root.searchInProgress = false
        }
    }

    function searchMessages(searchTerm) {
        if(!root.appSearchModule)
            return
        root.searchInProgress = searchTerm !== ""
        root.appSearchModule.searchMessages(searchTerm)
    }

    function setSearchLocation(location, subLocation, threadId = "") {
        if(!root.appSearchModule)
            return
        root.appSearchModule.setSearchLocation(location, subLocation, threadId)
    }

    function prepareLocationMenuModel() {
        if(!root.appSearchModule)
            return
        root.appSearchModule.prepareLocationMenuModel()
    }

    function getSearchLocationObject(chatId = "", threadId = "") {
        if(!root.appSearchModule)
            return ""
        return root.appSearchModule.getSearchLocationObject(chatId, threadId)
    }

    function prepareThreadLocationMenuModel(chatId) {
        if (root.appSearchModule)
            root.appSearchModule.prepareThreadLocationMenuModel(chatId)
    }

    function prepareThreadLocationsForSection(sectionId) {
        if (root.appSearchModule)
            root.appSearchModule.prepareThreadLocationsForSection(sectionId)
    }

    function resultItemClicked(itemId) {
        if(!root.appSearchModule)
            return
        root.appSearchModule.resultItemClicked(itemId)
    }
}
