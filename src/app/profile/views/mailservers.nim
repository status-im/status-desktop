import NimQml, chronicles
import ../../../status/status
import ../../../status/mailservers
import ../../../status/profile/mailserver
import mailservers_list
import ../../../status/libstatus/settings as status_settings

logScope:
  topics = "mailservers-view"

QtObject:
  type MailserversView* = ref object of QObject
    status: Status
    mailserversList*: MailServersList

  proc setup(self: MailserversView) =
    self.QObject.setup

  proc delete*(self: MailserversView) =
    self.mailserversList.delete
    self.QObject.delete

  proc newMailserversView*(status: Status): MailserversView =
    new(result, delete)
    result.status = status
    result.mailserversList = newMailServersList()
    result.setup

  proc add*(self: MailserversView, mailserver: MailServer) =
    self.mailserversList.add(mailserver)

  proc getMailserversList(self: MailserversView): QVariant {.slot.} =
    return newQVariant(self.mailserversList)

  QtProperty[QVariant] list:
    read = getMailserversList

  proc getActiveMailserver(self: MailserversView): string {.slot.} =
    return self.mailserversList.getMailserverName(self.status.mailservers.getActiveMailserver())

  proc activeMailserverChanged*(self: MailserversView) {.signal.}

  QtProperty[string] activeMailserver:
    read = getActiveMailserver
    notify = activeMailserverChanged

  proc getAutomaticSelection(self: MailserversView): bool {.slot.} =
    status_settings.getPinnedMailserver() == ""

  QtProperty[bool] automaticSelection:
    read = getAutomaticSelection

  proc setMailserver(self: MailserversView, id: string) {.slot.} =
    let enode = self.mailserversList.getMailserverEnode(id)
    status_settings.pinMailserver(enode)

  proc enableAutomaticSelection(self: MailserversView, value: bool) {.slot.} =
    if value:
      status_settings.pinMailserver()
    else:
      status_settings.pinMailserver(self.status.mailservers.getActiveMailserver())
