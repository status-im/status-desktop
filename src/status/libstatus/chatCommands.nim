import json, chronicles
import core, ../utils

proc acceptRequestAddressForTransaction*(messageId: string, address: string): string =
  result = callPrivateRPC("acceptRequestAddressForTransaction".prefix, %* [messageId, address])

proc declineRequestAddressForTransaction*(messageId: string): string =
  result = callPrivateRPC("declineRequestAddressForTransaction".prefix, %* [messageId])

proc declineRequestTransaction*(messageId: string): string =
  result = callPrivateRPC("declineRequestTransaction".prefix, %* [messageId])

proc requestAddressForTransaction*(chatId: string, fromAddress: string, amount: string, tokenAddress: string): string =
  result = callPrivateRPC("requestAddressForTransaction".prefix, %* [chatId, fromAddress, amount, tokenAddress])

proc requestTransaction*(chatId: string, fromAddress: string, amount: string, tokenAddress: string): string =
  result = callPrivateRPC("requestTransaction".prefix, %* [chatId, amount, tokenAddress, fromAddress])
