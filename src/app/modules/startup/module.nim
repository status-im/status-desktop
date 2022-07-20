import NimQml, chronicles

import io_interface
import view, controller
import internal/[state, notification_state, welcome_state, login_state]
import models/generated_account_item as gen_acc_item
import models/login_account_item as login_acc_item
import ../../global/global_singleton
import ../../core/eventemitter

import ../../../app_service/service/keychain/service as keychain_service
import ../../../app_service/service/accounts/service as accounts_service
import ../../../app_service/service/general/service as general_service
import ../../../app_service/service/profile/service as profile_service

export io_interface

logScope:
  topics = "startup-module"

type
  Module*[T: io_interface.DelegateInterface] = ref object of io_interface.AccessInterface
    delegate: T
    view: View
    viewVariant: QVariant
    controller: Controller

proc newModule*[T](delegate: T,
  events: EventEmitter,
  keychainService: keychain_service.Service,
  accountsService: accounts_service.Service,
  generalService: general_service.Service,
  profileService: profile_service.Service):
  Module[T] =
  result = Module[T]()
  result.delegate = delegate
  result.view = view.newView(result)
  result.viewVariant = newQVariant(result.view)
  result.controller = controller.newController(result, events, generalService, accountsService, keychainService,
  profileService)

method delete*[T](self: Module[T]) =
  self.view.delete
  self.viewVariant.delete
  self.controller.delete

proc extractImages(self: Module, account: AccountDto, thumbnailImage: var string,
  largeImage: var string) =
  for img in account.images:
    if(img.imgType == "thumbnail"):
      thumbnailImage = img.uri
    elif(img.imgType == "large"):
      largeImage = img.uri

method load*[T](self: Module[T]) =
  singletonInstance.engine.setRootContextProperty("startupModule", self.viewVariant)
  self.controller.init()

  let generatedAccounts = self.controller.getGeneratedAccounts()
  var accounts: seq[gen_acc_item.Item]
  for acc in generatedAccounts:
    accounts.add(gen_acc_item.initItem(acc.id, acc.alias, acc.address, acc.derivedAccounts.whisper.publicKey, acc.keyUid))
  self.view.setGeneratedAccountList(accounts)

  if(self.controller.shouldStartWithOnboardingScreen()):
    if defined(macosx):
      self.view.setCurrentStartupState(newNotificationState(FlowType.General, nil))
    else:
      self.view.setCurrentStartupState(newWelcomeState(FlowType.General, nil))
  else:
    let openedAccounts = self.controller.getOpenedAccounts()
    if(openedAccounts.len > 0):
      var items: seq[login_acc_item.Item]
      for acc in openedAccounts:
        var thumbnailImage: string
        var largeImage: string
        self.extractImages(acc, thumbnailImage, largeImage)
        items.add(login_acc_item.initItem(acc.name, thumbnailImage, largeImage, acc.keyUid, acc.colorHash, acc.colorId))
      self.view.setLoginAccountsModelItems(items)
      # set the first account as slected one
      if items.len == 0:
        error "cannot run the app in login flow cause list of login accounts is empty"
        quit() # quit the app
      self.setSelectedLoginAccount(items[0])
    self.view.setCurrentStartupState(newLoginState(FlowType.AppLogin, nil))
  self.delegate.startupDidLoad()

method moveToAppState*[T](self: Module[T]) =
  self.view.setAppState(AppState.MainAppState)

method startUpUIRaised*[T](self: Module[T]) =
  self.view.startUpUIRaised()

method emitLogOut*[T](self: Module[T]) =
  self.view.emitLogOut()

method onBackActionClicked*[T](self: Module[T]) =
  let currStateObj = self.view.currentStartupStateObj()
  if not currStateObj.isNil:
    currStateObj.executeBackCommand(self.controller)
    let backState = currStateObj.getBackState()
    self.view.setCurrentStartupState(backState)
    currStateObj.delete()    
    
method onPrimaryActionClicked*[T](self: Module[T]) =
  let currStateObj = self.view.currentStartupStateObj()
  if not currStateObj.isNil:
    currStateObj.executePrimaryCommand(self.controller)
    if currStateObj.moveToNextPrimaryState():
      let nextState = currStateObj.getNextPrimaryState()
      self.view.setCurrentStartupState(nextState)

method onSecondaryActionClicked*[T](self: Module[T]) =
  let currStateObj = self.view.currentStartupStateObj()
  if not currStateObj.isNil:
    currStateObj.executeSecondaryCommand(self.controller)
    if currStateObj.moveToNextSecondaryState():
      let nextState = currStateObj.getNextSecondaryState()
      self.view.setCurrentStartupState(nextState)

method onTertiaryActionClicked*[T](self: Module[T]) =
  let currStateObj = self.view.currentStartupStateObj()
  if not currStateObj.isNil:
    currStateObj.executeTertiaryCommand(self.controller)
    if currStateObj.moveToNextTertiaryState():
      let nextState = currStateObj.getNextTertiaryState()
      self.view.setCurrentStartupState(nextState)

method getImportedAccount*[T](self: Module[T]): GeneratedAccountDto =
  return self.controller.getImportedAccount()

method generateImage*[T](self: Module[T], imageUrl: string, aX: int, aY: int, bX: int, bY: int): string =
  return self.controller.generateImage(imageUrl, aX, aY, bX, bY)

method setDisplayName*[T](self: Module[T], value: string) =
  self.controller.setDisplayName(value)

method getDisplayName*[T](self: Module[T]): string =
  return self.controller.getDisplayName()

method setPassword*[T](self: Module[T], value: string) =
  self.controller.setPassword(value)

method getPassword*[T](self: Module[T]): string =
  return self.controller.getPassword()

method getPasswordStrengthScore*[T](self: Module[T], password, userName: string): int =
  return self.controller.getPasswordStrengthScore(password, userName)

method setupAccountError*[T](self: Module[T], error: string) =
  self.view.setupAccountError(error)

method validMnemonic*[T](self: Module[T], mnemonic: string): bool =
  return self.controller.validMnemonic(mnemonic)

method importAccountError*[T](self: Module[T], error: string) =
  self.view.importAccountError(error)

method importAccountSuccess*[T](self: Module[T]) =
  self.view.importAccountSuccess()

method setSelectedLoginAccount*[T](self: Module[T], item: login_acc_item.Item) =
  self.controller.setSelectedLoginAccountKeyUid(item.getKeyUid())
  self.view.setSelectedLoginAccount(item)

method emitAccountLoginError*[T](self: Module[T], error: string) =
  self.view.emitAccountLoginError(error)

method emitObtainingPasswordError*[T](self: Module[T], errorDescription: string) =
  self.view.emitObtainingPasswordError(errorDescription)

method emitObtainingPasswordSuccess*[T](self: Module[T], password: string) =
  self.view.emitObtainingPasswordSuccess(password)

method onNodeLogin*[T](self: Module[T], error: string) =
  let currStateObj = self.view.currentStartupStateObj()
  if currStateObj.isNil:
    error "error: cannot determine current startup state"
    quit() # quit the app

  if error.len == 0:
    self.delegate.userLoggedIn()
    if currStateObj.flowType() != FlowType.AppLogin:
      self.controller.storeIdentityImage()
  else:
    if currStateObj.flowType() == FlowType.AppLogin:
      self.emitAccountLoginError(error)
    else:
      self.setupAccountError(error)
    error "error: ", methodName="onNodeLogin", errDesription =error