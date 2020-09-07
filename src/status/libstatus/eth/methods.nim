import
  strutils, options

import
  nimcrypto, eth/common/eth_types

import 
  ../coder, eth, transactions, ../types

export sendTransaction

type Method* = object
  name*: string
  signature*: string

proc encodeMethod(self: Method): string =
  ($nimcrypto.keccak256.digest(self.signature))[0..<8].toLower

proc encodeAbi*(self: Method, obj: object = RootObj()): string =
  result = "0x" & self.encodeMethod()

  # .fields is an iterator, and there's no way to get a count of an iterator
  # in nim, so we have to loop and increment a counter
  var fieldCount = 0
  for i in obj.fields:
    fieldCount += 1
  var
    offset = 32*fieldCount
    data = ""

  for field in obj.fields:
    let encoded = encode(field)
    if encoded.dynamic:
      result &= offset.toHex(64).toLower
      data &= encoded.data
      offset += encoded.data.len
    else:
      result &= encoded.data
  result &= data

proc estimateGas*(self: Method, tx: var EthSend, methodDescriptor: object): string =
  tx.data = self.encodeAbi(methodDescriptor)
  let response = transactions.estimateGas(tx)
  result = response.result # gas estimate in hex

proc send*(self: Method, tx: var EthSend, methodDescriptor: object, password: string): string =
  tx.data = self.encodeAbi(methodDescriptor)
  result = eth.sendTransaction(tx, password)
  # result = coder.decodeContractResponse[string](response.result)
  # result = response.result

proc call*[T](self: Method, tx: var EthSend, methodDescriptor: object): T =
  tx.data = self.encodeAbi(methodDescriptor)
  let response = transactions.call(tx)
  result = coder.decodeContractResponse[T](response.result)