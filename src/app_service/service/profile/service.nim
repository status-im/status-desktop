import NimQml, json, chronicles

import ../settings/service as settings_service
import ../../../app/global/global_singleton

import ../../../app/core/signals/types
import ../../../app/core/eventemitter
import ../../../app/core/tasks/[qt, threadpool]

import ../../../backend/accounts as status_accounts

import ../accounts/dto/accounts
import ../community/dto/community
import ../wallet_account/dto/account_dto

include async_tasks

logScope:
  topics = "profile-service"

QtObject:
  type Service* = ref object of QObject
    threadpool: ThreadPool
    events: EventEmitter
    settingsService: settings_service.Service

  proc delete*(self: Service) =
    self.QObject.delete

  proc newService*(events: EventEmitter, threadpool: ThreadPool, settingsService: settings_service.Service): Service =
    new(result, delete)
    result.QObject.setup
    result.threadpool = threadpool
    result.events = events
    result.settingsService = settingsService

  # Forward declaration
  proc requestProfileShowcasePreferences*(self: Service)

  proc init*(self: Service) =
    self.events.on(SIGNAL_DISPLAY_NAME_UPDATED) do(e:Args):
      let args = SettingsTextValueArgs(e)
      singletonInstance.userProfile.setDisplayName(args.value)

    # Request preferences once on start
    self.requestProfileShowcasePreferences()

  proc storeIdentityImage*(self: Service, address: string, image: string, aX: int, aY: int, bX: int, bY: int): seq[Image] =
    try:
      let response = status_accounts.storeIdentityImage(address, image, aX, aY, bX, bY)
      if(not response.error.isNil):
        error "could not store identity images"
        return
      if(response.result.kind != JArray):
        error "error: ", procName="storeIdentityImage", errDesription = "response is not an array"
        return
      if(response.result.len == 0):
        error "error: array of stored images is empty"
        return

      for img in response.result:
        let imageDto = toImage(img)
        result.add(imageDto)
        if(imageDto.imgType == "large"):
          singletonInstance.userProfile.setLargeImage(imageDto.uri)
        elif(imageDto.imgType == "thumbnail"):
          singletonInstance.userProfile.setThumbnailImage(imageDto.uri)

    except Exception as e:
      error "error: ", procName="storeIdentityImage", errName = e.name, errDesription = e.msg

  proc deleteIdentityImage*(self: Service, address: string) =
    try:
      let response = status_accounts.deleteIdentityImage(address)
      if(not response.error.isNil):
        error "could not delete identity images"
        return
      singletonInstance.userProfile.setLargeImage("")
      singletonInstance.userProfile.setThumbnailImage("")

    except Exception as e:
      error "error: ", procName="deleteIdentityImage", errName = e.name, errDesription = e.msg

  proc setDisplayName*(self: Service, displayName: string) =
    try:
      let response =  status_accounts.setDisplayName(displayName)
      if(not response.error.isNil):
        error "could not set display name"
        return
      if(not self.settingsService.saveDisplayName(displayName)):
        error "could save display name to the settings"
        return
    except Exception as e:
      error "error: ", procName="setDisplayName", errName = e.name, errDesription = e.msg

  proc requestProfileShowcasePreferences*(self: Service) =
    try:
      let arg = QObjectTaskArg(
        tptr: cast[ByteAddress](asyncGetProfileShowcasePreferencesTask),
        vptr: cast[ByteAddress](self.vptr),
        slot: "asyncProfileShowcaseLoaded",
      )
      self.threadpool.start(arg)
    except Exception as e:
      error "Error requesting profile showcase preferences", msg = e.msg

  proc asyncProfileShowcaseLoaded*(self: Service, rpcResponse: string) {.slot.} =
    let rpcResponseObj = rpcResponse.parseJson
    if rpcResponseObj{"error"}.kind != JNull and rpcResponseObj{"error"}.getStr != "":
      error "Error requesting community info", msg = rpcResponseObj{"error"}
      return

    let result =  rpcResponseObj{"response"}{"result"}

    echo "-----> result:", result

    # # TODO: ProfileCommunityDto
    # var communities: seq[CommunityDto] = @[]
    # for profileCommunity in result{"communities"}:
    #   let community = profileCommunity.toCommunityDto()
    #   communities.add(community)

    # # TODO: ProfileWalletAccountDto
    # var accounts: seq[WalletAccountDto] = @[]
    # for profileAccount in result{"accounts"}:
    #   let account = profileAccount.toWalletAccountDto()
    #   accounts.add(account)

    # echo "-----> communities:", communities
    # echo "-----> accounts:", communities
    
    # let accounts =  response.result{"accounts"}
    # let collectibles =  response.result["collectibles"]
    # let assets =  response.result["assets"]
