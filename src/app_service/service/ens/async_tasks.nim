#################################################
# Async check for ens username availability
#################################################

type
  CheckEnsAvailabilityTaskArg = ref object of QObjectTaskArg
    ensUsername*: string
    isStatus*: bool
    myPublicKey*: string
    myWalletAddress*: string

const checkEnsAvailabilityTask: Task = proc(argEncoded: string) {.gcsafe, nimcall.} =
  let arg = decode[CheckEnsAvailabilityTaskArg](argEncoded)

  var desiredEnsUsername = arg.ensUsername & (if(arg.isStatus): ens_utils.STATUS_DOMAIN else: "")

  var availability = ""
  let ownerAddr = ens_utils.owner(desiredEnsUsername)
  if ownerAddr == "" and arg.isStatus:
    availability = ENS_AVAILABILITY_STATUS_AVAILABLE
  else:
    let ensPubkey = ens_utils.pubkey(arg.ensUsername)
    if ownerAddr != "":
      if ensPubkey == "" and ownerAddr == arg.myWalletAddress:
        availability = ENS_AVAILABILITY_STATUS_OWNED # "Continuing will connect this username with your chat key."
      elif ensPubkey == arg.myPublicKey:
        availability = ENS_AVAILABILITY_STATUS_CONNECTED
      elif ownerAddr == arg.myWalletAddress:
        availability = ENS_AVAILABILITY_STATUS_CONNECTED_DIFFERENT_KEY #  "Continuing will require a transaction to connect the username with your current chat key.",
      else:
        availability = ENS_AVAILABILITY_STATUS_TAKEN
    else:
      availability = ENS_AVAILABILITY_STATUS_TAKEN

  let responseJson = %*{
    "availability": availability
  }
  arg.finish(responseJson)

#################################################
# Async load ens username details
#################################################

type
  EnsUsernamDetailsTaskArg = ref object of QObjectTaskArg
    ensUsername*: string
    isStatus*: bool
    toAddress*: Address
    data: string

const ensUsernameDetailsTask: Task = proc(argEncoded: string) {.gcsafe, nimcall.} =
  let arg = decode[EnsUsernamDetailsTaskArg](argEncoded)

  let address = ens_utils.address(arg.ensUsername)
  let pubkey = ens_utils.pubkey(arg.ensUsername)

  var expirationTime = 0
  if arg.isStatus:
    expirationTime = ens_utils.getExpirationTime(arg.toAddress, arg.data)

  let responseJson = %* {
    "ensUsername": arg.ensUsername,
    "address": address,
    "pubkey": pubkey,
    "isStatus": arg.isStatus,
    "expirationTime": expirationTime
  }
  arg.finish(responseJson)


#################################################
# Async fetch gas price
#################################################

const fetchGasPriceTask: Task = proc(argEncoded: string) {.gcsafe, nimcall.} =
  let arg = decode[QObjectTaskArg](argEncoded)
  let response = status_eth.getGasPrice()
  let responseJson = %* {
    "gasPrice": response.result.getStr
  }
  arg.finish(responseJson)
