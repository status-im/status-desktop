import Tables, json, chronicles, strutils
import sets
import options
import chronicles, libp2p/[multihash, multicodec, cid]
import nimcrypto
include ../../common/json_utils
import service_interface
import status/statusgo_backend_new/ens as status_go
export service_interface

logScope:
  topics = "ens-service"

type 
  Service* = ref object of ServiceInterface

method delete*(self: Service) =
  discard

proc newService*(): Service =
  result = Service()

method init*(self: Service) =
  discard

method getContentHash*(self: Service, ens: string): Option[string] =
  try:
    let contentHash = status_go.contenthash(ens)
    if contentHash != "":
      return some(contentHash)
  except Exception as e:
    let errDescription = e.msg
    error "error: ", errDescription
  return none(string)

method decodeENSContentHash*(self: Service, value: string): tuple[ensType: ENSType, output: string] =
  if value == "":
    return (ENSType.UNKNOWN, "")

  if value[0..5] == "e40101":
    return (ENSType.SWARM, value.split("1b20")[1])

  if value[0..7] == "e3010170":
    try:
      let defaultCodec = parseHexInt("70") #dag-pb
      var codec = defaultCodec # no codec specified
      var codecStartIdx = 2 # idx of where codec would start if it was specified
      # handle the case when starts with 0xe30170 instead of 0xe3010170
      if value[2..5] == "0101":
        codecStartIdx = 6
        codec = parseHexInt(value[6..7])
      elif value[2..3] == "01" and value[4..5] != "12":
        codecStartIdx = 4
        codec = parseHexInt(value[4..5])

      # strip the info we no longer need
      var multiHashStr = value[codecStartIdx + 2..<value.len]

      # The rest of the hash identifies the multihash algo, length, and digest
      # More info: https://multiformats.io/multihash/
      # 12 = identifies sha2-256 hash
      # 20 = multihash length = 32
      # ...rest = multihash digest
      let
        multiHash = MultiHash.init(nimcrypto.fromHex(multiHashStr)).get()
        decoded = Cid.init(CIDv0, MultiCodec.codec(codec), multiHash).get()
      return (ENSType.IPFS, $decoded)
    except Exception as e:
      error "Error decoding ENS contenthash", hash=value, exception=e.msg
      raise

  if value[0..8] == "e50101700":
    return (ENSType.IPNS, parseHexStr(value[12..value.len-1]))

  return (ENSType.UNKNOWN, "")
