import strformat, httpclient, json, chronicles, sequtils, strutils, tables
from eth/common/utils import parseAddress
import ../libstatus/core as status
import ../libstatus/contracts as contracts
import ../libstatus/types
import eth/common/eth_types
import ../libstatus/types
import account

proc getTokenUri(contract: Contract, tokenId: Stuint[256]): string =
  try:
    let
      tokenUri = TokenUri(tokenId: tokenId)
      payload = %* [{
        "to": $contract.address,
        "data": contract.methods["tokenURI"].encodeAbi(tokenUri)
      }, "latest"]
      response = callPrivateRPC("eth_call", payload)
    var postfixedResult: string = parseJson($response)["result"].str
    postfixedResult.removeSuffix('0')
    postfixedResult.removePrefix("0x")
    postfixedResult = parseHexStr(postfixedResult)
    let index = postfixedResult.find("http")
    if (index < -1):
      return ""
    result = postfixedResult[index ..  postfixedResult.high]
  except Exception as e:
    error "Error getting the token URI", mes = e.msg
    result = ""

proc tokenOfOwnerByIndex(contract: Contract, address: EthAddress, index: Stuint[256]): int =
  let
    tokenOfOwnerByIndex = TokenOfOwnerByIndex(address: address, index: index)
    payload = %* [{
      "to": $contract.address,
      "data": contract.methods["tokenOfOwnerByIndex"].encodeAbi(tokenOfOwnerByIndex)
    }, "latest"]
    response = callPrivateRPC("eth_call", payload)
    res = parseJson($response)["result"].str
  if (res == "0x"):
    return -1
  result = fromHex[int](res)

proc tokensOfOwnerByIndex(contract: Contract, address: EthAddress): seq[int] =
  var index = 0
  var token: int
  result = @[]
  while (true):
    token = tokenOfOwnerByIndex(contract, address, index.u256)
    if (token == -1 or token == 0):
      return result
    result.add(token)
    index = index + 1

proc getCryptoKitties*(address: EthAddress): seq[Collectible] =
  result = @[]
  try:
    # TODO handle testnet -- does this API exist in testnet??
    # TODO handle offset (recursive method?)
    # Crypto kitties has a limit of 20
    let url: string = fmt"https://api.cryptokitties.co/kitties?limit=20&offset=0&owner_wallet_address={$address}&parents=false"
    let client = newHttpClient()
    client.headers = newHttpHeaders({ "Content-Type": "application/json" })

    let response = client.request(url)
    let kitties = parseJson(response.body)["kitties"]
    for kitty in kitties:
      var id = kitty["id"]
      var finalId = ""
      if (not (id.kind == JNull)):
        finalId = $id
      result.add(Collectible(id: finalId, name: kitty["name"].str, image: kitty["image_url"].str))
  except Exception as e:
    error "Error getting Cryptokitties", msg = e.msg

proc getEthermons*(address: EthAddress): seq[Collectible] =
  result = @[]
  try:
    let contract = getContract("ethermon")
    if contract == nil: return

    let tokens = tokensOfOwnerByIndex(contract, address)

    if (tokens.len == 0):
      return result

    let tokensJoined = strutils.join(tokens, ",")
    let url = fmt"https://www.ethermon.io/api/monster/get_data?monster_ids={tokensJoined}"
    let client = newHttpClient()
    client.headers = newHttpHeaders({ "Content-Type": "application/json" })

    let response = client.request(url)
    let monsters = parseJson(response.body)["data"]
    var i = 0
    for monsterKey in json.keys(monsters):
      let monster = monsters[monsterKey]
      result.add(Collectible(id: $tokens[i], name: monster["class_name"].str, image: monster["image"].str))
      i = i + 1
  except Exception as e:
    error "Error getting Ethermons", msg = e.msg

proc getKudos*(address: EthAddress): seq[Collectible] =
  result = @[]
  try:
    let contract = getContract("kudos")
    if contract == nil: return
    
    let tokens = tokensOfOwnerByIndex(contract, address)

    if (tokens.len == 0):
      return result

    for token in tokens:
      let url =  getTokenUri(contract, token.u256)

      if (url == ""):
        return result

      let client = newHttpClient()
      client.headers = newHttpHeaders({ "Content-Type": "application/json" })

      let response = client.request(url)
      let kudo = parseJson(response.body)

      result.add(Collectible(id: $token, name: kudo["name"].str, image: kudo["image"].str))
  except Exception as e:
    error "Error getting Kudos", msg = e.msg

proc getAllCollectibles*(address: string): seq[Collectible] =
  let eth_address = parseAddress(address)
  result = concat(getCryptoKitties(eth_address), getEthermons(eth_address), getKudos(eth_address))
