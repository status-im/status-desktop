import strformat, httpclient, json, chronicles, sequtils, strutils, tables, sugar
from eth/common/utils import parseAddress
import ../libstatus/core as status
import ../libstatus/contracts as contracts
import ../libstatus/stickers as status_stickers
import ../chat as status_chat
import ../libstatus/types
import eth/common/eth_types
import ../libstatus/types
import account

const CRYPTOKITTY* = "cryptokitty"
const KUDO* = "kudo"
const ETHERMON* = "ethermon"
const STICKER* = "stickers"

const COLLECTIBLE_TYPES* = [CRYPTOKITTY, KUDO, ETHERMON, STICKER]

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

proc getCryptoKitties*(address: EthAddress): string =
  var cryptokitties: seq[Collectible]
  cryptokitties = @[]
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
      try:
        var id = kitty["id"]
        var name = kitty["name"]
        var finalId = ""
        var finalName = ""
        if (not (id.kind == JNull)):
          finalId = $id
        if (not (name.kind == JNull)):
          finalName = $name
        cryptokitties.add(Collectible(id: finalId,
        name: finalName,
        image: kitty["image_url_png"].str,
        collectibleType: CRYPTOKITTY,
        description: "",
        externalUrl: ""))
      except Exception as e2:
        error "Error with this individual cat", msg = e2.msg, cat = kitty
  except Exception as e:
    error "Error getting Cryptokitties", msg = e.msg
    return e.msg
  
  return $(%*cryptokitties)

proc getCryptoKitties*(address: string): string =
  let eth_address = parseAddress(address)
  result = getCryptoKitties(eth_address)

proc getEthermons*(address: EthAddress): string =
  try:
    var ethermons: seq[Collectible]
    ethermons = @[]
    let contract = getContract("ethermon")
    if contract == nil: return

    let tokens = tokensOfOwnerByIndex(contract, address)

    if (tokens.len == 0):
      return $(%*ethermons)

    let tokensJoined = strutils.join(tokens, ",")
    let url = fmt"https://www.ethermon.io/api/monster/get_data?monster_ids={tokensJoined}"
    let client = newHttpClient()
    client.headers = newHttpHeaders({ "Content-Type": "application/json" })

    let response = client.request(url)
    let monsters = parseJson(response.body)["data"]
    var i = 0
    for monsterKey in json.keys(monsters):
      let monster = monsters[monsterKey]
      ethermons.add(Collectible(id: $tokens[i],
      name: monster["class_name"].str,
      image: monster["image"].str,
      collectibleType: ETHERMON,
      description: "",
      externalUrl: ""))
      i = i + 1
        
    return $(%*ethermons)
  except Exception as e:
    error "Error getting Ethermons", msg = e.msg
    result = e.msg

proc getEthermons*(address: string): string =
  let eth_address = parseAddress(address)
  result = getEthermons(eth_address)

proc getKudos*(address: EthAddress): string =
  try:
    var kudos: seq[Collectible]
    kudos = @[]
    let contract = getContract("kudos")
    if contract == nil: return
    
    let tokens = tokensOfOwnerByIndex(contract, address)

    if (tokens.len == 0):
      return $(%*kudos)

    for token in tokens:
      let url =  getTokenUri(contract, token.u256)

      if (url == ""):
        return  $(%*kudos)

      let client = newHttpClient()
      client.headers = newHttpHeaders({ "Content-Type": "application/json" })

      let response = client.request(url)
      let kudo = parseJson(response.body)

      kudos.add(Collectible(id: $token,
      name: kudo["name"].str,
      image: kudo["image"].str,
      collectibleType: KUDO,
      description: kudo["description"].str,
      externalUrl: kudo["external_url"].str))

    return $(%*kudos)
  except Exception as e:
    error "Error getting Kudos", msg = e.msg
    result = e.msg

proc getKudos*(address: string): string =
  let eth_address = parseAddress(address)
  result = getKudos(eth_address)

proc getStickers*(address: EthAddress): string =
  try:
    var stickers: seq[Collectible]
    stickers = @[]
    let contract = getContract("sticker-pack")
    if contract == nil: return
    
    let tokensIds = tokensOfOwnerByIndex(contract, address)

    if (tokensIds.len == 0):
      return $(%*stickers)

    let purchasedStickerPacks = tokensIds.map(tokenId => status_stickers.getPackIdFromTokenId(tokenId.u256))

    if (purchasedStickerPacks.len == 0):
      return $(%*stickers)
    # TODO find a way to keep those in memory so as not to reload it each time
    let availableStickerPacks = status_chat.getAvailableStickerPacks()

    var index = 0
    for stickerId in purchasedStickerPacks:
      let sticker = availableStickerPacks[stickerId]
      stickers.add(Collectible(id: $tokensIds[index],
        name: sticker.name,
        image: fmt"https://ipfs.infura.io/ipfs/{status_stickers.decodeContentHash(sticker.preview)}",
        collectibleType: STICKER,
        description: sticker.author,
        externalUrl: "")
      )
      index = index + 1

    return $(%*stickers)
  except Exception as e:
    error "Error getting Stickers", msg = e.msg
    result = e.msg

proc getStickers*(address: string): string =
  let eth_address = parseAddress(address)
  result = getStickers(eth_address)
