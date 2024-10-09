# Declarations of methods exposed from StatusQ

proc statusq_registerQmlTypes*() {.cdecl, importc.}
proc statusq_isCompressedPubKey*(strPubKey: cstring): bool {.cdecl, importc.}
