import Tables, json, sequtils, chronicles
import sets
import result
import options
include ../../common/json_utils
import service_interface
import status/statusgo_backend_new/permissions as status_go
import dto/dapp
import dto/permission
export service_interface

logScope:
  topics = "dapp-permissions-service"

type 
  Service* = ref object of ServiceInterface
    dapps: Table[string, Dapp]

type R = Result[Dapp, string]

method delete*(self: Service) =
  discard

proc newService*(): Service =
  result = Service()
  result.dapps = initTable[string, Dapp]()

method init*(self: Service) =
  try:
    let response = status_go.getDappPermissions()
    for dapp in response.result.getElems().mapIt(it.toDapp()):
      self.dapps[dapp.name] = dapp
  except Exception as e:
    let errDescription = e.msg
    error "error: ", errDescription

method getDapps*(self: Service): seq[Dapp] =
  return toSeq(self.dapps.values)

method getDapp*(self: Service, dapp: string): Option[Dapp] =
  if self.dapps.hasKey(dapp):
    return some(self.dapps[dapp])
  return none(Dapp)

method clearPermissions*(self: Service, dapp: string): bool =
  try:
    if not self.dapps.hasKey(dapp):
      return
    discard status_go.deleteDappPermissions(dapp)
    self.dapps.del(dapp)
    return true
  except Exception as e:
    let errDescription = e.msg
    error "error: ", errDescription

method revoke*(self: Service, permission: Permission): bool =
  try:
    for dapp in self.dapps.mvalues:
      if dapp.permissions.contains(permission):
        dapp.permissions.excl(permission)
        if dapp.permissions.len > 0:
          discard status_go.addDappPermissions(dapp.name, dapp.permissions.toSeq().mapIt($it))
        else:
          discard status_go.deleteDappPermissions(dapp.name)
          self.dapps.del(dapp.name)
    return true
  except Exception as e:
    let errDescription = e.msg
    error "error: ", errDescription

method revoke*(self: Service, dapp: string, permission: Permission): bool =
  try:
    if not self.dapps.hasKey(dapp):
      return

    if self.dapps[dapp].permissions.contains(permission):
      self.dapps[dapp].permissions.excl(permission)
      if self.dapps[dapp].permissions.len > 0:
        discard status_go.addDappPermissions(dapp, self.dapps[dapp].permissions.toSeq().mapIt($it))
      else:
        discard status_go.deleteDappPermissions(dapp)
        self.dapps.del(dapp)
    return true
  except Exception as e:
    let errDescription = e.msg
    error "error: ", errDescription

method addPermission*(self: Service, dapp: string, permission: Permission): R =
  try:
    if not self.dapps.hasKey(dapp):
      result.err "not found"
      return

    self.dapps[dapp].permissions.incl(permission)
    discard status_go.addDappPermissions(dapp, self.dapps[dapp].permissions.toSeq().mapIt($it))
    result.ok self.dapps[dapp]
  except Exception as e:
    let errDescription = e.msg
    error "error: ", errDescription
    result.err errDescription

method revokeAllPermisions*(self: Service): bool =
  try:
    for d in self.dapps.values:
      discard status_go.deleteDappPermissions(d.name)
    self.dapps.clear()
    return true
  except Exception as e:
    let errDescription = e.msg
    error "error: ", errDescription

method hasPermission*(self: Service, dapp: string, permission: Permission): bool =
  if not self.dapps.hasKey(dapp):
    return false
  return self.dapps[dapp].permissions.contains(permission)
