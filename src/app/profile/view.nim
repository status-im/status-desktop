import NimQml
import views/mailservers_list
import views/contact_list
import views/profile_info
import ../../status/profile
import ../../status/accounts as status_accounts
import ../../status/status

QtObject:
  type ProfileView* = ref object of QObject
    profile*: ProfileInfoView
    mailserversList*: MailServersList
    contactList*: ContactList
    status*: Status

  proc setup(self: ProfileView) =
    self.QObject.setup

  proc delete*(self: ProfileView) =
    self.QObject.delete

  proc newProfileView*(status: Status): ProfileView =
    new(result, delete)
    result = ProfileView()
    result.profile = newProfileInfoView()
    result.mailserversList = newMailServersList()
    result.contactList = newContactList()
    result.status = status
    result.setup

  proc addMailServerToList*(self: ProfileView, mailserver: MailServer) =
    self.mailserversList.addMailServerToList(mailserver)

  proc getMailserversList(self: ProfileView): QVariant {.slot.} =
    return newQVariant(self.mailserversList)

  QtProperty[QVariant] mailserversList:
    read = getMailserversList

  proc addContactToList*(self: ProfileView, contact: Contact) =
    self.contactList.addContactToList(contact)

  proc getContactList(self: ProfileView): QVariant {.slot.} =
    return newQVariant(self.contactList)

  QtProperty[QVariant] contactList:
    read = getContactList

  proc getProfile(self: ProfileView): QVariant {.slot.} =
    return newQVariant(self.profile)

  proc setNewProfile*(self: ProfileView, profile: Profile) =
    self.profile.setProfile(profile)

  QtProperty[QVariant] profile:
    read = getProfile

  proc logout*(self: ProfileView) {.slot.} =
    self.status.profile.logout()
