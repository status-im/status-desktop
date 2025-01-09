import app_service/service/network/network_item
import ./collectibles_entry

proc getExtraData*(network: NetworkItem): ExtraData =
  return ExtraData(
    networkShortName: network.shortName,
    networkColor: network.chainColor,
    networkIconUrl: network.iconURL,
  )
