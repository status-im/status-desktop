import status/statusgo_backend_new/node as status_node
import bitops, stew/byteutils, chronicles
include ../../../app/core/tasks/common

type
  BloomBitsSetTaskArg = ref object of QObjectTaskArg
    bitsSet: int

proc getBloomFilterBitsSet*(): int  =
  try:
    let bloomFilter = status_node.getBloomFilter().result.getStr
    var bitCount = 0;
    for b in hexToSeqByte(bloomFilter):
      bitCount += countSetBits(b)
    return bitCount
  except Exception as e:
    error "error while getting BloomFilterBitSet: ", msg = e.msg
    return 0;

const bloomBitsSetTask: Task = proc(argEncoded: string) {.gcsafe, nimcall.} =
  let
    arg = decode[BloomBitsSetTaskArg](argEncoded)
    output = getBloomFilterBitsSet()
  arg.finish(output)
  