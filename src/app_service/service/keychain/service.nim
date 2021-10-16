import NimQml, chronicles
#Tables, json, sequtils, strutils, strformat, uuids
#import json_serialization, 

import ../local_settings/service as local_settings_service

import eventemitter

logScope:
  topics = "keychain-service"

# Local Account Settings keys:
const LS_KEY_STORE_TO_KEYCHAIN* = "storeToKeychain"
# Local Account Settings values:
const LS_VALUE_STORE* = "store"

const ERROR_TYPE_AUTHENTICATION = "authentication"
const ERROR_TYPE_KEYCHAIN = "keychain"

type
  KeyChainServiceArg* = ref object of Args
    data*: string
    errCode: int
    errType: string
    errDescription: string

QtObject:
  type Service* = ref object of QObject
    localSettingsService: local_settings_service.Service
    events: EventEmitter
    keychainManager: StatusKeychainManager

  proc setup(self: Service) =
    self.QObject.setup
    self.keychainManager = newStatusKeychainManager("StatusDesktop", "authenticate you")
    signalConnect(self.keychainManager, "success(QString)", self,
    "onKeychainManagerSuccess(QString)", 2)
    signalConnect(self.keychainManager, "error(QString, int, QString)", self,
    "onKeychainManagerError(QString, int, QString)", 2)    

  proc delete*(self: Service) =
    self.keychainManager.delete
    self.QObject.delete

  proc newService*(localSettingsService: local_settings_service.Service,
    events: EventEmitter): 
    Service =
    new(result, delete)
    result.setup()
    result.localSettingsService = localSettingsService
    result.events = events

  proc storePassword*(self: Service, username: string, password: string) =
    let value = self.localSettingsService.getAccountValue(
      LS_KEY_STORE_TO_KEYCHAIN).stringVal
    
    if (value != LS_VALUE_STORE or username.len == 0):
      return

    self.keychainManager.storeDataAsync(username, password)

  proc tryToObtainPassword*(self: Service, username: string) =
    let value = self.localSettingsService.getAccountValue(
      LS_KEY_STORE_TO_KEYCHAIN).stringVal
    
    if (value != LS_VALUE_STORE):
      return
      
    self.keychainManager.readDataAsync(username)

  proc onKeychainManagerError*(self: Service, errorType: string, errorCode: int, 
    errorDescription: string) {.slot.} =
    ## This slot is called in case an error occured while we're dealing with
    ## KeychainManager. So far we're just logging the error.
    info "KeychainManager stopped: ", msg = errorCode, errorDescription
    if (errorType == ERROR_TYPE_AUTHENTICATION):
      return

    # We are notifying user only about keychain errors.
    self.localSettingsService.removeAccountValue(LS_KEY_STORE_TO_KEYCHAIN)
    let arg = KeyChainServiceArg(errCode: errorCode, errType: errorType, 
    errDescription: errorDescription)
    self.events.emit("obtainingPasswordError", arg)

  proc onKeychainManagerSuccess*(self: Service, data: string) {.slot.} =
    ## This slot is called in case a password is successfully retrieved from the
    ## Keychain. In this case @data contains required password.
    self.events.emit("obtainingPasswordSuccess", KeyChainServiceArg(data: data))