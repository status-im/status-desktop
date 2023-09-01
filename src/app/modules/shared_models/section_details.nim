import NimQml
import section_item

QtObject:
  type SectionDetails* = ref object of QObject
    id: string
    sectionType: SectionType
    joined: bool

  proc setup(self: SectionDetails) =
    self.QObject.setup

  proc delete*(self: SectionDetails) =
    self.QObject.delete

  proc newActiveSection*(): SectionDetails =
    new(result, delete)
    result.setup

  proc setActiveSectionData*(self: SectionDetails, item: SectionItem) =
    self.id = item.id
    self.sectionType = item.sectionType
    self.joined = item.joined

  proc getId*(self: SectionDetails): string {.slot.} =
    return self.id

  QtProperty[string] id:
    read = getId

  proc getSectionType(self: SectionDetails): int {.slot.} =
    return self.sectionType.int

  QtProperty[int] sectionType:
    read = getSectionType

  proc getJoined(self: SectionDetails): bool {.slot.} =
    return self.joined

  QtProperty[bool] joined:
    read = getJoined