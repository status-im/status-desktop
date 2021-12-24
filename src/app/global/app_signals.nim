from  ../modules/shared_models/section_item import SectionType

import eventemitter

export SectionType

type
  ToggleSectionArgs* = ref object of Args
    sectionType*: SectionType

const TOGGLE_SECTION* = "toggleSection"