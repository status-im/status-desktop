import json, chronicles
import core, utils

proc acceptRequestAddressForTransaction*(messageId: string, address: string): string =
  result = callPrivateRPC("acceptRequestAddressForTransaction".prefix, %* [messageId, address])

proc declineRequestAddressForTransaction*(messageId: string): string =
  result = callPrivateRPC("declineRequestAddressForTransaction".prefix, %* [messageId])

proc declineRequestTransaction*(messageId: string): string =
  result = callPrivateRPC("declineRequestTransaction".prefix, %* [messageId])
