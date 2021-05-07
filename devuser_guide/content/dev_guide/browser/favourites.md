---
title : "Favourites"
description: ""
lead: ""
date: 2020-10-06T08:48:23+00:00
lastmod: 2020-10-06T08:48:23+00:00
draft: false
images: []
menu:
  dev:
    parent: "browser"
toc: true
---

[User Docs for this section](/docs/browser/favourites/)

## Adding a favourite

key source file: [`src/status/libstatus/browser.nim`](https://github.com/status-im/status-desktop/blob/d2b6bf9310df088c89abcca7c1df42abc3999b18/src/status/libstatus/browser.nim#L3)

key source file: [`src/app/browser/view.nim`](https://github.com/status-im/status-desktop/blob/d2b6bf9310df088c89abcca7c1df42abc3999b18/src/app/browser/view.nim#L46)

### with the Star icon

key source file: [`ui/app/AppLayouts/Browser/BrowserHeader.qml`](https://github.com/status-im/status-desktop/blob/17b3a444589725f1723bda8549623e14a0277b2d/ui/app/AppLayouts/Browser/BrowserHeader.qml#L155)

### with the Add favourite button

key source file: [`ui/app/AppLayouts/Browser/FavoritesList.qml`](https://github.com/status-im/status-desktop/blob/d2b6bf9310df088c89abcca7c1df42abc3999b18/ui/app/AppLayouts/Browser/FavoritesList.qml#L39)

key source file: [`ui/app/AppLayouts/Browser/AddFavoriteModal.qml`](https://github.com/status-im/status-desktop/blob/17b3a444589725f1723bda8549623e14a0277b2d/ui/app/AppLayouts/Browser/AddFavoriteModal.qml#L9)

The modal is opened by calling `addFavoriteModal.open()` in `ui/app/AppLayouts/Browser/FavoritesList.qml`

## Displaying favourites

key source file: [`src/status/libstatus/browser.nim`](https://github.com/status-im/status-desktop/blob/d2b6bf9310df088c89abcca7c1df42abc3999b18/src/status/libstatus/browser.nim#L21)

key source file: [`src/app/browser/view.nim`](https://github.com/status-im/status-desktop/blob/d2b6bf9310df088c89abcca7c1df42abc3999b18/src/app/browser/view.nim#L39)

key source file: [`src/app/browser/views/bookmark_list.nim`](https://github.com/status-im/status-desktop/blob/17b3a444589725f1723bda8549623e14a0277b2d/src/app/browser/views/bookmark_list.nim#L5)

### In the Toolbar

key source file: [`ui/app/AppLayouts/Browser/FavoritesBar.qml`](https://github.com/status-im/status-desktop/blob/d2b6bf9310df088c89abcca7c1df42abc3999b18/ui/app/AppLayouts/Browser/FavoritesBar.qml#L12)

### In the blank page

key source file: [`ui/app/AppLayouts/Browser/BrowserLayout.qml`](https://github.com/status-im/status-desktop/blob/d2b6bf9310df088c89abcca7c1df42abc3999b18/ui/app/AppLayouts/Browser/BrowserLayout.qml#L670)

key source file: [`ui/app/AppLayouts/Browser/FavoritesList.qml`](https://github.com/status-im/status-desktop/blob/d2b6bf9310df088c89abcca7c1df42abc3999b18/ui/app/AppLayouts/Browser/FavoritesList.qml#L10)

// todo add how the list is added from the backend

## Editing a favourite

key source file: [`src/status/libstatus/browser.nim`](https://github.com/status-im/status-desktop/blob/d2b6bf9310df088c89abcca7c1df42abc3999b18/src/status/libstatus/browser.nim#L13)

## Removing a favourite

key source file: [`ui/app/AppLayouts/Browser/FavoriteMenu.qml`](https://github.com/status-im/status-desktop/blob/d2b6bf9310df088c89abcca7c1df42abc3999b18/ui/app/AppLayouts/Browser/FavoriteMenu.qml#L53)

key source file: [`ui/app/AppLayouts/Browser/AddFavoriteModal.qml`](https://github.com/status-im/status-desktop/blob/d2b6bf9310df088c89abcca7c1df42abc3999b18/ui/app/AppLayouts/Browser/AddFavoriteModal.qml#L129)

key source file: [`src/app/browser/view.nim`](https://github.com/status-im/status-desktop/blob/d2b6bf9310df088c89abcca7c1df42abc3999b18/src/app/browser/view.nim#L51)

key source file: [`src/status/libstatus/browser.nim`](https://github.com/status-im/status-desktop/blob/d2b6bf9310df088c89abcca7c1df42abc3999b18/src/status/libstatus/browser.nim#L25)

A favourite is removed by calling `browserModel.removeBookmark` from QML, in Nim, an RPC call to the backend is made using `browsers_deleteBookmark` with `url` as the payload

## Loading a favourite

key source file: [`ui/app/AppLayouts/Browser/FavoritesBar.qml`](https://github.com/status-im/status-desktop/blob/d2b6bf9310df088c89abcca7c1df42abc3999b18/ui/app/AppLayouts/Browser/FavoritesBar.qml#L46)

key source file: [`ui/app/AppLayouts/Browser/BrowserLayout.qml`](https://github.com/status-im/status-desktop/blob/d2b6bf9310df088c89abcca7c1df42abc3999b18/ui/app/AppLayouts/Browser/BrowserLayout.qml#L51)

A favourite is loaded by setting `currentWebView.url` to the intended url.

In this case [`ui/app/AppLayouts/Browser/FavoritesBar.qml`](https://github.com/status-im/status-desktop/blob/d2b6bf9310df088c89abcca7c1df42abc3999b18/ui/app/AppLayouts/Browser/FavoritesBar.qml#L46) each delegate has its own `url` property and that is used to set the `currentWebView.url` value after going through the`determineRealURL` helper in case it's a ENS domain etc..

```
currentWebView.url = determineRealURL(url)
```
