when defined(android):
  {.push dynlib: "", importc.}
  proc statusq_saf_takePersistablePermission*(treeUri: cstring) {.cdecl, importc: "statusq_saf_takePersistablePermission".}
  proc statusq_saf_copyFromPathToTree*(srcPath, treeUri, mime, displayName: cstring): cstring {.cdecl, importc: "statusq_saf_copyFromPathToTree".}
  proc free(p: pointer) {.importc, header: "<stdlib.h>".}
  {.pop.}

  proc safTakePersistablePermission*(treeUri: string) =
    statusq_saf_takePersistablePermission(treeUri.cstring)

  proc safCopyFromPathToTree*(srcPath, treeUri, mime, displayName: string): string =
    let cstr = statusq_saf_copyFromPathToTree(srcPath.cstring, treeUri.cstring, mime.cstring, displayName.cstring)
    if cstr.isNil:
      return ""
    defer: free(cstr)
    result = $cast[cstring](cstr)

else:
  # Stubs for non-Android builds
  proc safTakePersistablePermission*(treeUri: string) = discard
  proc safCopyFromPathToTree*(srcPath, treeUri, mime, displayName: string): string = ""
