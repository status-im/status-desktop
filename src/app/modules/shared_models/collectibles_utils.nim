import app_service/service/network/dto as network_dto
import ./collectibles_entry

proc getExtraData*(network: network_dto.NetworkDto): ExtraData =
    return ExtraData(
        networkShortName: network.shortName,
        networkColor: network.chainColor,
        networkIconUrl: network.iconURL
    )