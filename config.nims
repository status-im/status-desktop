if defined(release):
  switch("nimcache", "nimcache/release/$projectName")
else:
  switch("nimcache", "nimcache/debug/$projectName")

--threads:on
--opt:speed # -O3
--debugger:native # passes "-g" to the C compiler
--define:ssl # needed by the stdlib to enable SSL procedures

if defined(macosx):
  --dynlibOverrideAll # don't use dlopen()
  --tlsEmulation:off
  switch("passL", "-lstdc++")
  # DYLD_LIBRARY_PATH doesn't always work when running/packaging so set rpath
  # note: macdeployqt rewrites rpath appropriately when building the .app bundle
  switch("passL", "-rpath" & " " & getEnv("QT5_LIBDIR"))
  switch("passL", "-rpath" & " " & getEnv("STATUSGO_LIBDIR"))
  switch("passL", "-rpath" & " " & getEnv("STATUSKEYCARDGO_LIBDIR"))
  # statically link these libs
  switch("passL", "bottles/openssl@1.1/lib/libcrypto.a")
  switch("passL", "bottles/openssl@1.1/lib/libssl.a")
  switch("passL", "bottles/pcre/lib/libpcre.a")
  # https://code.videolan.org/videolan/VLCKit/-/issues/232
  switch("passL", "-Wl,-no_compact_unwind")
  # set the minimum supported macOS version to 12.0
  switch("passC", "-mmacosx-version-min=12.0")
elif defined(windows):
  --app:gui
  --tlsEmulation:off
  switch("passL", "-Wl,-as-needed")
else:
  --dynlibOverrideAll # don't use dlopen()
  # dynamically link these libs, since we're opting out of dlopen()
  switch("passL", "-l:libcrypto.so.1.1")
  switch("passL", "-l:libssl.so.1.1")
  # don't link libraries we're not actually using
  switch("passL", "-Wl,-as-needed")

--define:chronicles_line_numbers # useful when debugging=
switch("define", "chronicles_timestamps=RfcUtcTime")

# The compiler doth protest too much, methinks, about all these cases where it can't
# do its (N)RVO pass: https://github.com/nim-lang/RFCs/issues/230
switch("warning", "ObservableStores:off")

# Too many false positives for "Warning: method has lock level <unknown>, but another method has 0 [LockLevel]"
switch("warning", "LockLevel:off")

# No clean workaround for this warning in certain cases, waiting for better upstream support
switch("warning", "BareExcept:off")

# We assume this as a good practive to keep `else` even if all cases are covered
switch("warning", "UnreachableElse:off")

# Those are popular to miss in our app, and quickly make build log unreadable, so we want to prevent them
switch("warningAsError", "UseBase:on")
switch("warningAsError", "UnusedImport:on")
switch("warningAsError", "Deprecated:on")
switch("warningAsError", "HoleEnumConv:on")

# Workaround for https://github.com/nim-lang/Nim/issues/23429
switch("warning", "UseBase:on")
switch("warning", "UnusedImport:on")
switch("warning", "Deprecated:on")
switch("warning", "HoleEnumConv:on")

when defined(gcc):
  # GCC 14+ introduces new strictness for pointer types that not all nim libraries are compatible with
  switch("passc", "-Wno-error=incompatible-pointer-types")

