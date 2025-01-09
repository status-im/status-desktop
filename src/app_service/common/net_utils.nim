import net

# Util function to test if a port is busy
proc isPortBusy*(port: Port): bool =
  result = false
  let socket = newSocket()
  defer:
    socket.close()

  try:
    socket.connect("localhost", port)
    result = true
  except OSError:
    result = false
