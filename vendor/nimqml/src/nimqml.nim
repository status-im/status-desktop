## NimQml aims to provide binding to the QML for the Nim programming language

template debugMsg(message: string) =
  echo "NimQml: ", message

template debugMsg(typeName: string, procName: string) =
  when defined(debugNimQml):
    var message = typeName
    message &= ": "
    message &= procName
    debugMsg(message)

include "nimqml/private/dotherside.nim"
include "nimqml/private/nimqmltypes.nim"
include "nimqml/private/qmetaobject.nim"
include "nimqml/private/qvariant.nim"
include "nimqml/private/qobject.nim"
include "nimqml/private/qqmlapplicationengine.nim"
include "nimqml/private/qcoreapplication.nim"
include "nimqml/private/qguiapplication.nim"
include "nimqml/private/qapplication.nim"
include "nimqml/private/qurl.nim"
include "nimqml/private/qquickview.nim"
include "nimqml/private/qhashintbytearray.nim"
include "nimqml/private/qmodelindex.nim"
include "nimqml/private/qabstractitemmodel.nim"
include "nimqml/private/qabstractlistmodel.nim"
include "nimqml/private/qabstracttablemodel.nim"
include "nimqml/private/qresource.nim"
include "nimqml/private/qdeclarative.nim"
include "nimqml/private/nimqmlmacros.nim"

proc signal_handler*(receiver: pointer, signal: cstring, slot: cstring) =
  var dosqobj = cast[DosQObject](receiver)
  if(dosqobj.isNil == false):
    dos_signal(receiver, signal, slot)
