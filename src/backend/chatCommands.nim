import json
import core, ../app_service/common/utils
import response_type

proc acceptRequestAddressForTransaction*(
    messageId: string, address: string
): RpcResponse[JsonNode] =
  callPrivateRPC("acceptRequestAddressForTransaction".prefix, %*[messageId, address])

proc declineRequestAddressForTransaction*(messageId: string): RpcResponse[JsonNode] =
  callPrivateRPC("declineRequestAddressForTransaction".prefix, %*[messageId])

proc declineRequestTransaction*(messageId: string): RpcResponse[JsonNode] =
  callPrivateRPC("declineRequestTransaction".prefix, %*[messageId])

proc requestAddressForTransaction*(
    chatId: string, fromAddress: string, amount: string, tokenAddress: string
): RpcResponse[JsonNode] =
  callPrivateRPC(
    "requestAddressForTransaction".prefix, %*[chatId, fromAddress, amount, tokenAddress]
  )

proc requestTransaction*(
    chatId: string, fromAddress: string, amount: string, tokenAddress: string
): RpcResponse[JsonNode] =
  callPrivateRPC(
    "requestTransaction".prefix, %*[chatId, amount, tokenAddress, fromAddress]
  )

proc acceptRequestTransaction*(
    transactionHash: string, messageId: string, signature: string
): RpcResponse[JsonNode] =
  callPrivateRPC(
    "acceptRequestTransaction".prefix, %*[transactionHash, messageId, signature]
  )
