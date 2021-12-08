import QtQuick 2.13
import QtQuick.Controls 2.13

import utils 1.0
import StatusQ.Popups 0.1

Item {
    id: appSearch

    property var store
    readonly property var searchMessages: Backpressure.debounce(searchPopup, 400, function (value) {
        store.searchMessages(value)
    })

    function openSearchPopup(){
        searchPopup.open()
    }

    Connections {
        target: store.locationMenuModel
        onModelAboutToBeReset: {
            for (var i = 2; i <= searchPopupMenu.count; i++) {
                //clear menu
                if (!!searchPopupMenu.takeItem(i)) {
                    searchPopupMenu.removeItem(searchPopupMenu.takeItem(i));
                }
            }
        }
    }

    StatusSearchLocationMenu {
        id: searchPopupMenu
        searchPopup: searchPopup
        locationModel: store.locationMenuModel

        onItemClicked: {
            store.setSearchLocation(firstLevelItemValue, secondLevelItemValue)
            if(searchPopup.searchText !== "")
                searchMessages(searchPopup.searchText)
        }
    }

    StatusSearchPopup {
        id: searchPopup

        noResultsLabel: qsTr("No results")
        defaultSearchLocationText: qsTr("Anywhere")

        searchOptionsPopupMenu: searchPopupMenu
        searchResults: store.resultModel

        formatTimestampFn: function (ts) {
            return new Date(parseInt(ts, 10)).toLocaleString(Qt.locale(localAppSettings.locale))
        }

        onSearchTextChanged: {
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
            store.prepareLocationMenuModel()

            const jsonObj = store.getSearchLocationObject()

            if (!jsonObj) {
                return
            }

            let obj = JSON.parse(jsonObj)
            if (obj.location === "") {
                if(obj.subLocation === "") {
                    store.setSearchLocation("", "")
                }
                else {
                    searchPopup.setSearchSelection(obj.subLocation.text,
                                                   "",
                                                   obj.subLocation.imageSource,
                                                   obj.subLocation.isIdenticon,
                                                   obj.subLocation.iconName,
                                                   obj.subLocation.identiconColor)

                    store.setSearchLocation("", obj.subLocation.value)
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

                    store.setSearchLocation(obj.location.value, obj.subLocation.value)
                }
                else {
                    searchPopup.setSearchSelection(obj.location.title,
                                                   obj.subLocation.text,
                                                   obj.location.imageSource,
                                                   obj.location.isIdenticon,
                                                   obj.location.iconName,
                                                   obj.location.identiconColor)

                    store.setSearchLocation(obj.location.value, obj.subLocation.value)
                }
            }
        }
        onResultItemClicked: {
            searchPopup.close()

            // Not Refactored
            //root.rootStore.chatsModelInst.switchToSearchedItem(itemId)
        }

        onResultItemTitleClicked: {
            // Not Refactored
            //const pk = titleId
            //const userProfileImage = Global.getProfileImage(pk)
            //return Global.openProfilePopup(root.rootStore.chatsModelInst.userNameOrAlias(pk), pk, userProfileImage || root.rootStore.utilsModelInst.generateIdenticon(pk))
        }
    }
}
