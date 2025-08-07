import QtQuick
import QtQuick.Controls

import StatusQ.Popups

import AppLayouts.Browser.stores as BrowserStores

StatusMenu {
    id: root

    required property BrowserStores.BookmarksStore bookmarksStore

    property var openInNewTab: function () {}
    property string url
    property var currentFavorite: root.bookmarksStore.getCurrentFavorite(url)

    signal editFavoriteTriggered()

    StatusAction {
        text: qsTr("Open in new Tab")
        icon.name: "generate_account"
        onTriggered: {
            openInNewTab(root.url)
        }
    }

    StatusMenuSeparator {}

    StatusAction {
        text: qsTr("Edit")
        icon.name: "edit"
        onTriggered: {
            // Force reloading current favorite as it could have been modified when edited:
            root.currentFavorite = root.bookmarksStore.getCurrentFavorite(url)
            editFavoriteTriggered()
        }
    }

    StatusAction {
        text: qsTr("Remove")
        icon.name: "remove"
        type: StatusAction.Type.Danger
        onTriggered: {
            root.bookmarksStore.deleteBookmark(root.url)
        }
    }
}
