import QtQuick 2.13
import QtQuick.Controls 2.13

import StatusQ.Core 0.1
import StatusQ.Popups 0.1

import shared.stores 1.0
import utils 1.0

Item {
    id: appSearch

    property var store
    readonly property var searchMessages: Backpressure.debounce(searchPopup, 400, function (value) {
        appSearch.store.searchMessages(value)
    })
    property alias opened: searchPopup.opened

    signal closed()

    function openSearchPopup(){
        searchPopup.open()
    }

    function closeSearchPopup(){
        searchPopup.close()
    }

    Connections {
        target: appSearch.store.locationMenuModel
        function onModelAboutToBeReset() {
             while (searchPopupMenu.takeItem(searchPopupMenu.numDefaultItems)) {
                // Delete the item right after the default items
                // If takeItem returns null, it means there was nothing to remove
            }
        }
    }

    Connections {
        target: appSearch.store.appSearchModule
        function onAppSearchCompleted() {
            searchPopup.loading = false
        } 
    }

    StatusSearchLocationMenu {
        id: searchPopupMenu
        
        locationModel: appSearch.store.locationMenuModel

        onItemClicked: {
            appSearch.store.setSearchLocation(firstLevelItemValue, secondLevelItemValue)
            searchPopup.forceActiveFocus()
            if(searchPopup.searchText !== "")
                searchMessages(searchPopup.searchText)
        }

        onResetSearchSelection: {
            searchPopup.resetSearchSelection()
        }

        onSetSearchSelection: {
            searchPopup.setSearchSelection(text,
                                            secondaryText,
                                            imageSource,
                                            isIdenticon,
                                            iconName,
                                            iconColor,
                                            isUserIcon,
                                            colorId,
                                            colorHash)
        }
    }

    StatusSearchPopup {
        id: searchPopup
        noResultsLabel: qsTr("No results")
        defaultSearchLocationText: qsTr("Anywhere")
        searchOptionsPopupMenu: searchPopupMenu
        searchResults: appSearch.store.resultModel
        formatTimestampFn: function (ts) {
            return LocaleUtils.formatDateTime(parseInt(ts, 10))
        }
        onSearchTextChanged: {
            if (searchPopup.searchText !== "") {
                searchPopup.loading = true
                searchMessages(searchPopup.searchText);
            }
        }
        onAboutToHide: {
            if (searchPopupMenu.visible) {
                searchPopupMenu.close();
            }
        }
        onClosed: {
            searchPopupMenu.dismiss();
            appSearch.closed();
        }
        onResetSearchLocationClicked: {
            searchPopup.resetSearchSelection();
            appSearch.store.setSearchLocation("", "")
            searchMessages(searchPopup.searchText)
        }
        onOpened: {
            searchPopup.resetSearchSelection();
            appSearch.store.prepareLocationMenuModel()

            const jsonObj = appSearch.store.getSearchLocationObject()

            if (!jsonObj) {
                return
            }

            let obj = JSON.parse(jsonObj)
            if (obj.location === "" || (obj.location !== "" && !obj.subLocation)) {
                if(obj.subLocation === "") {
                    appSearch.store.setSearchLocation("", "")
                } else {
                    searchPopup.setSearchSelection(obj.subLocation.text,
                                                   "",
                                                   obj.subLocation.imageSource,
                                                   false,
                                                   obj.subLocation.iconName,
                                                   obj.subLocation.identiconColor)

                    appSearch.store.setSearchLocation("", obj.subLocation.value)
                }
            } else {
                if (obj.location.title === "Chat" && !!obj.subLocation) {
                    searchPopup.setSearchSelection(obj.subLocation.text,
                                                   "",
                                                   obj.subLocation.imageSource,
                                                   false,
                                                   obj.subLocation.iconName,
                                                   obj.subLocation.identiconColor,
                                                   obj.subLocation.isUserIcon,
                                                   obj.subLocation.colorId,
                                                   obj.subLocation.colorHash)

                    appSearch.store.setSearchLocation(obj.location.value, obj.subLocation.value)
                } else {
                    searchPopup.setSearchSelection(obj.location.title,
                                                   obj.subLocation.text,
                                                   obj.location.imageSource,
                                                   false,
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
        onResultItemTitleClicked: Global.openProfilePopup(titleId, searchPopup)
    }
}
