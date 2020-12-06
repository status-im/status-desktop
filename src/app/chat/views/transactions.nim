import NimQml, chronicles
import ../../../status/status

logScope:
  topics = "transactions-view"

QtObject:
  type TransactionsView* = ref object of QObject
    status: Status

  proc setup(self: TransactionsView) =
    self.QObject.setup

  proc delete*(self: TransactionsView) =
    self.QObject.delete

  proc newTransactionsView*(status: Status): TransactionsView =
    new(result, delete)
    result = TransactionsView()
    result.status = status
    result.setup

  proc acceptAddressRequest*(self: TransactionsView, messageId: string , address: string) {.slot.} =
    self.status.chat.acceptRequestAddressForTransaction(messageId, address)

  proc declineAddressRequest*(self: TransactionsView, messageId: string) {.slot.} =
    self.status.chat.declineRequestAddressForTransaction(messageId)

  proc requestAddress*(self: TransactionsView, chatId: string, fromAddress: string, amount: string, tokenAddress: string) {.slot.} =
    self.status.chat.requestAddressForTransaction(chatId, fromAddress, amount, tokenAddress)

  proc request*(self: TransactionsView, chatId: string, fromAddress: string, amount: string, tokenAddress: string) {.slot.} =
    self.status.chat.requestTransaction(chatId, fromAddress, amount, tokenAddress)

  proc declineRequest*(self: TransactionsView, messageId: string) {.slot.} =
    self.status.chat.declineRequestTransaction(messageId)
