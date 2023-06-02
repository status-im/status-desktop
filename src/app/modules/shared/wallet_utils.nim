import tables, sequtils, sugar

import ../shared_models/[balance_item, currency_amount, token_item, token_model]

import ../../../app_service/service/wallet_account/service as wallet_account_service
import ../../../app_service/service/currency/dto as currency_dto

import ../main/wallet_section/accounts/item as wallet_accounts_item
import ../main/wallet_section/assets/item as wallet_assets_item
import ../main/wallet_section/send/account_item as wallet_send_account_item
import ../main/profile_section/wallet/accounts/item as wallet_settings_accounts_item
import ../main/profile_section/wallet/accounts/[related_account_item, related_accounts_model]

proc currencyAmountToItem*(amount: float64, format: CurrencyFormatDto) : CurrencyAmount =
  return newCurrencyAmount(
    amount,
    format.symbol,
    int(format.displayDecimals),
    format.stripTrailingZeroes
  )

proc balanceToItemBalanceItem*(b: BalanceDto, format: CurrencyFormatDto) : balance_item.Item =
  return balance_item.initItem(
    currencyAmountToItem(b.balance, format),
    b.address,
    b.chainId
  )

proc walletAccountToRelatedAccountItem*(w: WalletAccountDto) : related_account_item.Item =
  return related_account_item.initItem(
    w.name,
    w.colorId,
    w.emoji,
  )

proc walletAccountToWalletSettingsAccountsItem*(w: WalletAccountDto, keycardAccount: bool): wallet_settings_accounts_item.Item =
  discard
  let relatedAccounts = related_accounts_model.newModel()
  if w.isNil:
    return wallet_settings_accounts_item.initItem()

  relatedAccounts.setItems(w.relatedAccounts.map(x => walletAccountToRelatedAccountItem(x)))

  return wallet_settings_accounts_item.initItem(
    w.name,
    w.address,
    w.path,
    w.colorId,
    w.walletType,
    w.emoji,
    relatedAccounts,
    w.keyUid,
    keycardAccount
  )

proc walletAccountToWalletAccountsItem*(w: WalletAccountDto, keycardAccount: bool, enabledChainIds: seq[int], currency: string,
  currencyFormat: CurrencyFormatDto): wallet_accounts_item.Item =
  return wallet_accounts_item.initItem(
    w.name,
    w.address,
    w.path,
    w.colorId,
    w.walletType,
    currencyAmountToItem(w.getCurrencyBalance(enabledChainIds, currency), currencyFormat),
    w.emoji,
    w.keyUid,
    w.createdAt,
    keycardAccount,
    w.assetsLoading,
  )

proc walletAccountToWalletAssetsItem*(w: WalletAccountDto): wallet_assets_item.Item =
  return wallet_assets_item.initItem(
    w.assetsLoading,
  )

proc walletTokenToItem*(
  t: WalletTokenDto, chainIds: seq[int], enabledChainIds: seq[int], currency: string,
  currencyFormat: CurrencyFormatDto, tokenFormat: CurrencyFormatDto
): token_item.Item =
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
    t.getBalances(chainIds).map(b => balanceToItemBalanceItem(b, tokenFormat)),
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
    loading = false
    )

proc walletAccountToWalletSendAccountItem*(w: WalletAccountDto, chainIds: seq[int], enabledChainIds: seq[int], currency: string,
  currencyFormat: CurrencyFormatDto, tokenFormats: Table[string, CurrencyFormatDto]): wallet_send_account_item.AccountItem =
  let assets = token_model.newModel()
  assets.setItems(
    w.tokens.map(t => walletTokenToItem(t, chainIds, enabledChainIds, currency, currencyFormat, tokenFormats[t.symbol]))
  )
  return wallet_send_account_item.newAccountItem(
    w.name,
    w.address,
    w.colorId,
    w.emoji,
    w.walletType,
    assets,
    currencyAmountToItem(w.getCurrencyBalance(enabledChainIds, currency), currencyFormat),
  )
