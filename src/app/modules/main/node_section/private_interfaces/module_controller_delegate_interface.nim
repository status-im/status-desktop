import ../../../../core/signals/types

method setPeerSize*(self: AccessInterface, peerSize: int) {.base.} =
  raise newException(ValueError, "No implementation available") 

method setLastMessage*(self: AccessInterface, lastMessage: string) {.base.} =
  raise newException(ValueError, "No implementation available") 

method setStats*(self: AccessInterface, stats: Stats) {.base.} =
  raise newException(ValueError, "No implementation available") 

method log*(self: AccessInterface, logContent: string) {.base.} =
  raise newException(ValueError, "No implementation available") 

method setBitsSet*(self: AccessInterface, bitsSet: int) {.base.} =
  raise newException(ValueError, "No implementation available") 
