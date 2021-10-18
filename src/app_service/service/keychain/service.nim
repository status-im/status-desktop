import NimQml, chronicles

import eventemitter

logScope:
  topics = "keychain-service"

const ERROR_TYPE_AUTHENTICATION* = "authentication"
const ERROR_TYPE_KEYCHAIN* = "keychain"

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
    self.keychainManager = newStatusKeychainManager("StatusDesktop", "authenticate you")
    signalConnect(self.keychainManager, "success(QString)", self,
    "onKeychainManagerSuccess(QString)", 2)
    signalConnect(self.keychainManager, "error(QString, int, QString)", self,
    "onKeychainManagerError(QString, int, QString)", 2)    

  proc delete*(self: Service) =
    self.keychainManager.delete
    self.QObject.delete

  proc newService*(events: EventEmitter): Service =
    new(result, delete)
    result.setup()
    result.events = events

  proc storePassword*(self: Service, username: string, password: string) =
    self.keychainManager.storeDataAsync(username, password)

  proc tryToObtainPassword*(self: Service, username: string) =
    self.keychainManager.readDataAsync(username)

  proc onKeychainManagerError*(self: Service, errorType: string, errorCode: int, 
    errorDescription: string) {.slot.} =
    ## This slot is called in case an error occured while we're dealing with
    ## KeychainManager. So far we're just logging the error.
    info "KeychainManager stopped: ", msg = errorCode, errorDescription
    
    let arg = KeyChainServiceArg(errCode: errorCode, errType: errorType, 
    errDescription: errorDescription)
    self.events.emit("keychainServiceError", arg)

  proc onKeychainManagerSuccess*(self: Service, data: string) {.slot.} =
    ## This slot is called in case a password is successfully retrieved from the
    ## Keychain. In this case @data contains required password.
    self.events.emit("keychainServiceSuccess", KeyChainServiceArg(data: data))