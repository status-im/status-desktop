import json
import base

import ../../../../app_service/service/wallet_account/[dto]

type WakuBackedUpWalletAccountsSignal* = ref object of Signal
  account*: WalletAccountDto

proc fromEvent*(T: type WakuBackedUpWalletAccountsSignal, event: JsonNode): WakuBackedUpWalletAccountsSignal =
  result = WakuBackedUpWalletAccountsSignal()

  if event["event"]{"backedUpWalletAccount"} != nil:
    result.account = event["event"]["backedUpWalletAccount"].toWalletAccountDto()