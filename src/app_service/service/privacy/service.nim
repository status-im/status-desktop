import NimQml, json, strutils, chronicles

import ../settings/service_interface as settings_service
import ../accounts/service_interface as accounts_service

import ../../../app/core/eventemitter

import status/statusgo_backend_new/accounts as status_account
import status/statusgo_backend_new/eth as status_eth
import status/statusgo_backend_new/privacy as status_privacy

logScope:
  topics = "privacy-service"

# Signals which may be emitted by this service:
const SIGNAL_MNEMONIC_REMOVAL* = "menmonicRemoval"
const SIGNAL_PASSWORD_CHANGED* = "passwordChanged"

type
  OperationSuccessArgs* = ref object of Args
    success*: bool
    
QtObject:
  type Service* = ref object of QObject
    events: EventEmitter
    settingsService: settings_service.ServiceInterface
    accountsService: accounts_service.ServiceInterface

  proc delete*(self: Service) =
    self.QObject.delete

  proc newService*(events: EventEmitter, settingsService: settings_service.ServiceInterface,
    accountsService: accounts_service.ServiceInterface): Service =
    new(result, delete)
    result.QObject.setup
    result.events = events
    result.settingsService = settingsService
    result.accountsService = accountsService

  proc init*(self: Service) =
    discard

  proc getLinkPreviewWhitelist*(self: Service): string =
    try:
      let response = status_privacy.getLinkPreviewWhitelist()
      
      if(response.result.kind != JArray):
        var errMsg = "response is not an array"
        if(response.result.contains("error")):
          errMsg = response.result["error"].getStr
        error "error: ", methodName="getLinkPreviewWhitelist", errDesription = errMsg
        return

      return $(response.result)
    except Exception as e:
      error "error: ", methodName="removeReaction", errName = e.name, errDesription = e.msg

  proc getDefaultAccount(self: Service): string =
    try:
      let response = status_eth.getEthAccounts()

      if(response.result.kind != JArray):
        error "error: ", methodName="getDefaultAccount", errDesription = "response is not an array"
        return
      
      for acc in response.result:
        # the first account is considered as the default one
        return acc.getStr
      
      return ""
    except Exception as e:
      error "error: ", methodName="getDefaultAccount", errName = e.name, errDesription = e.msg

  proc changePassword*(self: Service, password: string, newPassword: string) =
    try:
      var data = OperationSuccessArgs(success: false)

      let defaultAccount = self.getDefaultAccount()
      if(defaultAccount.len == 0):
        error "error: ", methodName="changePassword", errDesription = "default eth account is empty"
        self.events.emit(SIGNAL_PASSWORD_CHANGED, data)
        return

      let isPasswordOk = self.accountsService.verifyAccountPassword(defaultAccount, password)
      if not isPasswordOk:
        error "error: ", methodName="changePassword", errDesription = "password cannnot be verified"
        self.events.emit(SIGNAL_PASSWORD_CHANGED, data)
        return

      let loggedInAccount = self.accountsService.getLoggedInAccount()
      let response = status_privacy.changeDatabasePassword(loggedInAccount.keyUid, password, newPassword)

      if(response.result.contains("error")):
        let errMsg = response.result["error"].getStr
        if(errMsg.len == 0):
          data.success = true
        else:
          error "error: ", methodName="changePassword", errDesription = errMsg

      self.events.emit(SIGNAL_PASSWORD_CHANGED, data)

    except Exception as e:
      error "error: ", methodName="changePassword", errName = e.name, errDesription = e.msg

  proc isMnemonicBackedUp*(self: Service): bool =
    return self.settingsService.getMnemonic().len == 0

  proc getMnemonic*(self: Service): string =
    return self.settingsService.getMnemonic()

  proc removeMnemonic*(self: Service) =
    var data = OperationSuccessArgs(success: true)
    if(not self.settingsService.saveMnemonic("")):
      data.success = false
      error "error: ", methodName="removeMnemonic", errDesription = "an error occurred removing mnemonic"

    self.events.emit(SIGNAL_MNEMONIC_REMOVAL, data)

  proc getMnemonicWordAtIndex*(self: Service, index: int): string =
    let mnemonic = self.settingsService.getMnemonic()
    if(mnemonic.len == 0):
      let msg = "tyring to get a word on index " & $(index) & " from an empty mnemonic"
      error "error: ", methodName="getMnemonicWordAtIndex", errDesription = msg
      return

    let mnemonics = mnemonic.split(" ")
    if(index < 0 or index >= mnemonics.len):
      let msg = "tyring to get a word on index " & $(index) & " but mnemonic contains " & $(mnemonics.len) & " words"
      error "error: ", methodName="getMnemonicWordAtIndex", errDesription = msg
      return

    return mnemonics[index]