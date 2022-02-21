from  ../modules/shared_models/section_item import SectionType

import ../core/eventemitter

export SectionType

type
  ToggleSectionArgs* = ref object of Args
    sectionType*: SectionType

const TOGGLE_SECTION* = "toggleSection"
## Emmiting this signal will turn on section/s with passed `sectionType` if that section type is
## turned off, or turn it off in case that section type is turned on.

type 
  ActiveSectionChatArgs* = ref object of Args
    sectionId*: string
    chatId*: string
    messageId*: string

const SIGNAL_MAKE_SECTION_CHAT_ACTIVE* = "makeSectionChatActive"
## Emmiting this signal will switch the app to passed `sectionId`, after that if `chatId` is set
## it will make that chat an active one and at the end if `messageId` is set it will point to
## that message.