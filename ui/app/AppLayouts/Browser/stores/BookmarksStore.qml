pragma Singleton

import QtQuick 2.13

QtObject {
    id: root

    property var browserModelInst: browserModel

    // Seems like this vould be a BookMarks Store which has everything related to bookmarks
    property var bookmarksModel: browserModel.bookmarks

    function addBookmark(url, name)
    {
        browserModel.addBookmark(url, name)
    }

    function removeBookmark(url)
    {
        browserModel.removeBookmark(url)
    }

    function modifyBookmark(originalUrl, newUrl, newName)
    {
        browserModel.modifyBookmark(originalUrl, newUrl, newName)
    }

    function getBookmarkIndexByUrl(url)
    {
        return browserModel.bookmarks.getBookmarkIndexByUrl(url)
    }

    function getCurrentFavorite(url) {
        if (!url) {
            return null
        }
        const index = browserModel.bookmarks.getBookmarkIndexByUrl(url)
        if (index === -1) {
            return null
        }

        return {
            url: url,
            name: browserModel.bookmarks.rowData(index, 'name'),
            image: browserModel.bookmarks.rowData(index, 'imageUrl')
        }
    }
    // END >> Seems like this vould be a BookMarks Store which has everything related to bookmarks
}
