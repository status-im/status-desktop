import
  strutils, options, json

import
  nimcrypto, web3/[encoding, ethtypes]

import ../../../../backend/eth as status_eth

import
  ./transaction,
  ./coder


type MethodDto* = object
  name*: string
  signature*: string

const ERC20_procS* = @[
  ("name", MethodDto(signature: "name()")),
  ("symbol", MethodDto(signature: "symbol()")),
  ("decimals", MethodDto(signature: "decimals()")),
  ("totalSupply", MethodDto(signature: "totalSupply()")),
  ("balanceOf", MethodDto(signature: "balanceOf(address)")),
  ("transfer", MethodDto(signature: "transfer(address,uint256)")),
  ("allowance", MethodDto(signature: "allowance(address,address)")),
  ("approve", MethodDto(signature: "approve(address,uint256)")),
  ("transferFrom", MethodDto(signature: "approve(address,address,uint256)")),
  ("increaseAllowance", MethodDto(signature: "increaseAllowance(address,uint256)")),
  ("decreaseAllowance", MethodDto(signature: "decreaseAllowance(address,uint256)")),
  ("approveAndCall", MethodDto(signature: "approveAndCall(address,uint256,bytes)"))
]

const ERC721_ENUMERABLE_procS* = @[
  ("balanceOf", MethodDto(signature: "balanceOf(address)")),
  ("ownerOf", MethodDto(signature: "ownerOf(uint256)")),
  ("name", MethodDto(signature: "name()")),
  ("symbol", MethodDto(signature: "symbol()")),
  ("tokenURI", MethodDto(signature: "tokenURI(uint256)")),
  ("baseURI", MethodDto(signature: "baseURI()")),
  ("tokenOfOwnerByIndex", MethodDto(signature: "tokenOfOwnerByIndex(address,uint256)")),
  ("totalSupply", MethodDto(signature: "totalSupply()")),
  ("tokenByIndex", MethodDto(signature: "tokenByIndex(uint256)")),
  ("approve", MethodDto(signature: "approve(address,uint256)")),
  ("getApproved", MethodDto(signature: "getApproved(uint256)")),
  ("setApprovalForAll", MethodDto(signature: "setApprovalForAll(address,bool)")),
  ("isApprovedForAll", MethodDto(signature: "isApprovedForAll(address,address)")),
  ("transferFrom", MethodDto(signature: "transferFrom(address,address,uint256)")),
  ("safeTransferFrom", MethodDto(signature: "safeTransferFrom(address,address,uint256)")),
  ("safeTransferFromWithData", MethodDto(signature: "safeTransferFrom(address,address,uint256,bytes)"))
]

proc encodeproc(self: MethodDto): string =
  ($nimcrypto.keccak256.digest(self.signature))[0..<8].toLower

proc encodeAbi*(self: MethodDto, obj: object = RootObj()): string =
  result = "0x" & self.encodeproc()

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

proc estimateGas*(self: MethodDto, chainId: int, tx: var TransactionDataDto, procDescriptor: object, success: var bool): string =
  success = true
  tx.data = self.encodeAbi(procDescriptor)
  try:
    # this call should not be part of this file, we need to move it to appropriate place, or this should not be a DTO class.
    let response = status_eth.estimateGas(chainId, %*[%tx])
    result = response.result.getStr # gas estimate in hex
  except RpcException as e:
    success = false
    result = e.msg

proc getEstimateGasData*(self: MethodDto, tx: var TransactionDataDto, procDescriptor: object): JsonNode =
  tx.data = self.encodeAbi(procDescriptor)
  return %*[%tx]

proc call[T](self: MethodDto, chainId: int, tx: var TransactionDataDto, procDescriptor: object, success: var bool): T =
  success = true
  tx.data = self.encodeAbi(procDescriptor)
  let response: RpcResponse
  try:
    # this call should not be part of this file, we need to move it to appropriate place, or this should not be a DTO class.
    response = status_eth.doEthCall(chainId, tx)
  except RpcException as e:
    success = false
    result = e.msg
  result = coder.decodeContractResponse[T](response.result)