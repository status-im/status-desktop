import NimQml

import models/mailservers

import status/[status, settings]
import status/types/mailserver

import ../../../../../app_service/[main]
import ../../../../../app_service/tasks/[qt, threadpool]
import ../../../../../app_service/tasks/marathon/mailserver/worker

# import ./controller_interface
import ./io_interface

QtObject:
  type
    View* = ref object of QObject
      delegate: io_interface.AccessInterface
      mailserversList*: MailServersList

  proc delete*(self: View) =
    self.mailserversList.delete
    self.QObject.delete

  proc newView*(delegate: io_interface.AccessInterface): View =
    new(result, delete)
    result.QObject.setup
    result.mailserversList = newMailServersList()
    result.delegate = delegate

  proc add*(self: View, mailserver: MailServer) =
    self.mailserversList.add(mailserver)

  proc getMailserversList(self: View): QVariant {.slot.} =
    return newQVariant(self.mailserversList)

  QtProperty[QVariant] list:
    read = getMailserversList

  proc activeMailserverChanged*(self: View, activeMailserverName: string) {.signal.}

  proc getActiveMailserver(self: View): string {.slot.} =
    self.delegate.getActiveMailserver()
    # let
    #   mailserverWorker = self.appService.marathon[MailserverWorker().name]
    #   task = GetActiveMailserverTaskArg(
    #     `method`: "getActiveMailserver",
    #     vptr: cast[ByteAddress](self.vptr),
    #     slot: "getActiveMailserverResult"
    #   )
    # mailserverWorker.start(task)

  proc getActiveMailserverResult*(self: View, activeMailserver: string) {.slot.} =
    self.activeMailserverChanged(activeMailserver)

  proc getAutomaticSelection(self: View): bool {.slot.} =
    self.delegate.getAutomaticSelection()

  QtProperty[bool] automaticSelection:
    read = getAutomaticSelection

  proc setMailserver(self: View, id: string) {.slot.} =
    let enode = self.mailserversList.getMailserverEnode(id)
    self.delegate.pinMailserver(enode)

  proc enableAutomaticSelection(self: View, value: bool) {.slot.} =
    if value:
      # self.status.settings.pinMailserver()
      self.delegate.pinMailserver("")
    else:
      discard self.delegate.getActiveMailserver()
      # let
      #   mailserverWorker = self.appService.marathon[MailserverWorker().name]
      #   task = GetActiveMailserverTaskArg(
      #     `method`: "getActiveMailserver",
      #     vptr: cast[ByteAddress](self.vptr),
      #     slot: "getActiveMailserverResult2"
      #   )
      # mailserverWorker.start(task)

  proc getActiveMailserverResult2(self: View, activeMailserver: string) {.slot.} =
    self.delegate.pinMailserver(activeMailserver)
    # self.status.settings.pinMailserver(activeMailserver)

  proc save(self: View, name: string, address: string) {.slot.} =
    self.delegate.saveMailserver(name, address)
    self.mailserversList.add(Mailserver(name: name, endpoint: address))
