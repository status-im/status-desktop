import json

import libstatus/browser as status_browser
import ../eventemitter

#TODO: temporary?
import types as LibStatusTypes

type
    BrowserModel* = ref object
        events*: EventEmitter

proc newBrowserModel*(events: EventEmitter): BrowserModel =
  result = BrowserModel()
  result.events = events

proc storeBookmark*(self: BrowserModel, url: string, name: string): Bookmark =
  result = status_browser.storeBookmark(url, name)

proc updateBookmark*(self: BrowserModel, ogUrl: string, url: string, name: string) =
  status_browser.updateBookmark(ogUrl, url, name)

proc getBookmarks*(self: BrowserModel): string =
  result = status_browser.getBookmarks()

proc deleteBookmark*(self: BrowserModel, url: string) =
  status_browser.deleteBookmark(url)
