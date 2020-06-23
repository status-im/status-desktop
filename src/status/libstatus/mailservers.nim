import json, times
import core, utils

proc getMailservers*(): array[0..8, (string, string)] =
  result = [
    (
      "mail-01.ac-cn-hongkong-c.eth.prod",
      "enode://606ae04a71e5db868a722c77a21c8244ae38f1bd6e81687cc6cfe88a3063fa1c245692232f64f45bd5408fed5133eab8ed78049332b04f9c110eac7f71c1b429@47.75.247.214:443"
    ),
    (
      "mail-01.do-ams3.eth.prod",
      "enode://c42f368a23fa98ee546fd247220759062323249ef657d26d357a777443aec04db1b29a3a22ef3e7c548e18493ddaf51a31b0aed6079bd6ebe5ae838fcfaf3a49@178.128.142.54:443"
    ),
    (
      "mail-01.gc-us-central1-a.eth.prod",
      "enode://ee2b53b0ace9692167a410514bca3024695dbf0e1a68e1dff9716da620efb195f04a4b9e873fb9b74ac84de801106c465b8e2b6c4f0d93b8749d1578bfcaf03e@104.197.238.144:443"
    ),
    (
      "mail-02.ac-cn-hongkong-c.eth.prod",
      "enode://2c8de3cbb27a3d30cbb5b3e003bc722b126f5aef82e2052aaef032ca94e0c7ad219e533ba88c70585ebd802de206693255335b100307645ab5170e88620d2a81@47.244.221.14:443"
    ),
    (
      "mail-02.do-ams3.eth.prod",
      "enode://7aa648d6e855950b2e3d3bf220c496e0cae4adfddef3e1e6062e6b177aec93bc6cdcf1282cb40d1656932ebfdd565729da440368d7c4da7dbd4d004b1ac02bf8@178.128.142.26:443"
    ),
    (
      "mail-02.gc-us-central1-a.eth.prod",
      "enode://30211cbd81c25f07b03a0196d56e6ce4604bb13db773ff1c0ea2253547fafd6c06eae6ad3533e2ba39d59564cfbdbb5e2ce7c137a5ebb85e99dcfc7a75f99f55@23.236.58.92:443"
    ),
    (
      "mail-03.ac-cn-hongkong-c.eth.prod",
      "enode://e85f1d4209f2f99da801af18db8716e584a28ad0bdc47fbdcd8f26af74dbd97fc279144680553ec7cd9092afe683ddea1e0f9fc571ebcb4b1d857c03a088853d@47.244.129.82:443"
    ),
    (
      "mail-03.do-ams3.eth.prod",
      "enode://8a64b3c349a2e0ef4a32ea49609ed6eb3364be1110253c20adc17a3cebbc39a219e5d3e13b151c0eee5d8e0f9a8ba2cd026014e67b41a4ab7d1d5dd67ca27427@178.128.142.94:443"
    ),
    (
      "mail-03.gc-us-central1-a.eth.prod",
      "enode://44160e22e8b42bd32a06c1532165fa9e096eebedd7fa6d6e5f8bbef0440bc4a4591fe3651be68193a7ec029021cdb496cfe1d7f9f1dc69eb99226e6f39a7a5d4@35.225.221.245:443"
    )
  ]

proc ping*(timeoutMs: int): string =
  var addresses: seq[string] = @[]
  for mailserver in getMailservers():
    addresses.add(mailserver[1])
  result = callPrivateRPC("mailservers_ping", %* [
    { "addresses": addresses, "timeoutMs": timeoutMs }
  ])

proc update*(peer: string) =
  discard callPrivateRPC("updateMailservers".prefix, %* [[peer]])

proc delete*(peer: string) =
  discard callPrivateRPC("mailservers_deleteMailserver".prefix, %* [[peer]])

proc requestMessages*(topics: seq[string], symKeyID: string, peer: string, numberOfMessages: int) =
  echo callPrivateRPC("requestMessages".prefix, %* [
    {
        "topics": topics,
        "mailServerPeer": peer,
        "symKeyID": symKeyID,
        "timeout": 30,
        "limit": numberOfMessages,
        "cursor": nil,
        "from": (times.toUnix(times.getTime()) - 86400) # Unhardcode this. Need to keep the last fetch in a DB
    }
  ])
