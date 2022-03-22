import Tables, json, sequtils, chronicles
import sets
import result
import options
include ../../common/json_utils
import ../../../backend/permissions as status_go
import dto/dapp
import dto/permission

export dapp
export permission

logScope:
  topics = "dapp-permissions-service"

type
  Service* = ref object
    dapps: Table[string, Dapp]

type R = Result[Dapp, string]

proc delete*(self: Service) =
  discard

proc newService*(): Service =
  result = Service()
  result.dapps = initTable[string, Dapp]()

proc init*(self: Service) =
  try:
    let response = status_go.getDappPermissions()
    for dapp in response.result.getElems().mapIt(it.toDapp()):
      if dapp.address == "":
        continue

      self.dapps[dapp.name & dapp.address] = dapp
  except Exception as e:
    let errDescription = e.msg
    error "error: ", errDescription

proc getDapps*(self: Service): seq[Dapp] =
  return toSeq(self.dapps.values)

proc getDapp*(self: Service, name: string, address: string): Option[Dapp] =
  let key = name & address
  if self.dapps.hasKey(key):
    return some(self.dapps[key])

  return none(Dapp)

proc addPermission*(self: Service, name: string, address: string, permission: Permission): R =
  let key = name & address

  try:
    if not self.dapps.hasKey(key):
      self.dapps[key] = Dapp(
        name: name,
        address: address,
        permissions: initHashSet[Permission]()
      )

    self.dapps[key].permissions.incl(permission)
    let permissions = self.dapps[key].permissions.toSeq().mapIt($it)
    discard status_go.addDappPermissions(name, address, permissions)
    result.ok self.dapps[key]
  except Exception as e:
    let errDescription = e.msg
    error "error: ", errDescription
    result.err errDescription


proc hasPermission*(self: Service, dapp: string, address: string, permission: Permission): bool =
  let key = dapp & address
  if not self.dapps.hasKey(key):
    return false
  return self.dapps[key].permissions.contains(permission)

proc disconnect*(self: Service, dappName: string): bool =
  try:
    var addresses: seq[string] = @[]
    for dapp in self.dapps.values:
      if dapp.name != dappName:
        continue

      discard status_go.deleteDappPermissions(dapp.name, dapp.address)
      addresses.add(dapp.address)

    for address in addresses:
      self.dapps.del(dappName & address)

    return true  
  except Exception as e:
    let errDescription = e.msg
    error "error: ", errDescription

proc disconnectAddress*(self: Service, dappName: string, address: string): bool =
  let key = dappName & address
  if not self.dapps.hasKey(key):
      return

  try:
    discard status_go.deleteDappPermissions(dappName, address)
    self.dapps.del(key)
    return true
  except Exception as e:
    let errDescription = e.msg
    error "error: ", errDescription

proc removePermission*(self: Service, name: string, address: string, permission: Permission): bool =
  let key = name & address
  if not self.dapps.hasKey(key):
      return

  try:  
    if self.dapps[key].permissions.contains(permission):
      self.dapps[key].permissions.excl(permission)
      if self.dapps[key].permissions.len > 0:
        discard status_go.addDappPermissions(name, address, self.dapps[key].permissions.toSeq().mapIt($it))
      else:
        discard status_go.deleteDappPermissions(name, address)
        self.dapps.del(key)
    return true
  except Exception as e:
    let errDescription = e.msg
    error "error: ", errDescription