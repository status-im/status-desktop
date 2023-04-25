import Tables, sequtils, sugar
import ./account_item

import ../../../../../app_service/service/wallet_account/dto
import ../../../../../app_service/service/currency/dto as currency_dto
import ../../../shared_models/currency_amount_utils
import ../../../shared_models/token_model as token_model
import ../../../shared_models/token_utils

proc walletAccountToItem*(
  w: WalletAccountDto,
  chainIds: seq[int],
  enabledChainIds: seq[int],
  currency: string,
  currencyFormat: CurrencyFormatDto,
  tokenFormats: Table[string, CurrencyFormatDto],
) : account_item.AccountItem =
  let assets = token_model.newModel()
  assets.setItems(
    w.tokens.map(t => walletTokenToItem(t, chainIds, enabledChainIds, currency, currencyFormat, tokenFormats[t.symbol]))
  )
  return account_item.initAccountItem(
    w.name,
    w.address,
    w.color,
    w.walletType,
    w.emoji,
    assets,
    currencyAmountToItem(w.getCurrencyBalance(enabledChainIds, currency), currencyFormat),
  )
