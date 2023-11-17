import tables, sets
import ../../../../../../app_service/service/message/dto/link_preview

type
  LinkPreviewCache* = ref object
    cache: Table[string, LinkPreview]
    requests: HashSet[string]

proc newLinkPreiewCache*(): LinkPreviewCache =
  result = LinkPreviewCache()
  result.cache = initTable[string, LinkPreview]()
  result.requests = initHashSet[string]()

# Returns a table of link previews for given `urls`.
# If url is not found in cache, it's skipped
proc linkPreviews*(self: LinkPreviewCache, urls: seq[string]): Table[string, LinkPreview] =
  result = initTable[string, LinkPreview]()
  for url in urls:
    if self.cache.hasKey(url):
      result[url] = self.cache[url]

# Returns list of link previews for given `urls`.
# If url is not found in cache, it's skipped
proc linkPreviewsSeq*(self: LinkPreviewCache, urls: seq[string]): seq[LinkPreview] =
  for url in urls:
    if self.cache.hasKey(url):
      result.add(self.cache[url])

# Adds all given link previews to cache.
# Returns list of urls, for which link preview was updated.
# If a url is already found in cache, correcponding link preview is updated.
proc add*(self: LinkPreviewCache, linkPreviews: Table[string, LinkPreview]): seq[string] =
  for key, value in pairs(linkPreviews):
    result.add(key)
    self.cache[key] = value
    self.requests.excl(key)

# Marks the URL as requested.
# This should be used to avoid duplicating unfurl requests.
proc markAsRequested*(self: LinkPreviewCache, urls: seq[string]) =
  for url in urls:
    self.requests.incl(url)

# Goes though given `urls` and returns a list 
# of urls not found in cache.
proc unknownUrls*(self: LinkPreviewCache, urls: seq[string]): seq[string] =
  for url in urls:
    if not self.cache.hasKey(url) and not self.requests.contains(url):
      result.add(url)
      
# Clears link preview cache
proc clear*(self: LinkPreviewCache) =
  self.cache.clear()
  self.requests.clear()
