let qAbstractTableModelStaticMetaObjectInstance = newQAbstractTableModelMetaObject()

proc staticMetaObject*(c: type QAbstractTableModel): QMetaObject =
  ## Return the metaObject of QAbstractTableModel
  qAbstractTableModelStaticMetaObjectInstance

proc staticMetaObject*(self: QAbstractTableModel): QMetaObject =
  ## Return the metaObject of QAbstractTableModel
  qAbstractTableModelStaticMetaObjectInstance

method metaObject*(self: QAbstractTableModel): QMetaObject =
  # Return the metaObject
  QAbstractTableModel.staticMetaObject

proc setup*(self: QAbstractTableModel) =
  ## Setup a new QAbstractTableModel
  debugMsg("QAbstractTableModel", "setup")

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

  self.vptr = dos_qabstracttablemodel_create(addr(self[]), self.metaObject.vptr,
                                            qobjectCallback, qaimCallbacks).DosQObject

proc delete*(self: QAbstractTableModel) =
  ## Delete the given QAbstractItemModel
  debugMsg("QAbstractItemModel", "delete")
  self.QObject.delete()

proc newQAbstractTableModel*(): QAbstractTableModel =
  ## Return a new QAbstractTableModel
  debugMsg("QAbstractTableModel", "new")
  new(result, delete)
  result.setup()

method parent(self: QAbstractTableModel, child: QModelIndex): QModelIndex =
  let indexPtr = dos_qabstracttablemodel_parent(self.vptr.DosQAbstractTableModel, child.vptr.DosQModelIndex)
  result = newQModelIndex(indexPtr, Ownership.Take)

method index*(self: QAbstractTableModel, row: int, column: int, parent: QModelIndex): QModelIndex =
  let indexPtr = dos_qabstracttablemodel_index(self.vptr.DosQAbstractTableModel, row.cint, column.cint, parent.vptr.DosQModelIndex)
  result = newQModelIndex(indexPtr, Ownership.Take)

