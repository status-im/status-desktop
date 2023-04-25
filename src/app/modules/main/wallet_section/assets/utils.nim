import ./item

import ../../../../../app_service/service/wallet_account/dto

proc walletAccountToItem*(
  w: WalletAccountDto,
) : item.Item =
  return item.initItem(
    w.assetsLoading,
  )
