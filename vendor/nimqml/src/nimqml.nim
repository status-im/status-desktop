## NimQml aims to provide binding to the QML for the Nim programming language

template debugMsg(message: string) =
  echo "NimQml: ", message

template debugMsg(typeName: string, procName: string) =
  when defined(debugNimQml):
    var message = typeName
    message &= ": "
    message &= procName
    debugMsg(message)

import os

include "nimqml/private/dotherside.nim"
include "nimqml/private/nimqmltypes.nim"
include "nimqml/private/qmetaobject.nim"
include "nimqml/private/qnetworkconfigurationmanager.nim"
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
include "nimqml/private/singleinstance.nim"


proc signal_handler*(receiver: pointer, signal: cstring, slot: cstring) =
  var dosqobj = cast[DosQObject](receiver)
  if(dosqobj.isNil == false):
    dos_signal(receiver, signal, slot)

proc image_resizer*(imagePath: string, maxSize: int = 2000, tmpDir: string): string =
  discard existsOrCreateDir(tmpDir)
  result = $dos_image_resizer(imagePath.cstring, maxSize.cint, tmpDir)

proc plain_text*(htmlString: string): string =
  result = $(dos_plain_text(htmlString.cstring))

proc escape_html*(input: string): string =
  result = $(dos_escape_html(input.cstring))

proc url_fromUserInput*(input: string): string =
  result = $(dos_qurl_fromUserInput(input.cstring))

proc url_host*(host: string): string =
  result = $(dos_qurl_host(host.cstring))

proc url_replaceHostAndAddPath*(url: string, newHost: string, protocol: string = "", pathPrefix: string = ""): string =
  result = $(dos_qurl_replaceHostAndAddPath(url.cstring, protocol.cstring, newHost.cstring, pathPrefix.cstring))
