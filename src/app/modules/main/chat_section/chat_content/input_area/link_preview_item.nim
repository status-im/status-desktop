import strformat
import ../../../../../../app_service/service/message/dto/link_preview

type
  Item* = ref object
    unfurled*: bool
    linkPreview*: LinkPreview

proc delete*(self: Item) =
  self.linkPreview.delete

proc linkPreview*(self: Item): LinkPreview {.inline.} =
  return self.linkPreview

proc `linkPreview=`*(self: Item, linkPreview: LinkPreview) {.inline.} =
  self.linkPreview = linkPreview

proc `$`*(self: Item): string =
  result = fmt"""LinkPreviewItem(
    unfurled: {self.unfurled},
    linkPreview: {self.linkPreview},
  )"""
