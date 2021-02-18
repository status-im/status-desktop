import QtQuick 2.13
import "../../../shared"
import "../../../shared/status"
import "../../../imports"
import "./components"

Item {
    id: bookmarkListContainer

    ListView {
        id: bookmarkList
        model: browserModel.bookmarks
        spacing: Style.current.padding
        orientation : ListView.Horizontal
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.horizontalCenterOffset: -(addBookmarkBtn.width + spacing) /2
        width: Math.min(childrenRect.width, parent.width - addBookmarkBtn.width - spacing)
        delegate: BookmarkButton {
            id: bookmarkBtn
            text: name
            onClicked: {
                currentWebView.url = determineRealURL(url)
            }
            source: imageUrl
            onRightClicked: {
                favoriteMenu.url = url
                favoriteMenu.x = bookmarkList.x + bookmarkBtn.x + mouse.x
                favoriteMenu.y = Qt.binding(function () {return bookmarkListContainer.y + mouse.y + favoriteMenu.height})
                favoriteMenu.open()
            }
        }
    }

    BookmarkButton {
        id: addBookmarkBtn
        //% "Add favorite"
        text: qsTrId("add-favorite")
        onClicked: {
            addFavoriteModal.open()
        }
        anchors.left: bookmarkList.right
        anchors.leftMargin: bookmarkList.spacing
    }
}
