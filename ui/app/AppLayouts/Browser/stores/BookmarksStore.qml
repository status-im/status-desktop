pragma Singleton

import QtQuick 2.13

QtObject {
    id: root

    // Seems like this vould be a BookMarks Store which has everything related to bookmarks
    property var bookmarksModel: bookmarkModule.model

    function addBookmark(url, name)
    {
        bookmarkModule.addBookmark(url, name)
    }

    function deleteBookmark(url)
    {
        bookmarkModule.deleteBookmark(url)
    }

    function updateBookmark(originalUrl, newUrl, newName)
    {
        bookmarkModule.updateBookmark(originalUrl, newUrl, newName)
    }

    function getBookmarkIndexByUrl(url)
    {
        return bookmarkModule.model.getBookmarkIndexByUrl(url)
    }

    function getCurrentFavorite(url) {
        if (!url) {
            return null
        }
        const index = bookmarkModule.model.getBookmarkIndexByUrl(url)
        if (index === -1) {
            return null
        }

        return {
            url: url,
            name: bookmarkModule.model.rowData(index, 'name'),
            image: bookmarkModule.model.rowData(index, 'imageUrl')
        }
    }
    // END >> Seems like this vould be a BookMarks Store which has everything related to bookmarks
}
