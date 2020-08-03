import NimQml, sequtils, strutils, sugar
import views/[mailservers_list, ens_manager, contact_list, profile_info, device_list]
import ../../status/profile/[mailserver, profile, devices]
import ../../status/profile as status_profile
import ../../status/contacts as status_contacts
import ../../status/accounts as status_accounts
import ../../status/status
import ../../status/devices as status_devices
import ../../status/ens as status_ens
import ../../status/chat/chat
import ../../status/libstatus/types
import qrcode/qrcode

QtObject:
  type ProfileView* = ref object of QObject
    profile*: ProfileInfoView
    mailserversList*: MailServersList
    contactList*: ContactList
    addedContacts*: ContactList
    blockedContacts*: ContactList
    deviceList*: DeviceList
    mnemonic: string
    network: string
    status*: Status
    isDeviceSetup: bool
    changeLanguage*: proc(locale: string)
    contactToAdd*: Profile
    ens*: EnsManager

  proc setup(self: ProfileView) =
    self.QObject.setup

  proc delete*(self: ProfileView) =
    if not self.mailserversList.isNil: self.mailserversList.delete
    if not self.contactList.isNil: self.contactList.delete
    if not self.addedContacts.isNil: self.addedContacts.delete
    if not self.blockedContacts.isNil: self.blockedContacts.delete
    if not self.deviceList.isNil: self.deviceList.delete
    if not self.ens.isNil: self.ens.delete
    if not self.profile.isNil: self.profile.delete
    self.QObject.delete

  proc newProfileView*(status: Status, changeLanguage: proc(locale: string)): ProfileView =
    new(result, delete)
    result = ProfileView()
    result.profile = newProfileInfoView()
    result.mailserversList = newMailServersList()
    result.contactList = newContactList()
    result.addedContacts = newContactList()
    result.blockedContacts = newContactList()
    result.deviceList = newDeviceList()
    result.ens = newEnsManager()
    result.mnemonic = ""
    result.network = ""
    result.status = status
    result.isDeviceSetup = false
    result.changeLanguage = changeLanguage
    result.contactToAdd = Profile(
      username: "",
      alias: "",
      ensName: ""
    )
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
      if contact.systemTags.contains(":contact/added"):
          self.addedContacts.updateContact(contact)
      if contact.systemTags.contains(":contact/blocked"):
          self.blockedContacts.updateContact(contact)

  proc contactListChanged*(self: ProfileView) {.signal.}

  proc getContactList(self: ProfileView): QVariant {.slot.} =
    return newQVariant(self.contactList)

  proc setContactList*(self: ProfileView, contactList: seq[Profile]) =
    self.contactList.setNewData(contactList)
    self.addedContacts.setNewData(contactList.filter(c => c.systemTags.contains(":contact/added")))
    self.blockedContacts.setNewData(contactList.filter(c => c.systemTags.contains(":contact/blocked")))
    self.contactListChanged()

  QtProperty[QVariant] contactList:
    read = getContactList
    write = setContactList
    notify = contactListChanged

  proc getAddedContacts(self: ProfileView): QVariant {.slot.} =
    return newQVariant(self.addedContacts)

  QtProperty[QVariant] addedContacts:
    read = getAddedContacts
    notify = contactListChanged

  proc getBlockedContacts(self: ProfileView): QVariant {.slot.} =
    return newQVariant(self.blockedContacts)

  QtProperty[QVariant] blockedContacts:
    read = getBlockedContacts
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

  proc networkChanged*(self: ProfileView) {.signal.}

  proc getNetwork*(self: ProfileView): QVariant {.slot.} =
    return newQVariant(self.network)

  proc setNetwork*(self: ProfileView, network: string) =
    self.network = network
    self.networkChanged()
  
  proc setNetworkAndPersist*(self: ProfileView, network: string) {.slot.} =
    self.network = network
    self.networkChanged()
    self.status.accounts.changeNetwork(network)
    quit(QuitSuccess) # quits the app TODO: change this to logout instead when supported

  QtProperty[QVariant] network:
    read = getNetwork
    write = setNetworkAndPersist
    notify = networkChanged

  proc getProfile(self: ProfileView): QVariant {.slot.} =
    return newQVariant(self.profile)

  proc setNewProfile*(self: ProfileView, profile: Profile) =
    self.profile.setProfile(profile)

  QtProperty[QVariant] profile:
    read = getProfile

  proc contactToAddChanged*(self: ProfileView) {.signal.}

  proc getContactToAddUsername(self: ProfileView): QVariant {.slot.} =
    var username = self.contactToAdd.alias;

    if self.contactToAdd.ensVerified and self.contactToAdd.ensName != "":
      username = self.contactToAdd.ensName

    return newQVariant(username)

  QtProperty[QVariant] contactToAddUsername:
    read = getContactToAddUsername
    notify = contactToAddChanged

  proc getContactToAddPubKey(self: ProfileView): QVariant {.slot.} =
    return newQVariant(self.contactToAdd.address)

  QtProperty[QVariant] contactToAddPubKey:
    read = getContactToAddPubKey
    notify = contactToAddChanged

  proc logout*(self: ProfileView) {.slot.} =
    self.status.profile.logout()

  proc changeLocale*(self: ProfileView, locale: string) {.slot.} =
    self.changeLanguage(locale)
  
  proc nodeVersion*(self: ProfileView): string {.slot.} =
    self.status.getNodeVersion()

  proc isAdded*(self: ProfileView, id: string): bool {.slot.} =
    if id == "": return false
    self.status.contacts.isAdded(id)

  proc qrCode*(self: ProfileView, text:string): string {.slot.} =
    result = "data:image/svg+xml;utf8," & generateQRCodeSVG(text, 2)

  proc changeTheme*(self: ProfileView, theme: int) {.slot.} =
    self.profile.setAppearance(theme)
    self.status.saveSetting(Setting.Appearance, $theme)
    
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
    status_devices.setDeviceName(deviceName)
    self.setDeviceSetup(true)

  proc syncAllDevices*(self: ProfileView) {.slot.} =
    status_devices.syncAllDevices()

  proc advertiseDevice*(self: ProfileView) {.slot.} =
    status_devices.advertise()

  proc addDevices*(self: ProfileView, devices: seq[Installation]) =
    for dev in devices:
      self.deviceList.addDeviceToList(dev)

  proc getDeviceList(self: ProfileView): QVariant {.slot.} =
    return newQVariant(self.deviceList)

  QtProperty[QVariant] deviceList:
    read = getDeviceList

  proc getEnsManager(self: ProfileView): QVariant {.slot.} =
    return newQVariant(self.ens)

  QtProperty[QVariant] ens:
    read = getEnsManager

  proc enableInstallation*(self: ProfileView, installationId: string, enable: bool) {.slot.} =
    if enable:
      status_devices.enable(installationId)
    else:
      status_devices.disable(installationId)

  proc lookupContact*(self: ProfileView, value: string) {.slot.} =
    if value == "":
      return

    var id = value

    if not id.startsWith("0x"):
      id = status_ens.pubkey(id)

    let contact = self.status.contacts.getContactByID(id)

    if contact != nil:
      self.contactToAdd = contact
    else:
      self.contactToAdd = Profile(
        username: "",
        alias: "",
        ensName: "",
        ensVerified: false
      )
    self.contactToAddChanged()

  proc addContact*(self: ProfileView, pk: string) {.slot.} =
    discard self.status.contacts.addContact(pk)

  proc unblockContact*(self: ProfileView, id: string) {.slot.} =
    discard self.status.contacts.unblockContact(id)

  proc blockContact*(self: ProfileView, id: string) {.slot.} =
    discard self.status.contacts.blockContact(id)

  proc removeContact*(self: ProfileView, id: string) {.slot.} =
    self.status.contacts.removeContact(id)
