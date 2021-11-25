import
  sequtils, macros, tables, strutils

import
  web3/ethtypes, stew/byteutils, nimcrypto, json_serialization, chronicles
import json, tables, json_serialization
import ./method_dto

include  ../../../common/json_utils

type
  ContractDto* = ref object of RootObj
    name*: string
    chainId*: int
    address*: Address
    methods* {.dontSerialize.}: Table[string, MethodDto]
 
  Erc20ContractDto* = ref object of ContractDto
    symbol*: string
    decimals*: int
    hasIcon* {.dontSerialize.}: bool
    color*: string

  Erc721ContractDto* = ref object of ContractDto
    symbol*: string
    hasIcon*: bool

proc newErc20Contract*(name: string, chainId: int, address: Address, symbol: string, decimals: int, hasIcon: bool): Erc20ContractDto =
  Erc20ContractDto(name: name, chainId: chainId, address: address, methods: ERC20_METHODS.toTable, symbol: symbol, decimals: decimals, hasIcon: hasIcon)

proc newErc20Contract*(chainId: int, address: Address): Erc20ContractDto =
  Erc20ContractDto(name: "", chainId: chainId, address: address, methods: ERC20_METHODS.toTable, symbol: "", decimals: 0, hasIcon: false)

proc newErc721Contract*(name: string, chainId: int, address: Address, symbol: string, hasIcon: bool, addlMethods: seq[tuple[name: string, meth: MethodDto]] = @[]): Erc721ContractDto =
  Erc721ContractDto(name: name, chainId: chainId, address: address, symbol: symbol, hasIcon: hasIcon, methods: ERC721_ENUMERABLE_METHODS.concat(addlMethods).toTable)
