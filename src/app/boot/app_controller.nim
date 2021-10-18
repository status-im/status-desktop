import NimQml

import ../../app_service/service/contacts/service as contact_service
import ../../app_service/service/chat/service as chat_service
import ../../app_service/service/community/service as community_service
import ../modules/startup/module as startup_module
import ../modules/main/module as main_module

import global_singleton

# This will be removed later:
import status/status
import ../../app_service/[main]
# This to will be adapted to appropriate modules later:
import ../onboarding/core as onboarding
import ../login/core as login
import status/types/[account]

type 
  AppController* = ref object of RootObj 
    # Services
    contactService: contact_service.Service
    chatService: chat_service.Service
    communityService: community_service.Service
    # Modules
    startupModule: startup_module.AccessInterface
    mainModule: main_module.AccessInterface

    # This to will be adapted to appropriate modules later:
    status: Status
    appService: AppService
    login: LoginController
    onboarding: OnboardingController
    accountArgs: AccountArgs

#################################################
# Forward declaration section
proc load*(self: AppController)

# Startup Module Delegate Interface
proc startupDidLoad*(self: AppController)

# Main Module Delegate Interface
proc mainDidLoad*(self: AppController)
#################################################

proc connect(self: AppController) =
  self.status.events.once("login") do(a: Args):
    self.accountArgs = AccountArgs(a)
    self.load()
  self.status.events.once("nodeStopped") do(a: Args):
    self.login.reset()
    self.onboarding.reset()

proc newAppController*(status: Status, appService: AppService): AppController =
  result = AppController()
  # Services
  result.contactService = contact_service.newService()
  result.chatService = chat_service.newService()
  result.communityService = community_service.newService(result.chatService)
  # Modules
  result.startupModule = startup_module.newModule[AppController](result)
  result.mainModule = main_module.newModule[AppController](result, result.chatService,
  result.communityService)

  # Adding status and appService here now is just because of having a controll 
  # over order of execution while we integrating this refactoring architecture 
  # into the current app state.
  # Once we complete refactoring process we will get rid of "status" part/lib.
  #
  # This to will be adapted to appropriate modules later:
  result.status = status
  result.appService = appService
  result.login = login.newController(status, appService)
  result.onboarding = onboarding.newController(status)
  singletonInstance.engine.setRootContextProperty("loginModel", result.login.variant)
  singletonInstance.engine.setRootContextProperty("onboardingModel", result.onboarding.variant)
  result.connect()

proc delete*(self: AppController) =
  self.startupModule.delete
  self.mainModule.delete
  self.login.delete
  self.onboarding.delete

proc startupDidLoad*(self: AppController) =
  discard

proc mainDidLoad*(self: AppController) =
  # This to will be adapted to appropriate modules later:
  self.appService.onLoggedIn()

  # Reset login and onboarding to remove any mnemonic that would have been saved in the accounts list
  self.login.reset()
  self.onboarding.reset()

  self.login.moveToAppState()
  self.onboarding.moveToAppState()
  self.status.events.emit("loginCompleted", self.accountArgs)

proc start*(self: AppController) =
  self.login.init()
  self.onboarding.init()

proc load*(self: AppController) =
  self.contactService.init()
  self.chatService.init()
  self.communityService.init()
  
  self.startupModule.load()
  self.mainModule.load()