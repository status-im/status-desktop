import eth/common/eth_types
import ./core as status, ./types, ./contracts, ./settings
import json, json_serialization, tables, strutils, sequtils

# Retrieves number of sticker packs owned by user
# See https://notes.status.im/Q-sQmQbpTOOWCQcYiXtf5g#Read-Sticker-Packs-owned-by-a-user
# for more details
proc getBalance*(address: EthAddress): int =
  let contract = contracts.getContract(Network.Mainnet, "sticker-pack")
  let payload = %* [{
      "to": $contract.address,
      "data": contract.methods["balanceOf"].encodeAbi(address)
    }, "latest"]
  
  let responseStr = status.callPrivateRPC("eth_call", payload)
  let response = Json.decode(responseStr, RpcResponse)
  if response.error != "":
    raise newException(RpcException, "Error getting stickers balance: " & response.error)
  result = fromHex[int](response.result)

# Buys a sticker pack for user
# See https://notes.status.im/Q-sQmQbpTOOWCQcYiXtf5g#Buy-a-Sticker-Pack for more
# details
proc buyPack*(packId: int, address: EthAddress, price: int, password: string): string =
  let stickerMktContract = contracts.getContract(Network.Mainnet, "sticker-market")
  let sntContract = contracts.getContract(Network.Mainnet, "sticker-market")
  let buyTxAbiEncoded = stickerMktContract.methods["buyToken"].encodeAbi(packId, address, price)
  let approveAndCallAbiEncoded = sntContract.methods["approveAndCall"].encodeAbi($stickerMktContract.address, price, buyTxAbiEncoded)
  let payload = %* [{
      "from": $address,
      "to": $sntContract.address,
      "gas": 200000,
      "data": approveAndCallAbiEncoded
    }, "latest"]
  
  let responseStr = status.sendTransaction($payload, password)
  let response = Json.decode(responseStr, RpcResponse)
  if response.error != "":
    raise newException(RpcException, "Error getting stickers balance: " & response.error)
  result = response.result # should be a tx receipt

proc installStickers*() =
  discard settings.saveSettings("stickers/packs-installed", """{"1":{"author":"cryptoworld1373","id":1,"name":"Status Cat","preview":"e3010170122050efc0a3e661339f31e1e44b3d15a1bf4e501c965a0523f57b701667fa90ccca","price":0,"stickers":[{"hash":"e30101701220eab9a8ef4eac6c3e5836a3768d8e04935c10c67d9a700436a0e53199e9b64d29"},{"hash":"e30101701220c8f28aebe4dbbcee896d1cdff89ceeaceaf9f837df55c79125388f954ee5f1fe"},{"hash":"e301017012204861f93e29dd8e7cf6699135c7b13af1bce8ceeaa1d9959ab8592aa20f05d15f"},{"hash":"e301017012203ffa57a51cceaf2ce040852de3b300d395d5ba4d70e08ba993f93a25a387e3a9"},{"hash":"e301017012204f2674db0bc7f7cfc0382d1d7f79b4ff73c41f5c487ef4c3bb3f3a4cf3f87d70"},{"hash":"e30101701220e8d4d8b9fb5f805add2f63c1cb5c891e60f9929fc404e3bb725aa81628b97b5f"},{"hash":"e301017012206fdad56fe7a2facb02dabe8294f3ac051443fcc52d67c2fbd8615eb72f9d74bd"},{"hash":"e30101701220a691193cf0559905c10a3c5affb9855d730eae05509d503d71327e6c820aaf98"},{"hash":"e30101701220d8004af925f8e85b4e24813eaa5ef943fa6a0c76035491b64fbd2e632a5cc2fd"},{"hash":"e3010170122049f7bc650615568f14ee1cfa9ceaf89bfbc4745035479a7d8edee9b4465e64de"},{"hash":"e301017012201915dc0faad8e6783aca084a854c03553450efdabf977d57b4f22f73d5c53b50"},{"hash":"e301017012200b9fb71a129048c2a569433efc8e4d9155c54d598538be7f65ea26f665be1e84"},{"hash":"e30101701220d37944e3fb05213d45416fa634cf9e10ec1f43d3bf72c4eb3062ae6cc4ed9b08"},{"hash":"e3010170122059390dca66ba8713a9c323925bf768612f7dd16298c13a07a6b47cb5af4236e6"},{"hash":"e30101701220daaf88ace8a3356559be5d6912d5d442916e3cc92664954526c9815d693dc32b"},{"hash":"e301017012203ae30594fdf56d7bfd686cef1a45c201024e9c10a792722ef07ba968c83c064d"},{"hash":"e3010170122016e5eba0bbd32fc1ff17d80d1247fc67432705cd85731458b52febb84fdd6408"},{"hash":"e3010170122014fe2c2186cbf9d15ff61e04054fd6b0a5dbd7f365a1807f6f3d3d3e93e50875"},{"hash":"e30101701220f23a7dad3ea7ad3f3553a98fb305148d285e4ebf66b427d85a2340f66d51da94"},{"hash":"e3010170122047a637c6af02904a8ae702ec74b3df5fd8914df6fb11c99446a36d890beeb7ee"},{"hash":"e30101701220776f1ff89f6196ae68414545f6c6a5314c35eee7406cb8591d607a2b0533cc86"}],"thumbnail":"e30101701220e9876531554a7cb4f20d7ebbf9daef2253e6734ad9c96ba288586a9b88bef491"},"2":{"author":"ETHDenver","id":2,"name":"ETHDenver Bufficorn","preview":"e30101701220a62487ef23b1bbdc2bf39583bb4259bda032450ac90d199eec8b0b74fe8de580","price":0,"stickers":[{"hash":"e301017012209cba61faaa78931ddee49461ab1301a88a034f077ced9de6351126470b80fe32"},{"hash":"e30101701220e8109e8f4bf398a252bfb8d88fe44554c502c5ab8025e7e1abba692028333a97"},{"hash":"e30101701220079952b304013fe6bcd5ac00a7480e467badece24a19b00ddea64635d9d5ecae"},{"hash":"e301017012200a21dc7c6ef96cdb3f9b53ed1fdea4ee22baa8264a208c3705a8836b664efd8d"},{"hash":"e30101701220b3ab61589851545f2c3ce031beafbf808070c36e6abbaf8c7c8076458c3f06e0"},{"hash":"e30101701220a5274e0415793e1a81347f594715d6006538d78819a731324d3fec19ab762deb"},{"hash":"e3010170122076ae7e71383586ecfa0a6f9cc8af80e614ae466facabe48bee167d2921dd0420"},{"hash":"e30101701220bfe0dd7e214eac7cb75c7e8f6e9b1d02732e01ffc67a460cf3b1311aed92a2e9"},{"hash":"e3010170122042aa1a5e8dc25072ee6d0b43535701fcb44c58b18e6c14a4956a3212f64cf236"},{"hash":"e30101701220107d2ca1901cd8ac0ce54cbf93f5ac86d931c5d4bb16d402315a2a8197dac371"},{"hash":"e301017012206d2d66f7f2fff9f366e910f4d157f7ac59dead3e42b2f9fbe5a9b95aea146d10"},{"hash":"e301017012203a86612e82ea0db8248875e7993e73a65ee263f6bbeb2b1738eb12a6ec572965"},{"hash":"e301017012205bc05fe6517cc00e95e34ba978dd2a5cee91e4dc4efceb4505fecc38887bb7fb"},{"hash":"e301017012203cea2a96032284de80587e994c669a42405d49ce599281866ccc14f475e7870b"}],"thumbnail":"e30101701220d06f13f3de8da081ef2a1bc36ffa283c1bfe093bf45bc0332a6d748196e8ce16"},"5":{"name":"Ghostatus","author":"Brooklyn Design Factory","thumbnail":"e30101701220a7beb4be086ad31ae19c64e5a832853571e239d9799a923a03779c4435c6fdad","preview":"e3010170122027c67c9acbe98786f6db4aabca3fd3ec04993eaa3e08811aefe27d9786c3bf00","stickers":[{"hash":"e30101701220fff8527a1b37070d46c9077877b7f7cc74da5c31adafe77ba65e5efefebf5d91"},{"hash":"e301017012208023d8c6bd327b0ac2be66423d59776a753d5f5492975fe0bd5b5601d7c1d9d3"},{"hash":"e3010170122064f4e8fa00a5b8164689e038a4d74e0b12f4490dcd4112e80057c254f6fbc135"},{"hash":"e301017012200d50bd618b0aed0562ed153de0bf77da766646e81a848982a2f8aaf7d7e94dcc"},{"hash":"e3010170122055f08854a40acaac60355d9bb3eaa730b994e2e13484e67d2675103e0cda0c88"},{"hash":"e301017012203fc2acfed328918bf000ee637ab4c25fa38f2c69b378b69b9212d61747d30c02"},{"hash":"e3010170122096930b99e08c6c28c88c0b74bae7a0159f5c6438ab7d50294987533dabfee863"},{"hash":"e3010170122051ddbe29bee4bbc5fcf50d81faad0872f32b88cea4e4e4fcdbf2daf5d09eda76"},{"hash":"e301017012200647e07651c163515ce34d18b3c8636eeb4798dbaa1766b2a60facc59999b261"},{"hash":"e30101701220c539bfa744e39cf2ece1ab379a15c95338d513a9ce5178d4ad28be486b801bc2"},{"hash":"e301017012205ea333b9eb89918ed592f43372bd58dc3a91a7a71aa68b37369c2f66f931fd87"},{"hash":"e3010170122007f05ba31bd77003bff562ed932a8b440de1ad05481dc622b1c0c571d6b39ffc"},{"hash":"e30101701220906b7a664a87707db72921cf5c7416c61a717dfcb5fcff9bc04b28c612ae554d"}],"id":5,"price":0}}""")

proc saveRecentStickers*(stickers: seq[Sticker]) =
  discard settings.saveSettings("stickers/recent-stickers", %(stickers.mapIt($it.hash)))

proc getInstalledStickers*(): Table[int, StickerPack] =
  let setting = settings.getSetting[string]("stickers/packs-installed", "{}").parseJson
  result = initTable[int, StickerPack]()
  for i in setting.keys:
    result[parseInt(i)] = Json.decode($(setting[i]), StickerPack)

proc getPackIdForSticker*(packs: Table[int, StickerPack], hash: string): int =
  for packId, pack in packs.pairs:
    if pack.stickers.any(proc(sticker: Sticker): bool = return sticker.hash == hash):
      return packId
  return 0

proc getRecentStickers*(): seq[Sticker] =
  # TODO: this should be a custom `readValue` implementation of nim-json-serialization
  let settings = settings.getSetting[seq[string]]("stickers/recent-stickers", @[])
  let installedStickers = getInstalledStickers()
  result = newSeq[Sticker]()
  for hash in settings:
    # pack id is not returned from status-go settings, populate here
    let packId = getPackIdForSticker(getInstalledStickers(), $hash)
    # .insert instead of .add to effectively reverse the order stickers because
    # stickers are re-reversed when added to the view due to the nature of
    # inserting recent stickers at the front of the list
    result.insert(Sticker(hash: $hash, packId: packId), 0)
