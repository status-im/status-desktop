import tables

var ctorTable = initTable[cint, proc(): QObject]()

proc creator(id: cint, wrapper: DosQObjectWrapper, nimQObject: var NimQObject, dosQObject: var DosQObject) {.cdecl.} =
  let qobject: QObject = ctorTable[id]()
  GC_ref(qobject)
  nimQObject = addr(qobject[])
  dosQObject = qobject.vptr
  # Swap the dosQObject and
  qobject.vptr = wrapper.DosQObject
  qobject.owner = false

proc deleter(id: cint, nimQObject: NimQObject) {.cdecl.} =
  let qobject = cast[QObject](nimQObject)
  GC_unref(qobject)

proc qmlRegisterType*[T](uri: string, major: int, minor: int, qmlName: string, ctor: proc(): T): int =
  let metaObject: QMetaObject = T.staticMetaObject()
  var dosQmlRegisterType = DosQmlRegisterType(major: major.cint, minor: minor.cint, uri: uri.cstring,
                                              qml: qmlName.cstring, staticMetaObject: metaObject.vptr,
                                              createCallback: creator, deleteCallback: deleter)
  let id = dos_qdeclarative_qmlregistertype(dosQmlRegisterType.unsafeAddr)
  ctorTable[id] = proc(): QObject = ctor().QObject
  id.int

proc qmlRegisterSingletonType*[T](uri: string, major: int, minor: int, qmlName: string, ctor: proc(): T): int =
  let metaObject: QMetaObject = T.staticMetaObject()
  var dosQmlRegisterType = DosQmlRegisterType(major: major.cint, minor: minor.cint, uri: uri.cstring,
                                              qml: qmlName.cstring, staticMetaObject: metaObject.vptr,
                                              createCallback: creator, deleteCallback: deleter)
  let id = dos_qdeclarative_qmlregistersingletontype(dosQmlRegisterType.unsafeAddr)
  ctorTable[id] = proc(): QObject = ctor().QObject
  id.int
