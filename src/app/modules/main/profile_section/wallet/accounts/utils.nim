import tables, sequtils, sugar
import ../../../../../../app_service/service/wallet_account/service as wallet_account_service
import ./item
import ./related_account_item as related_account_item
import ./related_accounts_model as related_accounts_model

proc walletAccountToRelatedAccountItem*(w: WalletAccountDto) : related_account_item.Item =
  return related_account_item.initItem(
    w.name,
    w.color,
    w.emoji,
  )

proc walletAccountToItem*(
  w: WalletAccountDto,
) : item.Item =
  let relatedAccounts = related_accounts_model.newModel()
  if w.isNil:
    return item.initItem()

  relatedAccounts.setItems(
    w.relatedAccounts.map(x => walletAccountToRelatedAccountItem(x))
  )

  return item.initItem(
    w.name,
    w.address,
    w.path,
    w.color,
    w.walletType,
    w.emoji,
    relatedAccounts,
    w.keyUid,
  )
