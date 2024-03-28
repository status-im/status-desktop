include ../../common/json_utils
include ../../../app/core/tasks/common

type
  AsyncLoadDevicesTaskArg = ref object of QObjectTaskArg

type
  AsyncInputConnectionStringArg = ref object of QObjectTaskArg
    connectionString: string
    configJSON: string

proc asyncLoadDevicesTask(argEncoded: string) {.gcsafe, nimcall.} =
  let arg = decode[AsyncLoadDevicesTaskArg](argEncoded)
  let response = status_installations.getOurInstallations()
  arg.finish(response)

proc asyncInputConnectionStringTask(argEncoded: string) {.gcsafe, nimcall.} =
  let arg = decode[AsyncInputConnectionStringArg](argEncoded)
  let response = status_go.inputConnectionStringForBootstrapping(arg.connectionString, arg.configJSON)
  arg.finish(response)

proc asyncInputConnectionStringForImportingKeystoreTask(argEncoded: string) {.gcsafe, nimcall.} =
  let arg = decode[AsyncInputConnectionStringArg](argEncoded)
  let response = status_go.inputConnectionStringForImportingKeypairsKeystores(arg.connectionString, arg.configJSON)
  arg.finish(response)
