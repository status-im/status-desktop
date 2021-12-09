import NimQml
import model
import io_interface

QtObject:
  type
    View* = ref object of QObject
      delegate: io_interface.AccessInterface
      model: Model
      
  proc delete*(self: View) =
    self.model.delete
    self.QObject.delete

  proc newView*(delegate: io_interface.AccessInterface): View =
    new(result, delete)
    result.QObject.setup
    result.delegate = delegate
    result.model = newModel()

  proc load*(self: View) =
    self.delegate.viewDidLoad()
  
  proc sendImages*(self: View, sendImages: string): string {.slot.} =
    self.delegate.sendImages(sendImages)

  proc acceptAddressRequest*(self: View, messageId: string , address: string) {.slot.} =
    self.delegate.acceptRequestAddressForTransaction(messageId, address)

  proc declineAddressRequest*(self: View, messageId: string) {.slot.} =
    self.delegate.declineRequestAddressForTransaction(messageId)

  proc requestAddress*(self: View, chatId: string, fromAddress: string, amount: string, tokenAddress: string) {.slot.} =
    self.delegate.requestAddressForTransaction(chatId, fromAddress, amount, tokenAddress)

  proc request*(self: View, chatId: string, fromAddress: string, amount: string, tokenAddress: string) {.slot.} =
    self.delegate.requestTransaction(chatId, fromAddress, amount, tokenAddress)

  proc declineRequest*(self: View, messageId: string) {.slot.} =
    self.delegate.declineRequestTransaction(messageId)
  
  proc acceptRequestTransaction*(self: View, transactionHash: string, messageId: string, signature: string) {.slot.} =
    self.delegate.acceptRequestTransaction(transactionHash, messageId, signature)
    