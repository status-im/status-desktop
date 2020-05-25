when defined(macosx):
  import algorithm, strutils

if defined(release):
  switch("nimcache", "nimcache/release/$projectName")
else:
  switch("nimcache", "nimcache/debug/$projectName")

proc linkLib(name: string): string =
  var resLib = name

  when defined(macosx):
    # In macOS Catalina, unversioned libraries may be broken stubs, so we need to
    # find a versioned one: https://github.com/status-im/nim-status-client/pull/209
    var matches: seq[string]
    for path in listFiles("/usr/lib"):
      # /usr/lib/libcrypto.0.9.8.dylib
      let file = path[9..^1]
      # libcrypto.0.9.8.dylib
      if file.startsWith("lib" & name) and file != "lib" & name & ".dylib":
        matches.add(path)
    matches.sort(order = SortOrder.Descending)
    if matches.len > 0:
      resLib = matches[0]
      # Passing "/usr/lib/libcrypto.44.dylib" directly to the linker works for
      # dynamic linking.
      return resLib

  return "-l" & resLib

--threads:on
--opt:speed # -O3
--debugger:native # passes "-g" to the C compiler
--dynliboverrideall # don't use dlopen()
--define:ssl # needed by the stdlib to enable SSL procedures

if defined(macosx):
  # DYLD_LIBRARY_PATH doesn't seem to work with Qt5
  switch("passL", "-rpath" & " " & getEnv("QT5_LIBDIR"))
  switch("passL", "-lstdc++")
  # dynamically link these libs, since we're opting out of dlopen()
  switch("passL", linkLib("crypto"))
  switch("passL", linkLib("ssl"))
  # https://code.videolan.org/videolan/VLCKit/-/issues/232
  switch("passL", "-Wl,-no_compact_unwind")
else:
  switch("passL", linkLib("crypto") & " " & linkLib("ssl")) # dynamically link these libs, since we're opting out of dlopen()
  switch("passL", "-Wl,-as-needed") # don't link libraries we're not actually using

--define:chronicles_line_numbers # useful when debugging

