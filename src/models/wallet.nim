import eventemitter
import json
import ../status/wallet as status_wallet

type Asset* = ref object
    name*, symbol*, value*, fiatValue*, image*: string

type WalletModel* = ref object
    events*: EventEmitter

proc newWalletModel*(events: EventEmitter): WalletModel =
  result = WalletModel()
  result.events = events

proc delete*(self: WalletModel) =
  discard

proc sendTransaction*(self: WalletModel, from_value: string, to: string, value: string, password: string): string =
  status_wallet.sendTransaction(from_value, to, value, password)
