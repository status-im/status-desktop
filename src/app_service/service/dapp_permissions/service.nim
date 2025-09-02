import Tables, json, sequtils, chronicles
import sets
import results
import options
include ../../common/json_utils
import ../../../backend/backend
import dto/dapp
import dto/permission

export dapp
export permission

logScope:
  topics = "dapp-permissions-service"

type
  Service* = ref object
    dapps: Table[string, Dapp]
    permissionsFetched: bool

type R = Result[Dapp, string]

proc delete*(self: Service) =
  discard

proc newService*(): Service =
  result = Service()
  result.dapps = initTable[string, Dapp]()
  result.permissionsFetched = false

proc init*(self: Service) =
  discard

proc fetchDappPermissions*(self: Service) =
  # TODO later we can make this async, but it's not worth it for now
  try:
    let response = backend.getDappPermissions()
    for dapp in response.result.getElems().mapIt(it.toDapp()):
      if dapp.address == "":
        continue

      self.dapps[dapp.name & dapp.address] = dapp
    self.permissionsFetched = true
  except Exception as e:
    error "error fetching permissions: ", msg=e.msg

proc getDapps*(self: Service): seq[Dapp] =
  if not self.permissionsFetched:
    self.fetchDappPermissions()
  return toSeq(self.dapps.values)

proc getDapp*(self: Service, name: string, address: string): Option[Dapp] =
  let key = name & address
  if self.dapps.hasKey(key):
    return some(self.dapps[key])

  return none(Dapp)

proc addPermission*(self: Service, name: string, address: string, perm: permission.Permission): R =
  let key = name & address

  try:
    if not self.dapps.hasKey(key):
      self.dapps[key] = Dapp(
        name: name,
        address: address,
        permissions: initHashSet[permission.Permission]()
      )

    self.dapps[key].permissions.incl(perm)
    let permissions = self.dapps[key].permissions.toSeq().mapIt($it)
    discard backend.addDappPermissions(backend.Permission(
      dapp: name,
      address: address,
      permissions: permissions
    ))
    result.ok self.dapps[key]
  except Exception as e:
    let errDescription = e.msg
    error "error: ", errDescription
    result.err errDescription


proc hasPermission*(self: Service, dapp: string, address: string, perm: permission.Permission): bool =
  let key = dapp & address
  if not self.dapps.hasKey(key):
    return false
  return self.dapps[key].permissions.contains(perm)

proc disconnect*(self: Service, dappName: string): bool =
  try:
    var addresses: seq[string] = @[]
    for dapp in self.dapps.values:
      if dapp.name != dappName:
        continue

      discard backend.deleteDappPermissionsByNameAndAddress(dapp.name, dapp.address)
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
    discard backend.deleteDappPermissionsByNameAndAddress(dappName, address)
    self.dapps.del(key)
    return true
  except Exception as e:
    let errDescription = e.msg
    error "error: ", errDescription

proc removePermission*(self: Service, name: string, address: string, perm: permission.Permission): bool =
  let key = name & address
  if not self.dapps.hasKey(key):
      return

  try:  
    if self.dapps[key].permissions.contains(perm):
      self.dapps[key].permissions.excl(perm)
      if self.dapps[key].permissions.len > 0:
        discard backend.addDappPermissions(backend.Permission(
          dapp: name,
          address: address, 
          permissions: self.dapps[key].permissions.toSeq().mapIt($it)
        ))
      else:
        discard backend.deleteDappPermissionsByNameAndAddress(name, address)
        self.dapps.del(key)
    return true
  except Exception as e:
    let errDescription = e.msg
    error "error: ", errDescription