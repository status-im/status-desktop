import tables, sequtils, sugar

import ./item

import ../../../../../app_service/service/wallet_account/dto
import ../../../../../app_service/service/token/dto as token_dto
import ../../../../../app_service/service/currency/dto as currency_dto
import ../../../shared_models/token_model as token_model
import ../../../shared_models/token_item as token_item
import ../../../shared_models/token_utils
import ../../../shared_models/currency_amount
import ../../../shared_models/currency_amount_utils

import ./compact_item as compact_item
import ./compact_model as compact_model

proc walletAccountToCompactItem*(w: WalletAccountDto, enabledChainIds: seq[int], currency: string, currencyFormat: CurrencyFormatDto) : compact_item.Item =
  return compact_item.initItem(
    w.name,
    w.address,
    w.path,
    w.color,
    w.publicKey,
    w.walletType,
    w.isWallet,
    w.isChat,
    currencyAmountToItem(w.getCurrencyBalance(enabledChainIds, currency), currencyFormat),
    w.emoji,
    w.derivedfrom)

proc walletAccountToItem*(
  w: WalletAccountDto,
  chainIds: seq[int],
  enabledChainIds: seq[int],
  currency: string,
  keyPairMigrated: bool,
  currencyFormat: CurrencyFormatDto,
  tokenFormats: Table[string, CurrencyFormatDto],
  ) : item.Item =
  let assets = token_model.newModel()
  assets.setItems(
    w.tokens.map(t => walletTokenToItem(t, chainIds, enabledChainIds, currency, currencyFormat, tokenFormats[t.symbol]))
  )

  let relatedAccounts = compact_model.newModel()
  relatedAccounts.setItems(
    w.relatedAccounts.map(x => walletAccountToCompactItem(x, enabledChainIds, currency, currencyFormat))
  )

  result = initItem(
    w.name,
    w.address,
    w.mixedCaseAddress,
    w.path,
    w.color,
    w.publicKey,
    w.walletType,
    w.isWallet,
    w.isChat,
    currencyAmountToItem(w.getCurrencyBalance(enabledChainIds, currency), currencyFormat),
    assets,
    w.emoji,
    w.derivedfrom,
    relatedAccounts,
    w.keyUid,
    keyPairMigrated,
    w.ens
  )
