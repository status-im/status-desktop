import NimQml, json, strutils, chronicles


import ../settings/service as settings_service
import ../accounts/service as accounts_service

import ../../../app/core/eventemitter

import ../../../backend/eth as status_eth
import ../../../backend/privacy as status_privacy

import ../../common/utils as common_utils

logScope:
  topics = "privacy-service"

# Signals which may be emitted by this service:
const SIGNAL_PASSWORD_CHANGED* = "passwordChanged"

type
  OperationSuccessArgs* = ref object of Args
    success*: bool
    errorMsg*: string

QtObject:
  type Service* = ref object of QObject
    events: EventEmitter
    settingsService: settings_service.Service
    accountsService: accounts_service.Service

  proc delete*(self: Service) =
    self.QObject.delete

  proc newService*(events: EventEmitter, settingsService: settings_service.Service,
    accountsService: accounts_service.Service): Service =
    new(result, delete)
    result.QObject.setup
    result.events = events
    result.settingsService = settingsService
    result.accountsService = accountsService

  proc init*(self: Service) =
    discard

  proc getDefaultAccount(self: Service): string =
    try:
      let response = status_eth.getAccounts()

      if(response.result.kind != JArray):
        error "error: ", procName="getDefaultAccount", errDesription = "response is not an array"
        return

      for acc in response.result:
        # the first account is considered as the default one
        return acc.getStr

      return ""
    except Exception as e:
      error "error: ", procName="getDefaultAccount", errName = e.name, errDesription = e.msg

  proc changePassword*(self: Service, password: string, newPassword: string) =
    try:
      var data = OperationSuccessArgs(success: false, errorMsg: "")

      let defaultAccount = self.getDefaultAccount()
      if(defaultAccount.len == 0):
        error "error: ", procName="changePassword", errDesription = "default eth account is empty"
        self.events.emit(SIGNAL_PASSWORD_CHANGED, data)
        return

      let isPasswordOk = self.accountsService.verifyAccountPassword(defaultAccount, password)
      if not isPasswordOk:
        data.errorMsg = "Incorrect current password"
        error "error: ", procName="changePassword", errDesription = "password cannnot be verified"
        self.events.emit(SIGNAL_PASSWORD_CHANGED, data)
        return

      let loggedInAccount = self.accountsService.getLoggedInAccount()
      let response = status_privacy.changeDatabasePassword(loggedInAccount.keyUid, common_utils.hashPassword(password), common_utils.hashPassword(newPassword))

      if(response.result.contains("error")):
        let errMsg = response.result["error"].getStr
        if(errMsg.len == 0):
          data.success = true
        else:
          error "error: ", procName="changePassword", errDesription = errMsg

      self.events.emit(SIGNAL_PASSWORD_CHANGED, data)

    except Exception as e:
      error "error: ", procName="changePassword", errName = e.name, errDesription = e.msg

  proc isMnemonicBackedUp*(self: Service): bool =
    return self.settingsService.getMnemonic().len == 0

  proc getMnemonic*(self: Service): string =
    return self.settingsService.getMnemonic()

  proc removeMnemonic*(self: Service) =
    var data = OperationSuccessArgs(success: true)
    if(not self.settingsService.saveMnemonic("")):
      data.success = false
      error "error: ", procName="removeMnemonic", errDesription = "an error occurred removing mnemonic"

  proc mnemonicWasShown*(self: Service) =
    self.settingsService.mnemonicWasShown()

  proc getMnemonicWordAtIndex*(self: Service, index: int): string =
    let mnemonic = self.settingsService.getMnemonic()
    if(mnemonic.len == 0):
      let msg = "tyring to get a word on index " & $(index) & " from an empty mnemonic"
      error "error: ", procName="getMnemonicWordAtIndex", errDesription = msg
      return

    let mnemonics = mnemonic.split(" ")
    if(index < 0 or index >= mnemonics.len):
      let msg = "tyring to get a word on index " & $(index) & " but mnemonic contains " & $(mnemonics.len) & " words"
      error "error: ", procName="getMnemonicWordAtIndex", errDesription = msg
      return

    return mnemonics[index]

  proc validatePassword*(self: Service, password: string): bool =
    try:
      let defaultAccount = self.getDefaultAccount()

      if(defaultAccount.len == 0):
        error "error: ", procName="validatePassword", errDesription = "default eth account is empty"
        return false

      let isPasswordOk = self.accountsService.verifyAccountPassword(defaultAccount, password)
      if not isPasswordOk:
        error "error: ", procName="validatePassword", errDesription = "password cannnot be verified"
        return false

      return true
    except Exception as e:
      error "error: ", procName="validatePassword", errName = e.name, errDesription = e.msg
      return false
