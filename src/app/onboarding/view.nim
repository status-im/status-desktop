import NimQml
import Tables
import json
import nimcrypto
import ../../models/accounts as Models

type
  AddressRoles {.pure.} = enum
    Username = UserRole + 1,
    Identicon = UserRole + 2,
    Key = UserRole + 3

QtObject:
  type OnboardingView* = ref object of QAbstractListModel
    addresses*: seq[Address]
    model: AccountModel

  proc setup(self: OnboardingView) =
    self.QAbstractListModel.setup

  proc delete*(self: OnboardingView) =
    self.QAbstractListModel.delete
    self.addresses = @[]

  proc newOnboardingView*(model: AccountModel): OnboardingView =
    new(result, delete)
    result.model = model
    result.addresses = @[]
    result.setup

  proc addAddressToList*(self: OnboardingView, address: Address) =
    self.beginInsertRows(newQModelIndex(), self.addresses.len, self.addresses.len)
    self.addresses.add(address)
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

  proc storeAccountAndLogin(self: OnboardingView, selectedAccountIndex: int, password: string) {.slot.} =
    discard self.model.storeAccountAndLogin(selectedAccountIndex, password)

  # TODO: this is temporary and will be removed once accounts import and creation is working
  proc generateRandomAccountAndLogin*(self: OnboardingView) {.slot.} =
    self.model.generateRandomAccountAndLogin()
