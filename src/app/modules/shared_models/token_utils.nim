import tables, sequtils, sugar
import ../../../app_service/service/wallet_account/dto
import ../../../app_service/service/currency/dto as currency_dto
import ./currency_amount_utils
import ./balance_utils
import ./token_item

proc walletTokenToItem*(
  t: WalletTokenDto,
  chainIds: seq[int],
  enabledChainIds: seq[int],
  currency: string,
  currencyFormat: CurrencyFormatDto,
  tokenFormat: CurrencyFormatDto,
  ) : token_item.Item =
  let marketValues = t.marketValuesPerCurrency.getOrDefault(currency)

  return token_item.initItem(
    t.name,
    t.symbol,
    currencyAmountToItem(t.getBalance(chainIds), tokenFormat),
    currencyAmountToItem(t.getCurrencyBalance(chainIds, currency), currencyFormat),
    currencyAmountToItem(t.getBalance(enabledChainIds), tokenFormat),
    currencyAmountToItem(t.getCurrencyBalance(enabledChainIds, currency), currencyFormat),
    t.getVisibleForNetwork(enabledChainIds),
    t.getVisibleForNetworkWithPositiveBalance(enabledChainIds),
    t.getBalances(enabledChainIds).map(b => balanceToItem(b, tokenFormat)),
    t.description,
    t.assetWebsiteUrl,
    t.builtOn,
    t.getAddress(),
    currencyAmountToItem(marketValues.marketCap, currencyFormat),
    currencyAmountToItem(marketValues.highDay, currencyFormat),
    currencyAmountToItem(marketValues.lowDay, currencyFormat),
    marketValues.changePctHour,
    marketValues.changePctDay,
    marketValues.changePct24hour,
    marketValues.change24hour,
    currencyAmountToItem(marketValues.price, currencyFormat),
    t.decimals,
    t.pegSymbol
    )
