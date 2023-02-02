import NimQml, chronicles

import ../../../app/core/eventemitter

logScope:
  topics = "keychain-service"

const ERROR_TYPE_AUTHENTICATION* = "authentication"
const ERROR_TYPE_KEYCHAIN* = "keychain"

const SIGNAL_KEYCHAIN_SERVICE_SUCCESS* = "keychainServiceSuccess"
const SIGNAL_KEYCHAIN_SERVICE_ERROR* = "keychainServiceError"

type
  KeyChainServiceArg* = ref object of Args
    data*: string
    errCode*: int
    errType*: string
    errDescription*: string

QtObject:
  type Service* = ref object of QObject
    events: EventEmitter
    keychainManager: StatusKeychainManager

  proc setup(self: Service) =
    self.QObject.setup

  proc delete*(self: Service) =
    self.keychainManager.delete
    self.QObject.delete

  proc newService*(events: EventEmitter): Service =
    new(result, delete)
    result.setup()
    result.events = events
    result.keychainManager = newStatusKeychainManager("StatusDesktop", "authenticate you")

  proc init*(self: Service) =
    signalConnect(self.keychainManager, "success(QString)", self,
    "onKeychainManagerSuccess(QString)", 2)
    signalConnect(self.keychainManager, "error(QString, int, QString)", self,
    "onKeychainManagerError(QString, int, QString)", 2)

  proc storeData*(self: Service, key: string, data: string) =
    self.keychainManager.storeDataAsync(key, data)
 
  proc tryToObtainData*(self: Service, key: string) =
    self.keychainManager.readDataAsync(key)

  proc tryToDeleteData*(self: Service, key: string) =
    self.keychainManager.deleteDataAsync(key)

  proc onKeychainManagerError*(self: Service, errorType: string, errorCode: int,
    errorDescription: string) {.slot.} =
    ## This slot is called in case an error occured while we're dealing with
    ## KeychainManager. So far we're just logging the error.
    info "KeychainManager stopped: ", errCode=errorCode, errType=errorType, errDesc=errorDescription

    let arg = KeyChainServiceArg(errCode: errorCode, errType: errorType,
    errDescription: errorDescription)
    self.events.emit(SIGNAL_KEYCHAIN_SERVICE_ERROR, arg)

  proc onKeychainManagerSuccess*(self: Service, data: string) {.slot.} =
    ## This slot is called in case a password is successfully retrieved from the
    ## Keychain. In this case @data contains required password.
    self.events.emit(SIGNAL_KEYCHAIN_SERVICE_SUCCESS, KeyChainServiceArg(data: data))
