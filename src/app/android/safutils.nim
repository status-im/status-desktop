when defined(android):
  {.push dynlib: "", importc.}
  proc statusq_saf_takePersistablePermission*(treeUri: cstring) {.cdecl, importc: "statusq_saf_takePersistablePermission".}
  proc statusq_saf_createFileInTree*(treeUri, mime, displayName: cstring): cstring {.cdecl, importc: "statusq_saf_createFileInTree".}
  proc statusq_saf_writeBytesToUri*(documentUri: cstring, data: pointer, length: cint): bool {.cdecl, importc: "statusq_saf_writeBytesToUri".}
  proc statusq_saf_openWritableFd*(documentUri: cstring): cint {.cdecl, importc: "statusq_saf_openWritableFd".}
  proc statusq_saf_copyFromPathToTree*(srcPath, treeUri, mime, displayName: cstring): cstring {.cdecl, importc: "statusq_saf_copyFromPathToTree".}
  {.pop.}

  proc safTakePersistablePermission*(treeUri: string) =
    statusq_saf_takePersistablePermission(treeUri.cstring)

  proc safCreateFileInTree*(treeUri, mime, displayName: string): string =
    let cstr = statusq_saf_createFileInTree(treeUri.cstring, mime.cstring, displayName.cstring)
    if cstr.isNil:
      return ""
    # Copy into Nim string, then free the C allocation
    result = $cast[cstring](cstr)
    when declared(free):
      free(cast[pointer](cstr))

  proc safWriteBytesToUri*(documentUri: string, data: openArray[byte]): bool =
    if data.len == 0:
      return false
    return statusq_saf_writeBytesToUri(documentUri.cstring, unsafeAddr data[0], cint(data.len))

  proc safOpenWritableFd*(documentUri: string): int =
    return int(statusq_saf_openWritableFd(documentUri.cstring))

  proc safCopyFromPathToTree*(srcPath, treeUri, mime, displayName: string): string =
    let cstr = statusq_saf_copyFromPathToTree(srcPath.cstring, treeUri.cstring, mime.cstring, displayName.cstring)
    if cstr.isNil:
      return ""
    result = $cast[cstring](cstr)
    when declared(free):
      free(cast[pointer](cstr))

else:
  # Stubs for non-Android builds
  proc safTakePersistablePermission*(treeUri: string) = discard
  proc safCreateFileInTree*(treeUri, mime, displayName: string): string = ""
  proc safWriteBytesToUri*(documentUri: string, data: openArray[byte]): bool = false
  proc safOpenWritableFd*(documentUri: string): int = -1
