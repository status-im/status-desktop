# Package

version       = "0.1.0"
author        = "Richard Ramos"
description   = "A new awesome nimble package"
license       = "MIT"
srcDir        = "src"
bin           = @["nim_status_client"]
skipExt       = @["nim"]

# Deps

requires "nim >= 1.0.0", " nimqml >= 0.7.0", "stint", "nimcrypto >= 0.4.11", "uuids >= 0.1.10"
