pragma Singleton

import QtQuick 2.15

import StatusQ.Core.Utils 0.1 as SQUtils

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

        const item = SQUtils.ModelUtils.get(bookmarkModule.model, index)

        return {
            url: url,
            name: item.name,
            image: item.imageUrl
        }
    }
}
