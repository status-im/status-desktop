import
  sequtils, macros, tables, strutils

import
  web3/ethtypes, stew/byteutils, nimcrypto, json_serialization, chronicles
import json, tables, json_serialization
import web3/[ethtypes, conversions], stint
import ./method_dto

import ../../../../backend/eth as status_eth

export method_dto

include  ../../../common/json_utils

type
  ContractDto* = ref object of RootObj
    name*: string
    chainId*: int
    address*: Address
    procs* {.dontSerialize.}: Table[string, MethodDto]

  Erc20ContractDto* = ref object of ContractDto
    symbol*: string
    decimals*: int
    hasIcon* {.dontSerialize.}: bool
    color*: string

  Erc721ContractDto* = ref object of ContractDto
    symbol*: string
    hasIcon*: bool

proc newErc20Contract*(name: string, chainId: int, address: Address, symbol: string, decimals: int, hasIcon: bool): Erc20ContractDto =
  Erc20ContractDto(name: name, chainId: chainId, address: address, procs: ERC20_procS.toTable, symbol: symbol, decimals: decimals, hasIcon: hasIcon)

proc newErc20Contract*(chainId: int, address: Address): Erc20ContractDto =
  Erc20ContractDto(name: "", chainId: chainId, address: address, procs: ERC20_procS.toTable, symbol: "", decimals: 0, hasIcon: false)

proc newErc721Contract*(name: string, chainId: int, address: Address, symbol: string, hasIcon: bool, addlprocs: seq[tuple[name: string, meth: MethodDto]] = @[]): Erc721ContractDto =
  Erc721ContractDto(name: name, chainId: chainId, address: address, symbol: symbol, hasIcon: hasIcon, procs: ERC721_ENUMERABLE_procS.concat(addlprocs).toTable)

proc tokenDecimals*(contract: ContractDto): int =
  let payload = %* [{
      "to": $contract.address,
      "data": contract.procs["decimals"].encodeAbi()
    }, "latest"]

  let response = status_eth.doEthCall(payload)
  if not response.error.isNil:
    raise newException(RpcException, "Error getting token decimals: " & response.error.message)
  if response.result.getStr == "0x":
    return 0
  result = parseHexInt(response.result.getStr)

proc getTokenString*(contract: ContractDto, procName: string): string =
  let payload = %* [{
      "to": $contract.address,
      "data": contract.procs[procName].encodeAbi()
    }, "latest"]

  let response = status_eth.doEthCall(payload)
  if not response.error.isNil:
    raise newException(RpcException, "Error getting token string - " & procName & ": " & response.error.message)
  if response.result.getStr == "0x":
    return ""

  let size = fromHex(Stuint[256], response.result.getStr[66..129]).truncate(int)
  result = response.result.getStr[130..129+size*2].parseHexStr

proc tokenName*(contract: ContractDto): string =
  getTokenString(contract, "name")

proc tokenSymbol*(contract: ContractDto): string =
  getTokenString(contract, "symbol")

proc getproc*(contract: ContractDto, procName: string): MethodDto =
  return contract.procs[procName]
