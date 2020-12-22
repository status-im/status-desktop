import core, types, json, chronicles

proc storeBookmark*(url: string, name: string): Bookmark =
  let payload = %* [{"url": url, "name": name}]
  result = Bookmark(name: name, url: url)
  try:
    let resp = callPrivateRPC("browsers_storeBookmark", payload).parseJson["result"]
    result.imageUrl = resp["imageUrl"].getStr
  except Exception as e:
    error "Error updating bookmark", msg = e.msg
    discard

proc updateBookmark*(ogUrl: string, url: string, name: string) =
  let payload = %* [ogUrl, {"url": url, "name": name}]
  try:
    discard callPrivateRPC("browsers_updateBookmark", payload)
  except Exception as e:
    error "Error updating bookmark", msg = e.msg
    discard

proc getBookmarks*(): string =
  let payload = %* []
  result = callPrivateRPC("browsers_getBookmarks", payload)

proc deleteBookmark*(url: string) =
  let payload = %* [url]
  discard callPrivateRPC("browsers_deleteBookmark", payload)
