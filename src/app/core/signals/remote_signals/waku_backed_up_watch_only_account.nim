import json
import base

import ../../../../app_service/service/wallet_account/dto/account_dto

type WakuBackedUpWatchOnlyAccountSignal* = ref object of Signal
  account*: WalletAccountDto

proc fromEvent*(T: type WakuBackedUpWatchOnlyAccountSignal, event: JsonNode): WakuBackedUpWatchOnlyAccountSignal =
  result = WakuBackedUpWatchOnlyAccountSignal()

  let e = event["event"]
  if e.contains("backedUpWatchOnlyAccount"):
    result.account = e["backedUpWatchOnlyAccount"].toWalletAccountDto()
