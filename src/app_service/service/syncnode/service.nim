import json, json_serialization, sequtils, chronicles

import status/statusgo_backend/settings as status_go_settings

import ./service_interface, ./dto

export service_interface

logScope:
  topics = "settings-service"

const DESKTOP_VERSION {.strdefine.} = "0.0.0"

######################
# TODO: see src/app_service/tasks/marathon/mailserver/model.nim
######################

type 
  Service* = ref object of ServiceInterface
    # profile: Dto

method delete*(self: Service) =
  discard

proc newService*(): Service =
  result = Service()

method init*(self: Service) =
  try:
    echo "init"

  except Exception as e:
    let errDesription = e.msg
    error "error: ", errDesription
    return

method getActiveMailserver*(self: Service): string =
  return "replace-me-with-mailserver"
  # let
  #   mailserverWorker = self.appService.marathon[MailserverWorker().name]
  #   task = GetActiveMailserverTaskArg(
  #     `method`: "getActiveMailserver",
  #     vptr: cast[ByteAddress](self.vptr),
  #     slot: "getActiveMailserverResult"
  #   )
  # mailserverWorker.start(task)

method getAutomaticSelection*(self: Service): bool =
  status_go_settings.getPinnedMailserver() == ""

method pinMailserver*(self: Service, id: string) =
  status_go_settings.pinMailserver(id)

method enableAutomaticSelection*(self: Service, value: bool) =
  discard
  # status_go_settings.enableAutomaticSelection(value)

  # task
  # if value:
  #   self.status.settings.pinMailserver()
  # else:
  #   let
  #     mailserverWorker = self.appService.marathon[MailserverWorker().name]
  #     task = GetActiveMailserverTaskArg(
  #       `method`: "getActiveMailserver",
  #       vptr: cast[ByteAddress](self.vptr),
  #       slot: "getActiveMailserverResult2"
  #     )
  #   mailserverWorker.start(task)

  # result
  #self.status.settings.pinMailserver(activeMailserver)  

method saveMailserver*(self: Service, name: string, address: string) =
  status_go_settings.saveMailserver(name, address)
