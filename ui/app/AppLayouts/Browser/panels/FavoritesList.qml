import QtQuick 2.13

import utils 1.0

import "../controls"

GridView {
    id: bookmarkGrid

    property var determineRealURLFn: function(url){}
    property var setAsCurrentWebUrl: function(url){}
    property var favMenu
    property var addFavModal

    cellWidth: Style.dp(100)
    cellHeight: Style.dp(100)

    delegate: BookmarkButton {
        id: bookmarkBtn
        text: name
        source: imageUrl
        webUrl: determineRealURLFn(url)
        onClicked: {
            if (!webUrl.toString()) {
                Global.openPopup(addFavModal)
            } else {
                setAsCurrentWebUrl(webUrl)
            }
        }
        onRightClicked: {
            favMenu.url = url
            favMenu.x = bookmarkGrid.x + bookmarkBtn.x + mouse.x
            favMenu.y = Qt.binding(function () {return bookmarkGrid.y + mouse.y + favMenu.height})
            favMenu.open()
        }
    }
}
