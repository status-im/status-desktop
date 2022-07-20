import QtQuick 2.13

import StatusQ.Core 0.1

import utils 1.0

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
