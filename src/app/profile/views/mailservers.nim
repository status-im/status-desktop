import NimQml, chronicles, json
import status/[status, settings]
import status/types/mailserver

import ./mailservers_list
import ../../../app_service/[main]
import ../../../app_service/tasks/threadpool
import ../../../app_service/tasks/marathon/mailserver/worker

logScope:
  topics = "mailservers-view"

QtObject:
  type MailserversView* = ref object of QObject
    status: Status
    appService: AppService
    mailserversList*: MailServersList
    activeMailserver: string

  proc setup(self: MailserversView) =
    self.QObject.setup

  proc delete*(self: MailserversView) =
    self.mailserversList.delete
    self.QObject.delete

  proc newMailserversView*(status: Status, appService: AppService): MailserversView =
    new(result, delete)
    result.status = status
    result.appService = appService
    result.mailserversList = newMailServersList()
    result.setup

  proc add*(self: MailserversView, mailserver: MailServer) =
    self.mailserversList.add(mailserver)

  proc getMailserversList(self: MailserversView): QVariant {.slot.} =
    return newQVariant(self.mailserversList)

  QtProperty[QVariant] list:
    read = getMailserversList

  proc activeMailserverChanged*(self: MailserversView, activeMailserver: string) {.signal.}

  proc setActiveMailserver*(self: MailserversView, activeMailserver: string) =
    self.activeMailserver = activeMailserver
    self.activeMailserverChanged(activeMailserver)

  QtProperty[string] activeMailserver:
    read = activeMailserver
    notify = activeMailserverChanged

  proc getPinnedMailserver(self: MailserversView): string {.slot.} =
    self.status.settings.getPinnedMailserver()

  proc pinnedMailserverChanged(self: MailserversView) {.signal.}

  proc pinMailserver(self: MailserversView, name: string) {.slot.} =
    self.status.settings.pinMailserver(name)
    self.pinnedMailserverChanged()

  QtProperty[string] pinnedMailserver:
    read = getPinnedMailserver
    notify = pinnedMailserverChanged

  proc save(self: MailserversView, name: string, address: string) {.slot.} =
    self.status.settings.saveMailserver(name, address)
    self.mailserversList.add(Mailserver(name: name, endpoint: address))
