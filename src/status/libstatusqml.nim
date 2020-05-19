import NimQml
import libstatus
import utils

QtObject:
  type 
    LibStatusQml* = ref object of QObject


  # ¯\_(ツ)_/¯ dunno what is this
  proc setup(self: LibStatusQml) =
    self.QObject.setup
  
   # ¯\_(ツ)_/¯ seems to be a method for garbage collection
  proc delete*(self: LibStatusQml) =
    self.QObject.delete

  # Constructor
  proc newLibStatusQml*(): LibStatusQml =
    new(result, delete)
    result.setup

  proc hashMessage*(self: LibStatusQml, p0: string): string {.slot.} =
    return $libstatus.hashMessage(p0)

  proc initKeystore*(self: LibStatusQml, keydir: string): string {.slot.} =
    return $libstatus.initKeystore(keydir)

  proc openAccounts*(self: LibStatusQml, datadir: string): string {.slot.} =
    return $libstatus.openAccounts(datadir)

  proc multiAccountGenerateAndDeriveAddresses*(self: LibStatusQml, paramsJSON: string): string {.slot.} =
    return $libstatus.multiAccountGenerateAndDeriveAddresses(paramsJSON)

  proc multiAccountStoreDerivedAccounts*(self: LibStatusQml, paramsJSON: string): string {.slot.} =
    return $libstatus.multiAccountStoreDerivedAccounts(paramsJSON)

  proc saveAccountAndLogin*(self: LibStatusQml, accountData: string, password: string, settingsJSON: string, configJSON: string, subaccountData: string): string {.slot.} =
    return $libstatus.saveAccountAndLogin(accountData, password, settingsJSON, configJSON, subaccountData)

  proc callRPC*(self: LibStatusQml, inputJSON: string): string {.slot.} =
    return $libstatus.callRPC(inputJSON)

  proc callPrivateRPC*(self: LibStatusQml, inputJSON: string): string {.slot.} =
    return $libstatus.callPrivateRPC(inputJSON)

  proc addPeer*(self: LibStatusQml, peer: string): string {.slot.} =
    return $libstatus.addPeer(peer)
  
  proc generateAlias*(self: LibStatusQml, p0: string): string {.slot.} =
    return $libstatus.generateAlias(p0.toGoString)