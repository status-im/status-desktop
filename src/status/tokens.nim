import json, json_serialization

import 
  sugar, sequtils, strutils, atomics

import libstatus/tokens as status_tokens
import libstatus/eth/contracts
import ../eventemitter
import signals/types

#TODO: temporary?
import types as LibStatusTypes

type
    TokensModel* = ref object
        events*: EventEmitter

proc newTokensModel*(events: EventEmitter): TokensModel =
  result = TokensModel()
  result.events = events

proc getSNTAddress*(): string =
  result = status_tokens.getSNTAddress()

proc getCustomTokens*(self: TokensModel, useCached: bool = true): seq[Erc20Contract] =
  result = status_tokens.getCustomTokens(useCached)

proc removeCustomToken*(self: TokensModel, address: string) =
  status_tokens.removeCustomToken(address)

proc getSNTBalance*(account: string): string =
  result = status_tokens.getSNTBalance(account)

proc tokenDecimals*(contract: Contract): int =
  result = status_tokens.tokenDecimals(contract)

proc tokenName*(contract: Contract): string =
  result = status_tokens.tokenName(contract)

proc tokensymbol*(contract: Contract): string =
  result = status_tokens.tokensymbol(contract)

proc getTokenBalance*(tokenAddress: string, account: string): string = 
  result = status_tokens.getTokenBalance(tokenAddress, account)

proc getToken*(self: TokensModel, tokenAddress: string): Erc20Contract =
    result = status_tokens.getToken(tokenAddress)

export newErc20Contract
export getErc20Contracts
export Erc20Contract
export getErc20ContractByAddress
