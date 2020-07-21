import NimQml, sequtils
import views/[mailservers_list, contact_list, profile_info, device_list]
import ../../status/profile/[mailserver, profile, devices]
import ../../status/profile as status_profile
import ../../status/contacts as status_contacts
import ../../status/accounts as status_accounts
import ../../status/status
import ../../status/devices as status_devices
import ../../status/chat/chat
import ../../status/libstatus/types
import qrcode/qrcode

QtObject:
  type ProfileView* = ref object of QObject
    profile*: ProfileInfoView
    mailserversList*: MailServersList
    contactList*: ContactList
    deviceList*: DeviceList
    mnemonic: string
    network: string
    status*: Status
    isDeviceSetup: bool
    changeLanguage*: proc(locale: string)

  proc setup(self: ProfileView) =
    self.QObject.setup

  proc delete*(self: ProfileView) =
    if not self.mailserversList.isNil: self.mailserversList.delete
    if not self.contactList.isNil: self.contactList.delete
    if not self.deviceList.isNil: self.deviceList.delete
    if not self.profile.isNil: self.profile.delete
    self.QObject.delete

  proc newProfileView*(status: Status, changeLanguage: proc(locale: string)): ProfileView =
    new(result, delete)
    result = ProfileView()
    result.profile = newProfileInfoView()
    result.mailserversList = newMailServersList()
    result.contactList = newContactList()
    result.deviceList = newDeviceList()
    result.mnemonic = ""
    result.network = ""
    result.status = status
    result.isDeviceSetup = false
    result.changeLanguage = changeLanguage
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

  proc enableInstallation*(self: ProfileView, installationId: string, enable: bool) {.slot.} =
    if enable:
      status_devices.enable(installationId)
    else:
      status_devices.disable(installationId)