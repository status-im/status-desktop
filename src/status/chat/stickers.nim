import chronicles
import libp2p/[multihash, multicodec, cid]
from strutils import parseHexInt

logScope:
  topics = "sticker-decoding"

# TODO: this is for testing purposes, the correct function should decode the hash
proc decodeContentHash*(value: string): string =
  if value == "":
    return ""

  # eg encoded sticker multihash cid:
  #  e30101701220eab9a8ef4eac6c3e5836a3768d8e04935c10c67d9a700436a0e53199e9b64d29
  #
  # The first 4 bytes (in hex) represent:
  # e3 = codec identifier "ipfs-ns" for content-hash
  # 01 = unused
  # 01 = CID version (effectively unused, as we will decode with CIDv0 regardless)
  # 70 = codec identifier "dag-pb"

  # ipfs-ns
  if value[0] & value[1] != "e3":
    warn "Could not decode sticker. It may still be valid, but requires a different codec to be used"
    return ""

  try:
    # dag-pb
    let codecStr = value[6] & value[7]
    let codec = parseHexInt(codecStr)

    # strip the info we no longer need
    var multiHashStr = value[8..<value.len]

    # The rest of the hash identifies the multihash algo, length, and digest
    # More info: https://multiformats.io/multihash/
    # 12 = identifies sha2-256 hash
    # 20 = multihash length = 32
    # ...rest = multihash digest
    let multiHash = MultiHash.init(multiHashStr).get()
    result = $Cid.init(CIDv0, MultiCodec.codec(codec), multiHash)
    trace "Decoded sticker hash", cid=result
  except Exception as e:
    error "Error decoding sticker", hash=value, exception=e.msg
    result = ""
