import tables, sequtils, stint, sugar

import ../shared_models/[balance_item, currency_amount, token_item, token_model, wallet_account_item]

import backend/helpers/token

import app_service/service/currency/dto as currency_dto

import ../main/wallet_section/accounts/item as wallet_accounts_item
import ../main/wallet_section/assets/item as wallet_assets_item
import ../main/wallet_section/send/account_item as wallet_send_account_item

import backend/helpers/balance

proc currencyAmountToItem*(amount: float64, format: CurrencyFormatDto) : CurrencyAmount =
  return newCurrencyAmount(
    amount,
    format.symbol,
    int(format.displayDecimals),
    format.stripTrailingZeroes
  )

proc balanceToItemBalanceItem*(b: BalanceDto, format: CurrencyFormatDto) : balance_item.Item =
  return balance_item.initItem(
    b.rawBalance,
    currencyAmountToItem(b.balance, format),
    b.address,
    b.chainId
  )

proc walletAccountToWalletAccountItem*(w: WalletAccountDto, keycardAccount: bool, areTestNetworksEnabled: bool): WalletAccountItem =
  if w.isNil:
    return newWalletAccountItem()

  return newWalletAccountItem(
    w.name,
    w.address,
    w.colorId,
    w.emoji,
    w.walletType,
    w.path,
    w.keyUid,
    keycardAccount,
    w.position,
    w.operable,
    areTestNetworksEnabled,
    w.prodPreferredChainIds,
    w.testPreferredChainIds,
    w.hideFromTotalBalance
  )

proc walletAccountToWalletAccountsItem*(w: WalletAccountDto, keycardAccount: bool,
  currencyBalance: float64, currencyFormat: CurrencyFormatDto, areTestNetworksEnabled: bool): wallet_accounts_item.Item =
  return wallet_accounts_item.initItem(
    w.name,
    w.address,
    w.path,
    w.colorId,
    w.walletType,
    currencyAmountToItem(currencyBalance, currencyFormat),
    w.emoji,
    w.keyUid,
    w.createdAt,
    w.position,
    keycardAccount,
    w.assetsLoading,
    w.isWallet,
    areTestNetworksEnabled,
    w.prodPreferredChainIds,
    w.testPreferredChainIds,
    w.hideFromTotalBalance
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
    t.getRawBalance(chainIds).toString(10),
    currencyAmountToItem(t.getBalance(chainIds), tokenFormat),
    currencyAmountToItem(t.getCurrencyBalance(chainIds, currency), currencyFormat),
    currencyAmountToItem(t.getBalance(enabledChainIds), tokenFormat),
    currencyAmountToItem(t.getCurrencyBalance(enabledChainIds, currency), currencyFormat),
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
    t.image,
    t.communityId,
    t.communityName,
    t.communityImage,
    loading = false
    )

proc walletAccountToWalletSendAccountItem*(w: WalletAccountDto, tokens: seq[WalletTokenDto], chainIds: seq[int], enabledChainIds: seq[int], currency: string,
  currencyBalance: float64, currencyFormat: CurrencyFormatDto, tokenFormats: Table[string, CurrencyFormatDto], areTestNetworksEnabled: bool): wallet_send_account_item.AccountItem =
  let assets = token_model.newModel()
  assets.setItems(
    tokens.map(t => walletTokenToItem(t, chainIds, enabledChainIds, currency, currencyFormat, tokenFormats[t.symbol]))
  )
  return wallet_send_account_item.newAccountItem(
    w.name,
    w.address,
    w.colorId,
    w.emoji,
    w.walletType,
    assets,
    currencyAmountToItem(currencyBalance, currencyFormat),
    areTestNetworksEnabled,
    w.prodPreferredChainIds,
    w.testPreferredChainIds,
    canSend=w.walletType != "watch" and (w.operable==AccountFullyOperable or w.operable==AccountPartiallyOperable)
  )
