import NimQml
import Tables
import json
import eventemitter
import ../../status/accounts as status_accounts
import nimcrypto
import ../../status/utils
import ../../status/libstatus
import ../../models/accounts as Models
import ../../constants/constants
import uuids
import ../../status/test as status_test

type
  AddressRoles {.pure.} = enum
    Username = UserRole + 1,
    Identicon = UserRole + 2,
    Key = UserRole + 3

type
  Address* = ref object of QObject
    username*, identicon*, key*: string

QtObject:
  type OnboardingView* = ref object of QAbstractListModel
    addresses*: seq[Address]
    model: AccountModel
    # m_generatedAddresses: string
    doStoreAccountAndLogin: proc(model: AccountModel, selectedAccount: int, password: string): string
    doGenerateRandomAccountAndLogin: proc(events: EventEmitter)

  proc setup(self: OnboardingView) =
    self.QAbstractListModel.setup

  proc delete*(self: OnboardingView) =
    self.QAbstractListModel.delete
    for address in self.addresses:
      address.delete
    self.addresses = @[]

  proc newOnboardingView*(model: AccountModel, doStoreAccountAndLogin: proc, doGenerateRandomAccountAndLogin: proc(events: EventEmitter)): OnboardingView =
    new(result, delete)
    result.model = model
    result.doStoreAccountAndLogin = doStoreAccountAndLogin
    result.doGenerateRandomAccountAndLogin = doGenerateRandomAccountAndLogin
    result.addresses = @[]
    result.setup

  proc addAddressToList*(self: OnboardingView, username: string, identicon: string, key: string) {.slot.} =
    self.beginInsertRows(newQModelIndex(), self.addresses.len, self.addresses.len)
    self.addresses.add(Address(username : username,
                          identicon : identicon,
                          key : key))
    self.endInsertRows()

  method rowCount(self: OnboardingView, index: QModelIndex = nil): int =
    return self.addresses.len

  method data(self: OnboardingView, index: QModelIndex, role: int): QVariant =
    if not index.isValid:
      return
    if index.row < 0 or index.row >= self.addresses.len:
      return

    let asset = self.addresses[index.row]
    let assetRole = role.AddressRoles
    case assetRole:
    of AddressRoles.Username: result = newQVariant(asset.username)
    of AddressRoles.Identicon: result = newQVariant(asset.identicon)
    of AddressRoles.Key: result = newQVariant(asset.key)

  method roleNames(self: OnboardingView): Table[int, string] =
    { AddressRoles.Username.int:"username",
    AddressRoles.Identicon.int:"identicon",
    AddressRoles.Key.int:"key" }.toTable

  # proc getGeneratedAddresses*(self: OnboardingView): string {.slot.} =
  #   result = self.m_generatedAddresses

  # proc generatedAddressesChanged*(self: OnboardingView,
  #     generatedAddresses: string) {.signal.}

  # proc setGeneratedAddresses*(self: OnboardingView, generatedAddresses: string) {.slot.} =
  #   if self.m_generatedAddresses == generatedAddresses:
  #     return
  #   self.m_generatedAddresses = generatedAddresses
  #   self.generatedAddressesChanged(generatedAddresses)

  # QtProperty[string]generatedAddresses:
  #   read = getGeneratedAddresses
  #   write = setGeneratedAddresses
  #   notify = generatedAddressesChanged

  # QML functions
  # proc generateAddresses*(self: OnboardingView) {.slot.} =
    # self.setGeneratedAddresses(status_accounts.generateAddresses())

  # proc generateAlias*(self: OnboardingView, publicKey: string): string {.slot.} =
  #   result = $libstatus.generateAlias(publicKey.toGoString)

  # proc identicon*(self: OnboardingView, publicKey: string): string {.slot.} =
  #   result = $libstatus.identicon(publicKey.toGoString)

  # proc storeAccountAndLogin(self: OnboardingView, selectedAccount: string, password: string): string {.slot.} =
  proc storeAccountAndLogin(self: OnboardingView, selectedAccountIndex: int, password: string): string {.slot.} =
    echo "--------------------"
    echo "--------------------"
    echo selectedAccountIndex
    echo "--------------------"
    echo "--------------------"
    # var selectedAccountIndex = self.addresses
    result = self.doStoreAccountAndLogin(self.model, selectedAccountIndex, password)

  # TODO: this is temporary and will be removed once accounts import and creation is working
  proc generateRandomAccountAndLogin*(self: OnboardingView) {.slot.} =
    self.doGenerateRandomAccountAndLogin(self.model.events)
