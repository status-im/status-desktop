import sugar, sequtils

import ./item
import app_service/service/ramp/dto
import app/modules/shared_models/contract_item as contract_item

proc dtoToItem*(dto: CryptoRampDto): item.Item =
  let supportedAssets =
    dto.supportedTokens.map(t => contract_item.initItem(t.chainID, t.address))

  return initItem(
    dto.id, dto.name, dto.description, dto.fees, dto.logoUrl, dto.hostname,
    dto.supportsSinglePurchase, dto.supportsRecurrentPurchase, supportedAssets,
    dto.urlsNeedParameters,
  )
