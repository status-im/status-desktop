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

  proc idChanged*(self: SectionDetails) {.signal.}
  proc getId*(self: SectionDetails): string {.slot.} =
    return self.id

  QtProperty[string] id:
    read = getId
    notify = idChanged

  proc sectionTypeChanged*(self: SectionDetails) {.signal.}
  proc getSectionType(self: SectionDetails): int {.slot.} =
    return self.sectionType.int

  QtProperty[int] sectionType:
    read = getSectionType
    notify = sectionTypeChanged

  proc joinedChanged*(self: SectionDetails) {.signal.}
  proc getJoined(self: SectionDetails): bool {.slot.} =
    return self.joined

  QtProperty[bool] joined:
    read = getJoined
    notify = joinedChanged

  proc setActiveSectionData*(self: SectionDetails, item: SectionItem) =
    if self.joined != item.joined:
      self.joined = item.joined
      self.joinedChanged()

    if self.id != item.id:
      self.id = item.id
      self.idChanged()

    if self.sectionType != item.sectionType:
      self.sectionType = item.sectionType
      self.sectionTypeChanged()
