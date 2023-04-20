import ./item

import ../../../../../app_service/service/wallet_account/dto
import ../../../../../app_service/service/currency/dto as currency_dto
import ../../../shared_models/currency_amount
import ../../../shared_models/currency_amount_utils


proc walletAccountToItem*(
  w: WalletAccountDto,
  enabledChainIds: seq[int],
  currency: string,
  currencyFormat: CurrencyFormatDto,
  ) : item.Item =
  return item.initItem(
    w.name,
    w.address,
    w.path,
    w.color,
    w.walletType,
    currencyAmountToItem(w.getCurrencyBalance(enabledChainIds, currency), currencyFormat),
    w.emoji,
    w.keyUid,
    w.assetsLoading,
  )
