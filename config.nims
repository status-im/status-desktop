when defined(macosx):
  import algorithm, strutils

if defined(release):
  switch("nimcache", "nimcache/release/$projectName")
else:
  switch("nimcache", "nimcache/debug/$projectName")

--threads:on
--opt:speed # -O3
--debugger:native # passes "-g" to the C compiler
--dynliboverrideall # don't use dlopen()
--define:ssl # needed by the stdlib to enable SSL procedures

if defined(macosx):
  --tlsEmulation:off
  switch("passL", "-lstdc++")
  # DYLD_LIBRARY_PATH doesn't seem to work with Qt5
  switch("passL", "-rpath" & " " & getEnv("QT5_LIBDIR"))
  # statically linke these libs
  switch("passL", "bottles/openssl/lib/libcrypto.a")
  switch("passL", "bottles/openssl/lib/libssl.a")
  switch("passL", "bottles/pcre/lib/libpcre.a")
  # https://code.videolan.org/videolan/VLCKit/-/issues/232
  switch("passL", "-Wl,-no_compact_unwind")
  # set the minimum supported macOS version to 10.13
  switch("passC", "-mmacosx-version-min=10.13")
else:
  # dynamically link these libs, since we're opting out of dlopen()
  switch("passL", "-lcrypto")
  switch("passL", "-lssl")
  # don't link libraries we're not actually using
  switch("passL", "-Wl,-as-needed")

--define:chronicles_line_numbers # useful when debugging
