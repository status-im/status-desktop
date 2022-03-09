import ./dto as dto
export dto

type
  ServiceInterface* {.pure inheritable.} = ref object of RootObj
  ## Abstract class for this service access.

method delete*(self: ServiceInterface) {.base.} =
  raise newException(ValueError, "No implementation available")

method emojiHashOf*(self: ServiceInterface, pubkey: string): EmojiHashDto {.base.} =
  raise newException(ValueError, "No implementation available")

method colorHashOf*(self: ServiceInterface, pubkey: string): ColorHashDto {.base.} =
  raise newException(ValueError, "No implementation available")
