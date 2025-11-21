import QtQuick
import QtQuick.Controls

import StatusQ.Core
import StatusQ.Core.Backpressure
import StatusQ.Popups

import shared.stores
import utils

import AppLayouts.stores

Item {
    id: root

    property AppSearchStore store
    property UtilsStore utilsStore

    readonly property var searchMessages: Backpressure.debounce(searchPopup, 400, function (value) {
        root.store.searchMessages(value)
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
        target: root.store.locationMenuModel
        function onModelAboutToBeReset() {
             while (searchPopupMenu.takeItem(searchPopupMenu.numDefaultItems)) {
                // Delete the item right after the default items
                // If takeItem returns null, it means there was nothing to remove
            }
        }
    }

    Connections {
        target: root.store.appSearchModule
        function onAppSearchCompleted() {
            searchPopup.loading = false
        } 
    }

    StatusSearchLocationMenu {
        id: searchPopupMenu
        
        locationModel: root.store.locationMenuModel

        onItemClicked: {
            root.store.setSearchLocation(firstLevelItemValue, secondLevelItemValue)
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
                                            colorId)
        }
    }

    StatusSearchPopup {
        id: searchPopup
        fillHeightOnBottomSheet: true
        noResultsLabel: qsTr("No results")
        defaultSearchLocationText: qsTr("Anywhere")
        searchOptionsPopupMenu: searchPopupMenu
        searchResults: root.store.resultModel
        formatTimestampFn: function (ts) {
            return LocaleUtils.formatDateTime(parseInt(ts, 10), Locale.ShortFormat)
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
            root.closed();
        }
        onResetSearchLocationClicked: {
            searchPopup.resetSearchSelection();
            root.store.setSearchLocation("", "")
            searchMessages(searchPopup.searchText)
        }
        onOpened: {
            searchPopup.resetSearchSelection();
            root.store.prepareLocationMenuModel()

            const jsonObj = root.store.getSearchLocationObject()

            if (!jsonObj) {
                return
            }

            let obj = JSON.parse(jsonObj)
            if (obj.location === "" || (obj.location !== "" && !obj.subLocation)) {
                if(obj.subLocation === "") {
                    root.store.setSearchLocation("", "")
                } else {
                    searchPopup.setSearchSelection(obj.subLocation.text,
                                                   "",
                                                   obj.subLocation.imageSource,
                                                   false,
                                                   obj.subLocation.iconName,
                                                   obj.subLocation.identiconColor)

                    root.store.setSearchLocation("", obj.subLocation.value)
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
                                                   obj.subLocation.colorId)

                    root.store.setSearchLocation(obj.location.value, obj.subLocation.value)
                } else {
                    searchPopup.setSearchSelection(obj.location.title,
                                                   obj.subLocation.text,
                                                   obj.location.imageSource,
                                                   false,
                                                   obj.location.iconName,
                                                   obj.location.identiconColor)

                    root.store.setSearchLocation(obj.location.value, obj.subLocation.value)
                }
            }
        }
        onResultItemClicked: {
            searchPopup.close()
            root.store.resultItemClicked(itemId)
        }
        acceptsTitleClick: function (titleId) {
            return root.utilsStore.isChatKey(titleId)
        }
        onResultItemTitleClicked: Global.openProfilePopup(titleId, searchPopup)
    }
}
