proc setup*(variant: QVariant) =
  ## Setup a new QVariant
  variant.vptr = dos_qvariant_create()

proc setup*(variant: QVariant, value: int | int32 | int64) =
  ## Setup a new QVariant given a cint value
  variant.vptr =
    when sizeof(value) == sizeof(cint):
      dos_qvariant_create_int(value.cint)
    else:
      dos_qvariant_create_longlong(value.clonglong)

proc setup*(variant: QVariant, value: uint | uint32 | uint64) =
  ## Setup a new QVariant given a cint value
  variant.vptr =
    when sizeof(value) == sizeof(cuint):
      dos_qvariant_create_uint(value.cuint)
    else:
      dos_qvariant_create_ulonglong(value.culonglong)

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

proc newQVariant*(value: int | int32 | int64 | uint | uint32 | uint64): QVariant =
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
  when sizeof(result) == sizeof(cint):
    dos_qvariant_toInt(variant.vptr).int
  else:
    dos_qvariant_toLongLong(variant.vptr).int

proc `intVal=`*(variant: QVariant, value: int) =
  ## Sets the QVariant value int value
  when sizeof(value) == sizeof(cint):
    dos_qvariant_setInt(variant.vptr, value.cint)
  else:
    dos_qvariant_setLongLong(variant.vptr, value.clonglong)

proc int32Val*(variant: QVariant): int32 =
  ## Return the QVariant value as int
  dos_qvariant_toInt(variant.vptr).int32

proc `int32Val=`*(variant: QVariant, value: int32) =
  ## Sets the QVariant value int value
  dos_qvariant_setInt(variant.vptr, value.cint)

proc int64Val*(variant: QVariant): int64 =
  ## Return the QVariant value as int
  dos_qvariant_toLongLong(variant.vptr).int64

proc `int64Val=`*(variant: QVariant, value: int64) =
  ## Sets the QVariant value int value
  dos_qvariant_setLongLong(variant.vptr, value.clonglong)

proc uintVal*(variant: QVariant): uint =
  ## Return the QVariant value as int
  when sizeof(result) == sizeof(cuint):
    dos_qvariant_toUInt(variant.vptr).uint
  else:
    dos_qvariant_toULongLong(variant.vptr).uint

proc `uintVal=`*(variant: QVariant, value: uint) =
  ## Sets the QVariant value uint value
  when sizeof(value) == sizeof(cuint):
    dos_qvariant_setUInt(variant.vptr, value.cuint)
  else:
    dos_qvariant_setULongLong(variant.vptr, value.culonglong)

proc uint32Val*(variant: QVariant): uint32 =
  ## Return the QVariant value as int
  dos_qvariant_toUInt(variant.vptr).uint32

proc `uint32Val=`*(variant: QVariant, value: uint32) =
  ## Sets the QVariant value int value
  var rawValue = value.culonglong
  dos_qvariant_setUInt(variant.vptr, value.cuint)

proc uint64Val*(variant: QVariant): uint64 =
  ## Return the QVariant value as int
  dos_qvariant_toULongLong(variant.vptr).uint64

proc `uint64Val=`*(variant: QVariant, value: uint64) =
  ## Sets the QVariant value int value
  dos_qvariant_setULongLong(variant.vptr, value.culonglong)

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
