import QtQuick 2.13
import QtQuick.Layouts 1.13

import utils 1.0

import StatusQ.Controls 0.1

RowLayout {
    id: favoritesBar

    property alias bookmarkModel: bookmarkList.model

    spacing: 0
    height: bookmarkModel.rowCount() > 0 ? 38: 0

    ListView {
        id: bookmarkList
        spacing: Style.current.halfPadding
        orientation : ListView.Horizontal
        height: parent.height
        clip: true
        Layout.alignment: Qt.AlignLeft | Qt.AlignTop
        width: parent.width
        boundsBehavior: Flickable.StopAtBounds
        delegate: StatusFlatButton {
            id: favoriteBtn
            height: 32
            icon.source: imageUrl
            icon.width: 24
            icon.height: 24
            text: name

            MouseArea {
                anchors.fill: parent
                acceptedButtons: Qt.LeftButton | Qt.RightButton
                z: 51
                onClicked: function (mouse) {
                    const isAddBookmarkButton = url === Constants.newBookmark
                    if (mouse.button === Qt.RightButton && isAddBookmarkButton) {
                        return
                    }

                    if (mouse.button === Qt.RightButton) {
                        favoriteMenu.url = url
                        favoriteMenu.x = favoriteBtn.x + mouse.x
                        favoriteMenu.y = Qt.binding(function () {return mouse.y + favoriteMenu.height})
                        favoriteMenu.open()
                        return
                    }

                    if (isAddBookmarkButton) {
                        addFavoriteModal.toolbarMode = true
                        addFavoriteModal.ogUrl = browserHeader.currentFavorite ? browserHeader.currentFavorite.url : currentWebView.url
                        addFavoriteModal.ogName = browserHeader.currentFavorite ? browserHeader.currentFavorite.name : currentWebView.title
                        addFavoriteModal.open()
                        return
                    }

                    currentWebView.url = determineRealURL(url)
                }
            }
        }
    }
}
