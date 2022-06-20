import QtQuick 2.13
import QtQuick.Controls 2.3

import shared.panels 1.0
import shared.popups 1.0

import utils 1.0

import "../stores"

// TODO: replace with StatusPopupMenu
PopupMenu {
    id: favoritePopupMenu

    property var openInNewTab: function () {}
    property string url
    property var currentFavorite: BookmarksStore.getCurrentFavorite(url)

    signal editFavoriteTriggered()

    closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutside

    Action {
        //% "Open in new Tab"
        text: qsTrId("open-in-new-tab")
        icon.source: Style.svg("generate_account")
        icon.width: Style.dp(16)
        icon.height: Style.dp(16)
        onTriggered: {
            openInNewTab(favoritePopupMenu.url)
        }
    }

    Separator {}

    Action {
        //% "Edit"
        text: qsTrId("edit")
        icon.source: Style.svg("edit")
        icon.width: Style.dp(16)
        icon.height: Style.dp(16)
        onTriggered: {
            // Force reloading current favorite as it could have been modified when edited:
            favoritePopupMenu.currentFavorite = BookmarksStore.getCurrentFavorite(url)
            editFavoriteTriggered()
        }
    }

    Action {
        //% "Remove"
        text: qsTrId("remove")
        icon.source: Style.svg("remove")
        icon.color: Style.current.danger
        icon.width: Style.dp(16)
        icon.height: Style.dp(16)
        onTriggered: {
            BookmarksStore.deleteBookmark(favoritePopupMenu.url)
        }
    }
}
