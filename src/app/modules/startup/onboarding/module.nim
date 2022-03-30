import NimQml
import io_interface
import ../io_interface as delegate_interface
import view, controller, item
import ../../../global/global_singleton
import ../../../core/eventemitter
import ../../../../app_service/service/accounts/service as accounts_service
import ../../../../app_service/service/general/service as general_service

export io_interface

type
  Module* = ref object of io_interface.AccessInterface
    delegate: delegate_interface.AccessInterface
    view: View
    viewVariant: QVariant
    controller: Controller
    moduleLoaded: bool

proc newModule*(delegate: delegate_interface.AccessInterface, events: EventEmitter,
  accountsService: accounts_service.Service,
  generalService: general_service.Service):
  Module =
  result = Module()
  result.delegate = delegate
  result.view = view.newView(result)
  result.viewVariant = newQVariant(result.view)
  result.controller = controller.newController(result, events, accountsService, generalService)
  result.moduleLoaded = false

method delete*(self: Module) =
  self.view.delete
  self.viewVariant.delete
  self.controller.delete

method load*(self: Module) =
  singletonInstance.engine.setRootContextProperty("onboardingModule", self.viewVariant)
  self.controller.init()
  self.view.load()

  let generatedAccounts = self.controller.getGeneratedAccounts()
  var accounts: seq[Item]
  for acc in generatedAccounts:
    accounts.add(initItem(acc.id, acc.alias, acc.address, acc.derivedAccounts.whisper.publicKey, acc.keyUid))

  self.view.setAccountList(accounts)

method isLoaded*(self: Module): bool =
  return self.moduleLoaded

method viewDidLoad*(self: Module) =
  self.moduleLoaded = true
  self.delegate.onboardingDidLoad()

method setSelectedAccountByIndex*(self: Module, index: int) =
  self.controller.setSelectedAccountByIndex(index)

method setDisplayName*(self: Module, displayName: string) =
  self.controller.setDisplayName(displayName)

method storeSelectedAccountAndLogin*(self: Module, password: string) =
  self.controller.storeSelectedAccountAndLogin(password)

method setupAccountError*(self: Module, error: string) =
  self.view.setupAccountError(error)

method getImportedAccount*(self: Module): GeneratedAccountDto =
  return self.controller.getImportedAccount()

method validateMnemonic*(self: Module, mnemonic: string): string =
  return self.controller.validateMnemonic(mnemonic)

method importMnemonic*(self: Module, mnemonic: string) =
  self.controller.importMnemonic(mnemonic)

method importAccountError*(self: Module, error: string) =
  self.view.importAccountError(error)

method importAccountSuccess*(self: Module) =
  self.view.importAccountSuccess()

method getPasswordStrengthScore*(self: Module, password, userName: string): int =
  return self.controller.getPasswordStrengthScore(password, userName)
