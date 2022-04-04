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
        text: qsTr("Open in new Tab")
        icon.source: Style.svg("generate_account")
        icon.width: 16
        icon.height: 16
        onTriggered: {
            openInNewTab(favoritePopupMenu.url)
        }
    }

    Separator {}

    Action {
        text: qsTr("Edit")
        icon.source: Style.svg("edit")
        icon.width: 16
        icon.height: 16
        onTriggered: {
            // Force reloading current favorite as it could have been modified when edited:
            favoritePopupMenu.currentFavorite = BookmarksStore.getCurrentFavorite(url)
            editFavoriteTriggered()
        }
    }

    Action {
        text: qsTr("Remove")
        icon.source: Style.svg("remove")
        icon.color: Style.current.danger
        icon.width: 16
        icon.height: 16
        onTriggered: {
            BookmarksStore.deleteBookmark(favoritePopupMenu.url)
        }
    }
}
