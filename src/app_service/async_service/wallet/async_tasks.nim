include status/utils/json_utils

#################################################
# Async request for the list of services to buy/sell crypto
#################################################

const asyncGetCryptoServicesTask: Task = proc(argEncoded: string) {.gcsafe, nimcall.} =
  let arg = decode[QObjectTaskArg](argEncoded)
  var success: bool
  let response = status_wallet.fetchCryptoServices(success)

  var list: JsonNode
  if(success):
    list = response.parseJson()["result"]

  arg.finish($list)

#################################################
# Async fetch list of transactions for the address
#################################################
type
  AsyncFetchTransactionsTaskArg = ref object of QObjectTaskArg
    address: string
    toBlock: Uint256
    limit: int
    loadMore: bool

const asyncFetchTransactionTask: Task = proc(argEncoded: string) {.gcsafe, nimcall.} =
  let arg = decode[AsyncFetchTransactionsTaskArg](argEncoded)
  var messages: JsonNode
  var success: bool
  var transactions = status_wallet.getTransfersByAddress(arg.address, arg.toBlock, arg.limit, arg.loadMore, success)

  if(not success):
    transactions = @[]

  let responseJson = %*{
    "address": arg.address,
    "transactions": transactions
  }
  arg.finish(responseJson)