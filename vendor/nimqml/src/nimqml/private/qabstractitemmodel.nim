import tables

let qAbstractItemModelStaticMetaObjectInstance = newQAbstractItemModelMetaObject()

proc staticMetaObject*(c: type QAbstractItemModel): QMetaObject =
  ## Return the metaObject of QAbstractItemModel
  qAbstractItemModelStaticMetaObjectInstance

proc staticMetaObject*(self: QAbstractItemModel): QMetaObject =
  ## Return the metaObject of QAbstractItemModel
  qAbstractItemModelStaticMetaObjectInstance

method metaObject*(self: QAbstractItemModel): QMetaObject =
  # Return the metaObject
  QAbstractItemModel.staticMetaObject

method rowCount*(self: QAbstractItemModel, index: QModelIndex): int {.base.} =
  ## Return the model's row count
  0

proc rowCountCallback(modelPtr: pointer, rawIndex: DosQModelIndex, result: var cint) {.cdecl, exportc.} =
  debugMsg("QAbstractItemModel", "rowCountCallback")
  let model = cast[QAbstractItemModel](modelPtr)
  let index = newQModelIndex(rawIndex, Ownership.Clone)
  result = model.rowCount(index).cint

method columnCount*(self: QAbstractItemModel, index: QModelIndex): int {.base.} =
  ## Return the model's column count
  1

proc columnCountCallback(modelPtr: pointer, rawIndex: DosQModelIndex, result: var cint) {.cdecl, exportc.} =
  debugMsg("QAbstractItemModel", "columnCountCallback")
  let model = cast[QAbstractItemModel](modelPtr)
  let index = newQModelIndex(rawIndex, Ownership.Clone)
  result = model.columnCount(index).cint

method data*(self: QAbstractItemModel, index: QModelIndex, role: int): QVariant {.base.} =
  ## Return the data at the given model index and role
  nil

proc dataCallback(modelPtr: pointer, rawIndex: DosQModelIndex, role: cint, result: DosQVariant) {.cdecl, exportc.} =
  debugMsg("QAbstractItemModel", "dataCallback")
  let model = cast[QAbstractItemModel](modelPtr)
  let index = newQModelIndex(rawIndex, Ownership.Clone)
  let variant = data(model, index, role.int)
  if variant != nil:
    dos_qvariant_assign(result, variant.vptr)
    variant.delete

method setData*(self: QAbstractItemModel, index: QModelIndex, value: QVariant, role: int): bool {.base.} =
  ## Sets the data at the given index and role. Return true on success, false otherwise
  false

proc setDataCallback(modelPtr: pointer, rawIndex: DosQModelIndex, rawQVariant: DosQVariant, role: cint, result: var bool) {.cdecl, exportc.} =
  debugMsg("QAbstractItemModel", "setDataCallback")
  let model = cast[QAbstractItemModel](modelPtr)
  let index = newQModelIndex(rawIndex, Ownership.Clone)
  let variant = newQVariant(rawQVariant, Ownership.Clone)
  result = model.setData(index, variant, role.int)

method roleNames*(self: QAbstractItemModel): Table[int, string] {.base.} =
  ## Return the model role names
  nil

proc roleNamesCallback(modelPtr: pointer, hash: DosQHashIntByteArray) {.cdecl, exportc.} =
  debugMsg("QAbstractItemModel", "roleNamesCallback")
  let model = cast[QAbstractItemModel](modelPtr)
  let table = model.roleNames()
  for key, val in table.pairs:
    dos_qhash_int_qbytearray_insert(hash, key.cint, val.cstring)

method flags*(self: QAbstractItemModel, index: QModelIndex): QtItemFlag {.base.} =
  ## Return the item flags and the given index
  return QtItemFlag.None

proc flagsCallback(modelPtr: pointer, rawIndex: DosQModelIndex, result: var cint) {.cdecl, exportc.} =
  debugMsg("QAbstractItemModel", "flagsCallback")
  let model = cast[QAbstractItemModel](modelPtr)
  let index = newQModelIndex(rawIndex, Ownership.Clone)
  result = model.flags(index).cint

method headerData*(self: QAbstractItemModel, section: int, orientation: QtOrientation, role: int): QVariant {.base.} =
  ## Returns the data for the given role and section in the header with the specified orientation
  nil

proc headerDataCallback(modelPtr: pointer, section: cint, orientation: cint, role: cint, result: DosQVariant) {.cdecl, exportc.} =
  debugMsg("QAbstractItemModel", "headerDataCallback")
  let model = cast[QAbstractItemModel](modelPtr)
  let variant = model.headerData(section.int, orientation.QtOrientation, role.int)
  if variant != nil:
    dos_qvariant_assign(result, variant.vptr)
    variant.delete

proc createIndex*(self: QAbstractItemModel, row: int, column: int, data: pointer): QModelIndex =
  ## Create a new QModelIndex
  debugMsg("QAbstractItemModel", "createIndex")
  let index = dos_qabstractitemmodel_createIndex(self.vptr.DosQAbstractItemModel, row.cint, column.cint, data)
  result = newQModelIndex(index, Ownership.Take)

method index*(self: QAbstractItemModel, row: int, column: int, parent: QModelIndex): QModelIndex {.base.} =
  doAssert(false, "QAbstractItemModel::index is pure virtual")

proc indexCallback(modelPtr: pointer, row: cint, column: cint, parent: DosQModelIndex, result: DosQModelIndex) {.cdecl, exportc.} =
  debugMsg("QAbstractItemModel", "indexCallback")
  let model = cast[QAbstractItemModel](modelPtr)
  let index = model.index(row.int, column.int, newQModelIndex(parent, Ownership.Clone))
  dos_qmodelindex_assign(result, index.vptr)

method parent*(self: QAbstractItemModel, child: QModelIndex): QModelIndex {.base.} =
  doAssert(false, "QAbstractItemModel::parent is pure virtual")

proc parentCallback(modelPtr: pointer, child: DosQModelIndex, result: DosQModelIndex) {.cdecl, exportc.} =
  debugMsg("QAbstractItemModel", "parentCallback")
  let model = cast[QAbstractItemModel](modelPtr)
  let index = model.parent(newQModelIndex(child, Ownership.Clone))
  dos_qmodelindex_assign(result, index.vptr)

method hasChildren*(self: QAbstractItemModel, parent: QModelIndex): bool {.base.} =
  return dos_qabstractitemmodel_hasChildren(self.vptr.DosQAbstractItemModel, parent.vptr.DosQModelIndex)

proc hasChildrenCallback(modelPtr: pointer, parent: DosQModelIndex, result: var bool) {.cdecl, exportc.} =
  let model = cast[QAbstractItemModel](modelPtr)
  result = model.hasChildren(newQModelIndex(parent, Ownership.Clone))

method canFetchMore*(self: QAbstractItemModel, parent: QModelIndex): bool {.base.} =
  return dos_qabstractitemmodel_canFetchMore(self.vptr.DosQAbstractItemModel, parent.vptr.DosQModelIndex)

proc canFetchMoreCallback(modelPtr: pointer, parent: DosQModelIndex, result: var bool) {.cdecl, exportc.} =
  let model = cast[QAbstractItemModel](modelPtr)
  result = model.canFetchMore(newQModelIndex(parent, Ownership.Clone))

method fetchMore*(self: QAbstractItemModel, parent: QModelIndex) {.base.} =
  dos_qabstractitemmodel_fetchMore(self.vptr.DosQAbstractItemModel, parent.vptr.DosQModelIndex)

proc fetchMoreCallback(modelPtr: pointer, parent: DosQModelIndex) {.cdecl, exportc.} =
  let model = cast[QAbstractItemModel](modelPtr)
  model.fetchMore(newQModelIndex(parent, Ownership.Clone))

method onSlotCalled*(self: QAbstractItemModel, slotName: string, arguments: openarray[QVariant]) =
  ## Called from the dotherside library when a slot is called from Qml.
  discard

proc setup*(self: QAbstractItemModel) =
  ## Setup a new QAbstractItemModel
  debugMsg("QAbstractItemModel", "setup")

  let qaimCallbacks = DosQAbstractItemModelCallbacks(rowCount: rowCountCallback,
  columnCount: columnCountCallback,
  data: dataCallback,
  setData: setDataCallback,
  roleNames: roleNamesCallback,
  flags: flagsCallback,
  headerData: headerDataCallback,
  index: indexCallback,
  parent: parentCallback,
  hasChildren: hasChildrenCallback,
  canFetchMore: canFetchMoreCallback,
  fetchMore: fetchMoreCallback)

  self.vptr = dos_qabstractitemmodel_create(addr(self[]), self.metaObject.vptr,
                                            qobjectCallback, qaimCallbacks).DosQObject

proc delete*(self: QAbstractItemModel) =
  ## Delete the given QAbstractItemModel
  debugMsg("QAbstractItemModel", "delete")
  self.QObject.delete()

proc newQAbstractItemModel*(): QAbstractItemModel =
  ## Return a new QAbstractItemModel
  debugMsg("QAbstractItemModel", "new")
  new(result, delete)
  result.setup()

proc hasIndex*(self: QAbstractItemModel, row: int, column: int, parent: QModelIndex): bool =
  debugMsg("QAbstractItemModel", "hasIndex")
  dos_qabstractitemmodel_hasIndex(self.vptr.DosQAbstractItemModel, row.cint, column.cint, parent.vptr.DosQModelIndex)

proc beginInsertRows*(self: QAbstractItemModel, parentIndex: QModelIndex, first: int, last: int) =
  ## Notify the view that the model is about to inserting the given number of rows
  debugMsg("QAbstractItemModel", "beginInsertRows")
  dos_qabstractitemmodel_beginInsertRows(self.vptr.DosQAbstractItemModel, parentIndex.vptr, first.cint, last.cint)

proc endInsertRows*(self: QAbstractItemModel) =
  ## Notify the view that the rows have been inserted
  debugMsg("QAbstractItemModel", "endInsertRows")
  dos_qabstractitemmodel_endInsertRows(self.vptr.DosQAbstractItemModel)

proc beginRemoveRows*(self: QAbstractItemModel, parentIndex: QModelIndex, first: int, last: int) =
  ## Notify the view that the model is about to remove the given number of rows
  debugMsg("QAbstractItemModel", "beginRemoveRows")
  dos_qabstractitemmodel_beginRemoveRows(self.vptr.DosQAbstractItemModel, parentIndex.vptr, first.cint, last.cint)

proc endRemoveRows*(self: QAbstractItemModel) =
  ## Notify the view that the rows have been removed
  debugMsg("QAbstractItemModel", "endRemoveRows")
  dos_qabstractitemmodel_endRemoveRows(self.vptr.DosQAbstractItemModel)

proc beginInsertColumns*(self: QAbstractItemModel, parentIndex: QModelIndex, first: int, last: int) =
  ## Notify the view that the model is about to inserting the given number of columns
  debugMsg("QAbstractItemModel", "beginInsertColumns")
  dos_qabstractitemmodel_beginInsertColumns(self.vptr.DosQAbstractItemModel, parentIndex.vptr, first.cint, last.cint)

proc endInsertColumns*(self: QAbstractItemModel) =
  ## Notify the view that the rows have been inserted
  debugMsg("QAbstractItemModel", "endInsertColumns")
  dos_qabstractitemmodel_endInsertColumns(self.vptr.DosQAbstractItemModel)

proc beginRemoveColumns*(self: QAbstractItemModel, parentIndex: QModelIndex, first: int, last: int) =
  ## Notify the view that the model is about to remove the given number of columns
  debugMsg("QAbstractItemModel", "beginRemoveColumns")
  dos_qabstractitemmodel_beginRemoveColumns(self.vptr.DosQAbstractItemModel, parentIndex.vptr, first.cint, last.cint)

proc endRemoveColumns*(self: QAbstractItemModel) =
  ## Notify the view that the columns have been removed
  debugMsg("QAbstractItemModel", "endRemoveColumns")
  dos_qabstractitemmodel_endRemoveColumns(self.vptr.DosQAbstractItemModel)

proc beginResetModel*(self: QAbstractItemModel) =
  ## Notify the view that the model is about to resetting
  debugMsg("QAbstractItemModel", "beginResetModel")
  dos_qabstractitemmodel_beginResetModel(self.vptr.DosQAbstractItemModel)

proc endResetModel*(self: QAbstractItemModel) =
  ## Notify the view that model has finished resetting
  debugMsg("QAbstractItemModel", "endResetModel")
  dos_qabstractitemmodel_endResetModel(self.vptr.DosQAbstractItemModel)

proc dataChanged*(self: QAbstractItemModel,
                 topLeft: QModelIndex,
                 bottomRight: QModelIndex,
                 roles: openArray[int]) =
  ## Notify the view that the model data changed
  debugMsg("QAbstractItemModel", "dataChanged")
  var copy: seq[cint]
  for i in roles:
    copy.add(i.cint)
  dos_qabstractitemmodel_dataChanged(self.vptr.DosQAbstractItemModel, topLeft.vptr,
                                     bottomRight.vptr, copy[0].addr, copy.len.cint)
