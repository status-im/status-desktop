proc setup*(variant: QVariant) =
  ## Setup a new QVariant
  variant.vptr = dos_qvariant_create()

proc setup*(variant: QVariant, value: int) =
  ## Setup a new QVariant given a cint value
  variant.vptr = dos_qvariant_create_int(value.cint)

proc setup*(variant: QVariant, value: bool) =
  ## Setup a new QVariant given a bool value
  variant.vptr = dos_qvariant_create_bool(value)

proc setup*(variant: QVariant, value: string) =
  ## Setup a new QVariant given a string value
  variant.vptr = dos_qvariant_create_string(value.cstring)

proc setup*(variant: QVariant, value: QObject) =
  ## Setup a new QVariant given a QObject
  variant.vptr = dos_qvariant_create_qobject(value.vptr)

proc setup*(variant: QVariant, value: DosQVariant, takeOwnership: Ownership) =
  ## Setup a new QVariant given another QVariant.
  ## The inner value of the QVariant is copied
  variant.vptr = if takeOwnership == Ownership.Take: value else: dos_qvariant_create_qvariant(value)

proc setup*(variant: QVariant, value: cfloat) =
  ## Setup a new QVariant given a cfloat value
  variant.vptr = dos_qvariant_create_float(value)

proc setup*(variant: QVariant, value: cdouble) =
  ## Setup a new QVariant given a cdouble value
  variant.vptr = dos_qvariant_create_double(value)

proc setup*(variant: QVariant, value: QVariant) =
  ## Setup a new QVariant given another QVariant.
  ## The inner value of the QVariant is copied
  setup(variant, value.vptr, Ownership.Clone)

proc delete*(variant: QVariant) =
  ## Delete a QVariant
  if variant.vptr.isNil:
    return
  debugMsg("QVariant", "delete")
  dos_qvariant_delete(variant.vptr)
  variant.vptr.resetToNil

proc newQVariant*(): QVariant =
  ## Return a new QVariant
  new(result, delete)
  result.setup()

proc newQVariant*(value: int): QVariant =
  ## Return a new QVariant given a cint
  new(result, delete)
  result.setup(value)

proc newQVariant*(value: bool): QVariant =
  ## Return a new QVariant given a bool
  new(result, delete)
  result.setup(value)

proc newQVariant*(value: string): QVariant =
  ## Return a new QVariant given a string
  new(result, delete)
  result.setup(value)

proc newQVariant*(value: QObject): QVariant =
  ## Return a new QVariant given a QObject
  new(result, delete)
  result.setup(value)

proc newQVariant(value: DosQVariant, takeOwnership: Ownership): QVariant =
  ## Return a new QVariant given a raw QVariant pointer
  new(result, delete)
  result.setup(value, takeOwnership)

proc newQVariant*(value: QVariant): QVariant =
  ## Return a new QVariant given another QVariant
  new(result, delete)
  result.setup(value)

proc newQVariant*(value: float): QVariant =
  ## Return a new QVariant given a float
  new(result, delete)
  result.setup(value.cfloat)

proc isNull*(variant: QVariant): bool =
  ## Return true if the QVariant value is null, false otherwise
  dos_qvariant_isnull(variant.vptr)

proc intVal*(variant: QVariant): int =
  ## Return the QVariant value as int
  dos_qvariant_toInt(variant.vptr).int

proc `intVal=`*(variant: QVariant, value: int) =
  ## Sets the QVariant value int value
  var rawValue = value.cint
  dos_qvariant_setInt(variant.vptr, rawValue)

proc boolVal*(variant: QVariant): bool =
  ## Return the QVariant value as bool
  dos_qvariant_toBool(variant.vptr)

proc `boolVal=`*(variant: QVariant, value: bool) =
  ## Sets the QVariant bool value
  dos_qvariant_setBool(variant.vptr, value)

proc floatVal*(variant: QVariant): float =
  ## Return the QVariant value as float
  dos_qvariant_toFloat(variant.vptr).float

proc `floatVal=`*(variant: QVariant, value: float) =
  ## Sets the QVariant float value
  dos_qvariant_setFloat(variant.vptr, value.cfloat)

proc doubleVal*(variant: QVariant): cdouble =
  ## Return the QVariant value as double
  dos_qvariant_toDouble(variant.vptr)

proc `doubleVal=`*(variant: QVariant, value: cdouble) =
  ## Sets the QVariant double value
  dos_qvariant_setDouble(variant.vptr, value)

proc stringVal*(variant: QVariant): string =
  ## Return the QVariant value as string
  var rawCString = dos_qvariant_toString(variant.vptr)
  result = $rawCString
  dos_chararray_delete(rawCString)

proc `stringVal=`*(variant: QVariant, value: string) =
  ## Sets the QVariant string value
  dos_qvariant_setString(variant.vptr, value)

proc `qobjectVal=`*(variant: QVariant, value: QObject) =
  ## Sets the QVariant qobject value
  dos_qvariant_setQObject(variant.vptr, value.vptr)

proc assign*(leftValue: QVariant, rightValue: QVariant) =
  ## Assign a QVariant with another. The inner value of the QVariant is copied
  dos_qvariant_assign(leftValue.vptr, rightValue.vptr)

proc toQVariantSequence(a: ptr DosQVariantArray, length: cint, takeOwnership: Ownership): seq[QVariant] =
  ## Convert an array of DosQVariant to a sequence of QVariant
  result = @[]
  for i in 0..<length:
    result.add(newQVariant(a[i], takeOwnership))

proc delete(a: openarray[QVariant]) =
  ## Delete an array of QVariants
  for x in a:
    x.delete
