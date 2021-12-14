import QtQuick 2.13
import shared 1.0
import shared.status 1.0
import "../controls"

import utils 1.0

GridView {
    id: bookmarkGrid
    cellWidth: 100
    cellHeight: 100
    delegate: BookmarkButton {
        id: bookmarkBtn
        text: name
        source: imageUrl
        webUrl: determineRealURL(url)
        onClicked: {
            if (!webUrl.toString()) {
                addFavoriteModal.ogName = ""
                addFavoriteModal.ogUrl = ""
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
}
