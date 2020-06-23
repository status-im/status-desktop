import strformat, httpclient, json, chronicles, sequtils, strutils, tables
import ../libstatus/[core, contracts]
import eth/common/eth_types
import account

proc getTokenUri(contract: Contract, tokenId: int): string =
  try:
    let payload = %* [{
      "to": $contract.address,
      "data": contract.methods["tokenURI"].encodeAbi(tokenId)
    }, "latest"]
    let response = callPrivateRPC("eth_call", payload)
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

proc tokenOfOwnerByIndex(contract: Contract, address: EthAddress, index: int): int =
  let payload = %* [{
    "to": $contract.address,
    "data": contract.methods["tokenOfOwnerByIndex"].encodeAbi(address, index)
  }, "latest"]
  let response = callPrivateRPC("eth_call", payload)
  let res = parseJson($response)["result"].str
  if (res == "0x"):
    return -1
  result = fromHex[int](res)

proc tokensOfOwnerByIndex(contract: Contract, address: EthAddress): seq[int] =
  var index = 0
  var token: int
  result = @[]
  while (true):
    token = tokenOfOwnerByIndex(contract, address, index)
    if (token == -1 or token == 0):
      return result
    result.add(token)
    index = index + 1

proc getCryptoKitties*(address: EthAddress): seq[Collectible] =
  result = @[]
  try:
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
    let contract = getContract(Network.Mainnet, "ethermon")
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
    let contract = getContract(Network.Mainnet, "kudos")
    let tokens = tokensOfOwnerByIndex(contract, address)

    if (tokens.len == 0):
      return result

    for token in tokens:
      let url =  getTokenUri(contract, token)

      if (url == ""):
        return result

      let client = newHttpClient()
      client.headers = newHttpHeaders({ "Content-Type": "application/json" })

      let response = client.request(url)
      let kudo = parseJson(response.body)

      result.add(Collectible(id: $token, name: kudo["name"].str, image: kudo["image"].str))
  except Exception as e:
    error "Error getting Kudos", msg = e.msg

proc getAllCollectibles*(address: EthAddress): seq[Collectible] =
  result = concat(getCryptoKitties(address), getEthermons(address), getKudos(address))
