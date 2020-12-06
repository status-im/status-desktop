import NimQml, chronicles
import ../../../status/status
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
