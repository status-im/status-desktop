import NimQml, Tables
from status/wallet2 import OpenseaCollection

type
  CollectionRoles {.pure.} = enum
    Name = UserRole + 1,
    Slug = UserRole + 2,
    ImageUrl = UserRole + 3,
    OwnedAssetCount = UserRole + 4

QtObject:
  type CollectionList* = ref object of QAbstractListModel
    collections*: seq[OpenseaCollection]

  proc setup(self: CollectionList) = self.QAbstractListModel.setup

  proc delete(self: CollectionList) =
    self.collections = @[]
    self.QAbstractListModel.delete

  proc newCollectionList*(): CollectionList =
    new(result, delete)
    result.collections = @[]
    result.setup
  
  proc getCollection*(self: CollectionList, index: int): OpenseaCollection = self.collections[index]

  proc rowData(self: CollectionList, index: int, column: string): string {.slot.} =
    if (index >= self.collections.len):
      return
    
    let collection = self.collections[index]
    case column:
      of "name": result = collection.name
      of "slug": result = collection.slug
      of "imageUrl": result = collection.imageUrl
      of "ownedAssetCount": result = $collection.ownedAssetCount

  method rowCount*(self: CollectionList, index: QModelIndex = nil): int =
    return self.collections.len

  method data(self: CollectionList, index: QModelIndex, role: int): QVariant =
    if not index.isValid:
      return

    if index.row < 0 or index.row >= self.collections.len:
      return
    
    let collection = self.collections[index.row]
    let collectionRole = role.CollectionRoles
    case collectionRole:
    of CollectionRoles.Name: result = newQVariant(collection.name)
    of CollectionRoles.Slug: result = newQVariant(collection.slug)
    of CollectionRoles.ImageUrl: result = newQVariant(collection.imageUrl)
    of CollectionRoles.OwnedAssetCount: result = newQVariant(collection.ownedAssetCount)

  method roleNames(self: CollectionList): Table[int, string] =
    { CollectionRoles.Name.int:"name",
    CollectionRoles.Slug.int:"slug",
    CollectionRoles.ImageUrl.int:"imageUrl",
    CollectionRoles.OwnedAssetCount.int:"ownedAssetCount"}.toTable

  proc setData*(self: CollectionList, collections: seq[OpenseaCollection]) =
    self.beginResetModel()
    self.collections = collections
    self.endResetModel()