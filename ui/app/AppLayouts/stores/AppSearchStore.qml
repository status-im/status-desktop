import QtQuick

QtObject {
    id: root

    property var appSearchModule

    property var locationMenuModel: root.appSearchModule.locationMenuModel
    property var resultModel: root.appSearchModule.resultModel

    function searchMessages(searchTerm) {
        if(!root.appSearchModule)
            return
        root.appSearchModule.searchMessages(searchTerm)
    }

    function setSearchLocation(location, subLocation) {
        if(!root.appSearchModule)
            return
        root.appSearchModule.setSearchLocation(location, subLocation)
    }

    function prepareLocationMenuModel() {
        if(!root.appSearchModule)
            return
        root.appSearchModule.prepareLocationMenuModel()
    }

    function getSearchLocationObject() {
        if(!root.appSearchModule)
            return ""
        return root.appSearchModule.getSearchLocationObject()
    }

    function resultItemClicked(itemId) {
        if(!root.appSearchModule)
            return
        root.appSearchModule.resultItemClicked(itemId)
    }
}
