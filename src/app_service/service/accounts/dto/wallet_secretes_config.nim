import json

type WalletSecretsConfig* = object
  poktToken*: string
  infuraToken*: string
  infuraSecret*: string
  openseaApiKey*: string
  raribleMainnetApiKey*: string
  raribleTestnetApiKey*: string
  alchemyEthereumMainnetToken*: string
  alchemyEthereumSepoliaToken*: string
  alchemyArbitrumMainnetToken*: string
  alchemyArbitrumSepoliaToken*: string
  alchemyOptimismMainnetToken*: string
  alchemyOptimismSepoliaToken*: string
  statusProxyStageName*: string
  statusProxyMarketUser*: string
  statusProxyMarketPassword*: string
  statusProxyBlockchainUser*: string
  statusProxyBlockchainPassword*: string

proc toJson*(self: WalletSecretsConfig): JsonNode =
  return
    %*{
      "poktToken": self.poktToken,
      "infuraToken": self.infuraToken,
      "infuraSecret": self.infuraSecret,
      "openseaApiKey": self.openseaApiKey,
      "raribleMainnetApiKey": self.raribleMainnetApiKey,
      "raribleTestnetApiKey": self.raribleTestnetApiKey,
      "alchemyEthereumMainnetToken": self.alchemyEthereumMainnetToken,
      "alchemyEthereumSepoliaToken": self.alchemyEthereumSepoliaToken,
      "alchemyArbitrumMainnetToken": self.alchemyArbitrumMainnetToken,
      "alchemyArbitrumSepoliaToken": self.alchemyArbitrumSepoliaToken,
      "alchemyOptimismMainnetToken": self.alchemyOptimismMainnetToken,
      "alchemyOptimismSepoliaToken": self.alchemyOptimismSepoliaToken,
      "statusProxyStageName": self.statusProxyStageName,
      "statusProxyMarketUser": self.statusProxyMarketUser,
      "statusProxyMarketPassword": self.statusProxyMarketPassword,
      "statusProxyBlockchainUser": self.statusProxyBlockchainUser,
      "statusProxyBlockchainPassword": self.statusProxyBlockchainPassword,
    }
