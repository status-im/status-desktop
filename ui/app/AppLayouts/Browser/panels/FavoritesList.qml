import QtQuick

import StatusQ.Core

import utils

import "../controls"

StatusGridView {
    id: bookmarkGrid

    property var determineRealURLFn: function(url){}
    property var setAsCurrentWebUrl: function(url){}
    property var favMenu
    property var addFavModal

    cellWidth: 100
    cellHeight: 100

    delegate: BookmarkButton {
        id: bookmarkBtn
        text: name
        source: imageUrl
        webUrl: determineRealURLFn(url)
        onClicked: function(mouse) {
            if (!webUrl.toString()) {
                Global.openPopup(addFavModal)
            } else {
                setAsCurrentWebUrl(webUrl)
            }
        }
        onRightClicked: function(mouse) {
            favMenu.url = url
            favMenu.x = bookmarkGrid.x + bookmarkBtn.x + mouse.x
            favMenu.y = Qt.binding(function () {return bookmarkGrid.y + mouse.y + favMenu.height})
            favMenu.open()
        }
    }
}
