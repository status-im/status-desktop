proc setup*(self: QModelIndex) =
  ## Setup a new QModelIndex
  self.vptr = dos_qmodelindex_create()

proc setup(self: QModelIndex, other: DosQModelIndex, takeOwnership: Ownership) =
  ## Setup a new QModelIndex
  self.vptr = if takeOwnership == Ownership.Take: other else: dos_qmodelindex_create_qmodelindex(other)

proc delete*(self: QModelIndex) =
  ## Delete the given QModelIndex
  if not self.vptr.isNil:
    return
  debugMsg("QModelIndex", "delete")
  dos_qmodelindex_delete(self.vptr)
  self.vptr.resetToNil

proc newQModelIndex*(): QModelIndex =
  ## Return a new QModelIndex
  new(result, delete)
  result.setup()

proc newQModelIndex(vptr: DosQModelIndex, takeOwnership: Ownership): QModelIndex =
  ## Return a new QModelIndex given a raw index
  new(result, delete)
  result.setup(vptr, takeOwnership)

proc row*(self: QModelIndex): int =
  ## Return the index row
  dos_qmodelindex_row(self.vptr).int

proc column*(self: QModelIndex): int =
  ## Return the index column
  dos_qmodelindex_column(self.vptr).int

proc isValid*(self: QModelIndex): bool =
  ## Return true if the index is valid, false otherwise
  dos_qmodelindex_isValid(self.vptr)

proc data*(self: QModelIndex, role: cint): QVariant =
  ## Return the model data associated to the given role
  newQVariant(dos_qmodelindex_data(self.vptr, role), Ownership.Take)

proc parent*(self: QModelIndex): QModelIndex =
  ## Return the parent index
  newQModelIndex(dos_qmodelindex_parent(self.vptr), Ownership.Take)

proc child*(self: QModelIndex, row: cint, column: cint): QModelIndex =
  ## Return the child index associated to the given row and column
  newQModelIndex(dos_qmodelindex_child(self.vptr, row, column), Ownership.Take)

proc sibling*(self: QModelIndex, row: cint, column: cint): QModelIndex =
  ## Return the sibling index associated to the given row and column
  newQModelIndex(dos_qmodelindex_sibling(self.vptr, row, column), Ownership.Take)

proc internalPointer(self: QModelIndex): pointer =
  ## Return the internal pointer
  dos_qmodelindex_internalPointer(self.vptr)
