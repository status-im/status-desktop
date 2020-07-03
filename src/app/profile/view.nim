import NimQml, sequtils
import views/[mailservers_list, contact_list, profile_info]
import ../../status/profile/[mailserver, profile]
import ../../status/profile as status_profile
import ../../status/contacts as status_contacts
import ../../status/accounts as status_accounts
import ../../status/status
import ../../status/devices
import ../../status/chat/chat
import qrcode/qrcode

QtObject:
  type ProfileView* = ref object of QObject
    profile*: ProfileInfoView
    mailserversList*: MailServersList
    contactList*: ContactList
    mnemonic: string
    status*: Status
    isDeviceSetup: bool

  proc setup(self: ProfileView) =
    self.QObject.setup

  proc delete*(self: ProfileView) =
    if not self.mailserversList.isNil: self.mailserversList.delete
    if not self.contactList.isNil: self.contactList.delete
    if not self.profile.isNil: self.profile.delete
    self.QObject.delete

  proc newProfileView*(status: Status): ProfileView =
    new(result, delete)
    result = ProfileView()
    result.profile = newProfileInfoView()
    result.mailserversList = newMailServersList()
    result.contactList = newContactList()
    result.mnemonic = ""
    result.status = status
    result.isDeviceSetup = false
    result.setup

  proc addMailServerToList*(self: ProfileView, mailserver: MailServer) =
    self.mailserversList.addMailServerToList(mailserver)

  proc getMailserversList(self: ProfileView): QVariant {.slot.} =
    return newQVariant(self.mailserversList)

  QtProperty[QVariant] mailserversList:
    read = getMailserversList

  proc updateContactList*(self: ProfileView, contacts: seq[Profile]) =
    for contact in contacts:
      self.contactList.updateContact(contact)

  proc contactListChanged*(self: ProfileView) {.signal.}

  proc getContactList(self: ProfileView): QVariant {.slot.} =
    return newQVariant(self.contactList)

  proc setContactList*(self: ProfileView, contactList: seq[Profile]) =
    self.contactList.setNewData(contactList)
    self.contactListChanged()

  QtProperty[QVariant] contactList:
    read = getContactList
    write = setContactList
    notify = contactListChanged

  proc mnemonicChanged*(self: ProfileView) {.signal.}

  proc getMnemonic*(self: ProfileView): QVariant {.slot.} =
    return newQVariant(self.mnemonic)

  proc setMnemonic*(self: ProfileView, mnemonic: string) =
    self.mnemonic = mnemonic
    self.mnemonicChanged()

  QtProperty[QVariant] mnemonic:
    read = getMnemonic
    write = setMnemonic
    notify = mnemonicChanged

  proc getProfile(self: ProfileView): QVariant {.slot.} =
    return newQVariant(self.profile)

  proc setNewProfile*(self: ProfileView, profile: Profile) =
    self.profile.setProfile(profile)

  QtProperty[QVariant] profile:
    read = getProfile

  proc logout*(self: ProfileView) {.slot.} =
    self.status.profile.logout()

  proc nodeVersion*(self: ProfileView): string {.slot.} =
    self.status.getNodeVersion()

  proc isAdded*(self: ProfileView, id: string): bool {.slot.} =
    if id == "": return false
    self.status.contacts.isAdded(id)

  proc qrCode*(self: ProfileView, text:string): string {.slot.} =
    result = "data:image/svg+xml;utf8," & generateQRCodeSVG(text, 2)

  proc changeTheme*(self: ProfileView, theme: int) {.slot.} =
    self.profile.setAppearance(theme)
    self.status.saveSetting("appearance", $theme)
    
  proc isDeviceSetup*(self: ProfileView): bool {.slot} =
    result = self.isDeviceSetup

  proc deviceSetupChanged*(self: ProfileView) {.signal.}

  proc setDeviceSetup*(self: ProfileView, isSetup: bool) {.slot} =
    self.isDeviceSetup = isSetup
    self.deviceSetupChanged()

  QtProperty[bool] deviceSetup:
    read = isDeviceSetup
    notify = deviceSetupChanged

  proc setDeviceName*(self: ProfileView, deviceName: string) {.slot.} =
    devices.setDeviceName(deviceName)
    self.isDeviceSetup = true
    self.deviceSetupChanged()

  proc syncAllDevices*(self: ProfileView) {.slot.} =
    devices.syncAllDevices()

  proc advertiseDevice*(self: ProfileView) {.slot.} =
    devices.advertise()
