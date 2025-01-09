import stint, chronicles

import backend/collectibles_types as backend_collectibles
import backend/activity as backend_activity
import app_service/common/types
import web3/ethtypes as eth

proc collectibleUidToActivityToken*(
    uid: string, tokenType: TokenType
): backend_activity.Token =
  try:
    let id = uid.toCollectibleUniqueID()
    result.tokenType = tokenType
    result.chainId = backend_activity.ChainId(id.contractID.chainID)
    let contractAddress = id.contractID.address
    if len(contractAddress) > 0:
      var address: eth.Address
      address = eth.fromHex(eth.Address, contractAddress)
      result.address = some(address)
    result.tokenId = some(backend_activity.TokenId("0x" & stint.toHex(id.tokenId)))
  except:
    error "Invalid collectible uid: ", uid
