import QtQuick

import StatusQ.Core.Utils as SQUtils

QtObject {
    id: root

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
        return bookmarksModel.getBookmarkIndexByUrl(url)
    }

    function getCurrentFavorite(url) {
        if (!url) {
            return null
        }
        const index = getBookmarkIndexByUrl(url)
        if (index === -1) {
            return null
        }

        const item = SQUtils.ModelUtils.get(bookmarksModel, index)

        return {
            url: url,
            name: item.name,
            image: item.imageUrl
        }
    }
}
