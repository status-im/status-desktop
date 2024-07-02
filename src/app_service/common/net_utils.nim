import net

# Util function to test if a port is busy
proc isPortBusy*(port: Port): bool =
  var sock: Socket
  try:
    sock = newSocket()
    sock.setSockOpt(OptReuseAddr, true)
    sock.bindAddr(port)
    sock.close()
    return false
  except OSError:
    return true