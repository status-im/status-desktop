import ../../../../../app_service/service/message/dto/message

method onSearchMessagesDone*(self: AccessInterface, messages: seq[MessageDto]) {.base.} =
  raise newException(ValueError, "No implementation available")