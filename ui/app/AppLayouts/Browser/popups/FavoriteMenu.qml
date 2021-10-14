import QtQuick 2.13
import QtQuick.Controls 2.3
import QtWebEngine 1.9
import shared 1.0
import shared.panels 1.0
import shared.status 1.0
import shared.popups 1.0
import "../stores"

import utils 1.0

import "../../Chat/popups"

// TODO: replace with StatusPopupMenu
PopupMenu {
    property var openInNewTab: function () {}
    property string url
    property var currentFavorite: BookmarksStore.getCurrentFavorite(url)

    id: root
    closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutside

    Action {
        //% "Open in new Tab"
        text: qsTrId("open-in-new-tab")
        icon.source: Style.svg("generate_account")
        icon.width: 16
        icon.height: 16
        onTriggered: {
            openInNewTab(root.url)
        }
    }

    Separator {}

    Action {
        //% "Edit"
        text: qsTrId("edit")
        icon.source: Style.svg("edit")
        icon.width: 16
        icon.height: 16
        onTriggered: {
            addFavoriteModal.modifiyModal = true
            addFavoriteModal.ogUrl = root.currentFavorite ? root.currentFavorite.url : currentWebView.url
            addFavoriteModal.ogName = root.currentFavorite ? root.currentFavorite.name : currentWebView.title
            addFavoriteModal.open()
        }
    }

    Action {
        //% "Remove"
        text: qsTrId("remove")
        icon.source: Style.svg("remove")
        icon.color: Style.current.danger
        icon.width: 16
        icon.height: 16
        onTriggered: {
            BookmarksStore.deleteBookmark(root.url)
        }
    }
}
