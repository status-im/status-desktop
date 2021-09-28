import QtQuick 2.13
import "../../../shared"
import "../../../shared/status"

import utils 1.0
import "./components"

GridView {
    id: bookmarkGrid
    cellWidth: 100
    cellHeight: 100
    model: browserModel.bookmarks
    delegate: BookmarkButton {
        id: bookmarkBtn
        text: name
        source: imageUrl
        webUrl: determineRealURL(url)
        onClicked: {
            if (!webUrl.toString()) {
                addFavoriteModal.open()
            } else {
                currentWebView.url = webUrl
            }
        }
        onRightClicked: {
            favoriteMenu.url = url
            favoriteMenu.x = bookmarkGrid.x + bookmarkBtn.x + mouse.x
            favoriteMenu.y = Qt.binding(function () {return bookmarkGrid.y + mouse.y + favoriteMenu.height})
            favoriteMenu.open()
        }
    }

    Component.onCompleted: {
        // Add fav button at the end of the grid
        var index = browserModel.bookmarks.getBookmarkIndexByUrl("")
        if (index !== -1) {
            browserModel.removeBookmark("")
        }
        browserModel.addBookmark("", qsTr("Add Favorite"))
    }
}
