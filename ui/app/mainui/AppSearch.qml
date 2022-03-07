import QtQuick 2.13
import QtQuick.Controls 2.13

import utils 1.0
import StatusQ.Popups 0.1

Item {
    id: appSearch

    property var store
    readonly property var searchMessages: Backpressure.debounce(searchPopup, 400, function (value) {
        appSearch.store.searchMessages(value)
    })
    property alias opened: searchPopup.opened

    function openSearchPopup(){
        searchPopup.open()
    }

    function closeSearchPopup(){
        searchPopup.close()
    }

    Connections {
        target: appSearch.store.locationMenuModel
        onModelAboutToBeReset: {
             while (searchPopupMenu.takeItem(searchPopupMenu.numDefaultItems)) {
                // Delete the item right after the default items
                // If takeItem returns null, it means there was nothing to remove
            }
        }
    }

    Connections {
        target: appSearch.store.appSearchModule
        onAppSearchCompleted: searchPopup.loading = false
    }

    StatusSearchLocationMenu {
        id: searchPopupMenu
        searchPopup: searchPopup
        locationModel: appSearch.store.locationMenuModel

        onItemClicked: {
            appSearch.store.setSearchLocation(firstLevelItemValue, secondLevelItemValue)
            if(searchPopup.searchText !== "")
                searchMessages(searchPopup.searchText)
        }
    }

    StatusSearchPopup {
        id: searchPopup

        noResultsLabel: qsTr("No results")
        defaultSearchLocationText: qsTr("Anywhere")

        searchOptionsPopupMenu: searchPopupMenu
        searchResults: appSearch.store.resultModel

        formatTimestampFn: function (ts) {
            return new Date(parseInt(ts, 10)).toLocaleString(Qt.locale(localAppSettings.locale))
        }

        onSearchTextChanged: {
            searchPopup.loading = true
            searchMessages(searchPopup.searchText);
        }
        onAboutToHide: {
            if (searchPopupMenu.visible) {
                searchPopupMenu.close();
            }
        }
        onClosed: {
            searchPopupMenu.dismiss();
        }
        onOpened: {
            searchPopup.resetSearchSelection();
            searchPopup.forceActiveFocus()
            appSearch.store.prepareLocationMenuModel()

            const jsonObj = appSearch.store.getSearchLocationObject()

            if (!jsonObj) {
                return
            }

            let obj = JSON.parse(jsonObj)
            if (obj.location === "") {
                if(obj.subLocation === "") {
                    appSearch.store.setSearchLocation("", "")
                }
                else {
                    searchPopup.setSearchSelection(obj.subLocation.text,
                                                   "",
                                                   obj.subLocation.imageSource,
                                                   obj.subLocation.isIdenticon,
                                                   obj.subLocation.iconName,
                                                   obj.subLocation.identiconColor)

                    appSearch.store.setSearchLocation("", obj.subLocation.value)
                }
            }
            else {
                if (obj.location.title === "Chat") {
                    searchPopup.setSearchSelection(obj.subLocation.text,
                                                   "",
                                                   obj.subLocation.imageSource,
                                                   obj.subLocation.isIdenticon,
                                                   obj.subLocation.iconName,
                                                   obj.subLocation.identiconColor)

                    appSearch.store.setSearchLocation(obj.location.value, obj.subLocation.value)
                }
                else {
                    searchPopup.setSearchSelection(obj.location.title,
                                                   obj.subLocation.text,
                                                   obj.location.imageSource,
                                                   obj.location.isIdenticon,
                                                   obj.location.iconName,
                                                   obj.location.identiconColor)

                    appSearch.store.setSearchLocation(obj.location.value, obj.subLocation.value)
                }
            }
        }
        onResultItemClicked: {
            searchPopup.close()
            appSearch.store.resultItemClicked(itemId)
        }
        acceptsTitleClick: function (titleId) {
            return Utils.isChatKey(titleId)
        }
        onResultItemTitleClicked: Global.openProfilePopup(titleId)
    }
}
