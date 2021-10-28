import NimQml

import ../../app_service/service/accounts/service as accounts_service
import ../../app_service/service/contacts/service as contact_service
import ../../app_service/service/chat/service as chat_service
import ../../app_service/service/community/service as community_service
import ../modules/startup/module as startup_module
import ../modules/main/module as main_module

import global_singleton

# This will be removed later once we move to c++ and handle there async things
# and improved some services, like EventsService which should implement 
# provider/subscriber principe:
import ../../app_service/[main]

# This to will be adapted to appropriate modules later:
# import ../onboarding/core as onboarding
# import ../login/core as login
# import status/types/[account]

type 
  AppController* = ref object of RootObj 
    appService: AppService
    # Services
    accountsService: accounts_service.Service
    contactService: contact_service.Service
    chatService: chat_service.Service
    communityService: community_service.Service
    # Modules
    startupModule: startup_module.AccessInterface
    mainModule: main_module.AccessInterface

    # This to will be adapted to appropriate modules later:
    # login: LoginController
    # onboarding: OnboardingController
    # accountArgs: AccountArgs

#################################################
# Forward declaration section
proc load*(self: AppController)

# Startup Module Delegate Interface
proc startupDidLoad*(self: AppController)
proc userLoggedIn*(self: AppController)

# Main Module Delegate Interface
proc mainDidLoad*(self: AppController)
#################################################

# proc connect(self: AppController) =
  # self.appService.status.events.once("login") do(a: Args):
  #   self.accountArgs = AccountArgs(a)
  #   self.load()
  
  # self.appService.status.events.once("nodeStopped") do(a: Args):
  #   self.login.reset()
  #   self.onboarding.reset()

proc newAppController*(appService: AppService): AppController =
  result = AppController()
  result.appService = appService
  # Services
  result.accountsService = accounts_service.newService()
  result.contactService = contact_service.newService()
  result.chatService = chat_service.newService()
  result.communityService = community_service.newService(result.chatService)
  # Modules
  result.startupModule = startup_module.newModule[AppController](result, appService,
  result.accountsService)
  result.mainModule = main_module.newModule[AppController](result, result.chatService,
  result.communityService)

  # Adding status and appService here now is just because of having a controll 
  # over order of execution while we integrating this refactoring architecture 
  # into the current app state.
  # Once we complete refactoring process we will get rid of "status" part/lib.
  #
  # This to will be adapted to appropriate modules later:
  # result.login = login.newController(appService.status, appService)
  # result.onboarding = onboarding.newController(appService.status)
  # singletonInstance.engine.setRootContextProperty("loginModel", result.login.variant)
  # singletonInstance.engine.setRootContextProperty("onboardingModel", result.onboarding.variant)
  #result.connect()

proc delete*(self: AppController) =
  self.startupModule.delete
  self.mainModule.delete
  # self.login.delete
  # self.onboarding.delete

  self.accountsService.delete
  self.contactService.delete
  self.chatService.delete
  self.communityService.delete

proc startupDidLoad*(self: AppController) =
  singletonInstance.engine.load(newQUrl("qrc:///main.qml"))
  # self.login.init()
  # self.onboarding.init()

proc mainDidLoad*(self: AppController) =
  # This to will be adapted to appropriate modules later:
  self.appService.onLoggedIn()
  self.startupModule.moveToAppState()

  # Reset login and onboarding to remove any mnemonic that would have been saved in the accounts list
  # self.login.reset()
  # self.onboarding.reset()

  # self.login.moveToAppState()
  # self.onboarding.moveToAppState()
  # self.appService.status.events.emit("loginCompleted", self.accountArgs)

proc start*(self: AppController) =
  self.accountsService.init()
  
  self.startupModule.load()

proc load*(self: AppController) =
  self.contactService.init()
  self.chatService.init()
  self.communityService.init()
  
  self.mainModule.load()

proc userLoggedIn*(self: AppController) =
  self.load()