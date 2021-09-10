import NimQml, Tables, strutils
import trait_list
from status/wallet2 import OpenseaAsset

type
  AssetRoles {.pure.} = enum
    Id = UserRole + 1,
    Name = UserRole + 2,
    Description = UserRole + 3,
    Permalink = UserRole + 4,
    ImageUrl = UserRole + 5,
    BackgroundColor = UserRole + 6,
    Properties = UserRole + 7,
    Rankings = UserRole + 8,
    Stats = UserRole + 9

QtObject:
  type AssetList* = ref object of QAbstractListModel
    assets*: seq[OpenseaAsset]
    propertiesList*: TraitsList
    rankingList*: TraitsList
    statsList*: TraitsList

  proc setup(self: AssetList) = self.QAbstractListModel.setup

  proc delete(self: AssetList) =
    self.assets = @[]
    self.QAbstractListModel.delete

  proc newAssetList*(): AssetList =
    new(result, delete)
    result.assets = @[]
    result.propertiesList = newTraitsList()
    result.rankingList = newTraitsList()
    result.statsList = newTraitsList()
    result.setup

  proc assetsChanged*(self: AssetList) {.signal.}
  
  proc getAsset*(self: AssetList, index: int): OpenseaAsset = self.assets[index]

  proc rowData(self: AssetList, index: int, column: string): string {.slot.} =
    if (index >= self.assets.len):
      return
    
    let asset = self.assets[index]
    case column:
      of "name": result = asset.name
      of "imageUrl": result = asset.imageUrl

  method rowCount*(self: AssetList, index: QModelIndex = nil): int =
    return self.assets.len

  method data(self: AssetList, index: QModelIndex, role: int): QVariant =
    if not index.isValid:
      return

    if index.row < 0 or index.row >= self.assets.len:
      return
    
    let asset = self.assets[index.row]
    let assetRole = role.AssetRoles
    case assetRole:
    of AssetRoles.Id: result = newQVariant(asset.id)
    of AssetRoles.Name: result = newQVariant(asset.name)
    of AssetRoles.Description: result = newQVariant(asset.description)
    of AssetRoles.Permalink: result = newQVariant(asset.permalink)
    of AssetRoles.ImageUrl: result = newQVariant(asset.imageUrl)
    of AssetRoles.BackgroundColor: result = newQVariant(if (asset.backgroundColor == ""): "transparent" else: ("#" & asset.backgroundColor))
    of AssetRoles.Properties:
        self.propertiesList.traits = @[]
        self.propertiesList.traits = asset.properties
        result = newQVariant(self.propertiesList)
    of AssetRoles.Rankings:
        self.rankingList.traits = @[]
        self.rankingList.traits = asset.rankings
        result = newQVariant(self.rankingList)
    of AssetRoles.Stats:
        self.statsList.traits = @[]
        self.statsList.traits = asset.statistics
        result = newQVariant(self.statsList)

  method roleNames(self: AssetList): Table[int, string] =
    { AssetRoles.Id.int:"id",
    AssetRoles.Name.int:"name",
    AssetRoles.Description.int:"description",
    AssetRoles.Permalink.int:"permalink",
    AssetRoles.ImageUrl.int:"imageUrl",
    AssetRoles.BackgroundColor.int:"backgroundColor",
    AssetRoles.Properties.int:"properties",
    AssetRoles.Rankings.int:"rankings",
    AssetRoles.Stats.int:"stats"}.toTable

  proc setData*(self: AssetList, assets: seq[OpenseaAsset]) =
    self.beginResetModel()
    self.assets = assets
    self.endResetModel()
    self.assetsChanged()
