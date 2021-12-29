import NimQml, chronicles
import status/[status, settings]
import status/types/mailserver

import ./mailservers_list
import ../../core/[main]
import ../../core/tasks/[qt, threadpool]
import ../../core/tasks/marathon/mailserver/worker

logScope:
  topics = "mailservers-view"

QtObject:
  type MailserversView* = ref object of QObject
    status: Status
    statusFoundation: StatusFoundation
    mailserversList*: MailServersList

  # proc setup(self: MailserversView) =
  #   self.QObject.setup

  # proc delete*(self: MailserversView) =
  #   self.mailserversList.delete
  #   self.QObject.delete

  # proc newMailserversView*(status: Status, statusFoundation: StatusFoundation): MailserversView =
  #   new(result, delete)
  #   result.status = status
  #   result.statusFoundation = statusFoundation
  #   result.mailserversList = newMailServersList()
  #   result.setup

  # proc add*(self: MailserversView, mailserver: MailServer) =
  #   self.mailserversList.add(mailserver)

  # proc getMailserversList(self: MailserversView): QVariant {.slot.} =
  #   return newQVariant(self.mailserversList)

  # QtProperty[QVariant] list:
  #   read = getMailserversList

  # proc activeMailserverChanged*(self: MailserversView, activeMailserverName: string) {.signal.}

  # proc getActiveMailserver(self: MailserversView): string {.slot.} =
  #   let
  #     mailserverWorker = self.statusFoundation.marathon[MailserverWorker().name]
  #     task = GetActiveMailserverTaskArg(
  #       `method`: "getActiveMailserver",
  #       vptr: cast[ByteAddress](self.vptr),
  #       slot: "getActiveMailserverResult"
  #     )
  #   mailserverWorker.start(task)

  # proc getActiveMailserverResult*(self: MailserversView, activeMailserver: string) {.slot.} =
  #   self.activeMailserverChanged(activeMailserver)

  # proc getAutomaticSelection(self: MailserversView): bool {.slot.} =
  #   self.status.settings.getPinnedMailserver() == ""

  # QtProperty[bool] automaticSelection:
  #   read = getAutomaticSelection

  proc setMailserver(self: MailserversView, id: string) {.slot.} =
    let enode = self.mailserversList.getMailserverEnode(id)
    self.status.settings.pinMailserver(enode)

  # proc enableAutomaticSelection(self: MailserversView, value: bool) {.slot.} =
  #   if value:
  #     self.status.settings.pinMailserver()
  #   else:
  #     let
  #       mailserverWorker = self.statusFoundation.marathon[MailserverWorker().name]
  #       task = GetActiveMailserverTaskArg(
  #         `method`: "getActiveMailserver",
  #         vptr: cast[ByteAddress](self.vptr),
  #         slot: "getActiveMailserverResult2"
  #       )
  #     mailserverWorker.start(task)

  # proc getActiveMailserverResult2(self: MailserversView, activeMailserver: string) {.slot.} =
  #   self.status.settings.pinMailserver(activeMailserver)

  proc save(self: MailserversView, name: string, address: string) {.slot.} =
    self.status.settings.saveMailserver(name, address)
    self.mailserversList.add(Mailserver(name: name, endpoint: address))
