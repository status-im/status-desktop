from os import getAppDir, joinPath, commandLineParams
from winlean import Handle, shellExecuteW

proc restoreParamsString(strings: seq[string]): string =
  result = ""
  for str in strings:
    result = result & " " & str

const NULL: Handle = 0
let launcherDir = getAppDir()
let workDir_str = joinPath(launcherDir, "bin")
let exePath_str = joinPath(workDir_str, "Status.exe")
let open_str = "open"
let params_str = restoreParamsString(commandLineParams())
let workDir = newWideCString(workDir_str)
let exePath = newWideCString(exePath_str)
let open = newWideCString(open_str)
let params = newWideCString(params_str)
# SW_SHOW (5): activates window and displays it in its current size and position
const showCmd: int32 = 5


discard shellExecuteW(NULL, open, exePath, params, workDir, showCmd)
