import tables
import ../../../../../../app_service/service/message/dto/link_preview

type
  LinkPreviewCache* = ref object
    cache: Table[string, LinkPreview]

proc newLinkPreiewCache*(): LinkPreviewCache =
  result = LinkPreviewCache()
  result.cache = initTable[string, LinkPreview]()

# Returns list of link previews for given `urls`
# If url is not found in cache, it's skipped
# TODO: Add an empty LinkPreview for not found url?
proc linkPreviews*(self: LinkPreviewCache, urls: seq[string]): Table[string, LinkPreview] =
  result = initTable[string, LinkPreview]()
  for url in urls:
    if self.cache.hasKey(url):
      result[url] = self.cache[url]

# Adds all given link previews to cache.
# Returns list of urls found in `linkPreviews`
# If a url is already found in cache, correcponding link preview is updated.
# TODO: Return set?
proc add*(self: LinkPreviewCache, linkPreviews: seq[LinkPreview]): seq[string] =
  for linkPreview in linkPreviews:
    result.add(linkPreview.url)
    self.cache[linkPreview.url] = linkPreview

# Goes though given `urls` and returns a list 
# of urls not found in cache.
proc unknownUrls*(self: LinkPreviewCache, urls: seq[string]): seq[string] =
  for url in urls:
    if not self.cache.hasKey(url):
      result.add(url)
      
# Clears link preview cache
proc clear*(self: LinkPreviewCache) =
  self.cache.clear()
