import chronicles
include ../../common/json_utils
include ../../../app/core/tasks/common

type
  AsyncLoadDevicesTaskArg = ref object of QObjectTaskArg

type
  AsyncInputConnectionStringArg = ref object of QObjectTaskArg
    connectionString: string
    configJSON: string

const asyncLoadDevicesTask: Task = proc(argEncoded: string) {.gcsafe, nimcall.} =
  let arg = decode[AsyncLoadDevicesTaskArg](argEncoded)
  let response = status_installations.getOurInstallations()
  arg.finish(response)

const asyncInputConnectionStringTask: Task = proc(argEncoded: string) {.gcsafe, nimcall.} =
  let arg = decode[AsyncInputConnectionStringArg](argEncoded)
  try: 
    let response = status_go.inputConnectionStringForBootstrapping(arg.connectionString, arg.configJSON)
    arg.finish(response)
  except Exception as e:
    error "inputConnectionStringForBootstrapping failed", errorMessage = e.msg
    arg.finish(%* {
      "error": "unexpected error occured: " & e.msg
    })

const asyncInputConnectionStringForImportingKeystoreTask: Task = proc(argEncoded: string) {.gcsafe, nimcall.} =
  let arg = decode[AsyncInputConnectionStringArg](argEncoded)
  let response = status_go.inputConnectionStringForImportingKeypairsKeystores(arg.connectionString, arg.configJSON)
  arg.finish(response)
