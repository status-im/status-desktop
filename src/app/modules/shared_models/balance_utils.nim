import ../../../app_service/service/wallet_account/dto
import ../../../app_service/service/currency/dto as currency_dto
import ./currency_amount_utils
import ./balance_item

proc balanceToItem*(b: BalanceDto, format: CurrencyFormatDto) : Item =
  return initItem(
    currencyAmountToItem(b.balance, format),
    b.address,
    b.chainId
  )
