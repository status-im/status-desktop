import item, controller_interface, io_interface
import ../../core/global_singleton

import ../../../app_service/service/keychain/service as keychain_service
import ../../../app_service/service/accounts/service_interface as accounts_service
import ../../../app_service/service/community/service as community_service

import eventemitter
import status/[signals]

export controller_interface

type 
  Controller* = ref object of controller_interface.AccessInterface
    delegate: io_interface.AccessInterface
    events: EventEmitter
    keychainService: keychain_service.Service
    accountsService: accounts_service.ServiceInterface
    communityService: community_service.ServiceInterface
    activeSectionId: string

proc newController*(delegate: io_interface.AccessInterface, 
  events: EventEmitter,
  keychainService: keychain_service.Service,
  accountsService: accounts_service.ServiceInterface,
  communityService: community_service.ServiceInterface): 
  Controller =
  result = Controller()
  result.delegate = delegate
  result.events = events
  result.keychainService = keychainService
  result.accountsService = accountsService
  result.communityService = communityService
  
method delete*(self: Controller) =
  discard

method init*(self: Controller) = 
  if(defined(macosx)): 
    let account = self.accountsService.getLoggedInAccount()
    singletonInstance.localAccountSettings.setFileName(account.name)

  self.events.on("keychainServiceSuccess") do(e:Args):
    let args = KeyChainServiceArg(e)
    self.delegate.emitStoringPasswordSuccess()

  self.events.on("keychainServiceError") do(e:Args):
    let args = KeyChainServiceArg(e)
    singletonInstance.localAccountSettings.removeKey(LS_KEY_STORE_TO_KEYCHAIN)
    self.delegate.emitStoringPasswordError(args.errDescription)

  self.events.on("sectionAvailabilityChanged") do(e:Args):
    ## We will receive here a signal with two fields:
    ## sectionType: int
    ## enabled: bool
    ## 
    ## Then we only need to do something like:
    ## if(enabled):
    ##   self.delegate.enableSection(sectionType)
    ## else:
    ##   self.delegate.disableSection(sectionType)
    discard    

method getCommunities*(self: Controller): seq[community_service.CommunityDto] =
  return self.communityService.getCommunities()

method checkForStoringPassword*(self: Controller) =
  # This method is called once user is logged in irrespective he is logged in 
  # through the onboarding or login view.

  # This is MacOS only feature
  if(not defined(macosx)): 
    return

  let value = singletonInstance.localAccountSettings.getStoreToKeychainValue()
  if (value == LS_VALUE_STORE or value == LS_VALUE_NEVER):
    return

  # We are here if stored "storeToKeychain" property for the logged in user
  # is either empty or set to "NotNow".
  self.delegate.offerToStorePassword()

method storePassword*(self: Controller, password: string) =
  let account = self.accountsService.getLoggedInAccount()

  let value = singletonInstance.localAccountSettings.getStoreToKeychainValue()
  if (value != LS_VALUE_STORE or account.name.len == 0):
    return

  self.keychainService.storePassword(account.name, password)

method setActiveSection*(self: Controller, sectionId: string, sectionType: SectionType) =
  self.activeSectionId = sectionId

  if(sectionType == SectionType.Chat or sectionType != SectionType.Community):
    # We need to take other actions here, in case of Chat or Community sections like
    # notify status go that unviewed mentions count is updated and so...
    # and then in case all is good, notify the view about the chage so it can update the UI
    echo "deal with appropriate service..."

  singletonInstance.localAccountSensitiveSettings.setActiveSection(self.activeSectionId)

  self.delegate.activeSectionSet(self.activeSectionId)