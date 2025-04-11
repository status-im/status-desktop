import json

type
  WalletSecretsConfig* = object
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
    alchemyBaseMainnetToken*: string
    alchemyBaseSepoliaToken*: string
    statusProxyStageName*: string
    statusProxyMarketUser*: string
    statusProxyMarketPassword*: string
    marketDataProxyUrl*: string
    marketDataProxyUser*: string
    marketDataProxyPassword*: string
    statusProxyBlockchainUser*: string
    statusProxyBlockchainPassword*: string
    ethRpcProxyUser*: string
    ethRpcProxyPassword*: string
    ethRpcProxyUrl*: string

proc toJson*(self: WalletSecretsConfig): JsonNode =
  return %* {
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
    "alchemyBaseMainnetToken": self.alchemyBaseMainnetToken,
    "alchemyBaseSepoliaToken": self.alchemyBaseSepoliaToken,
    "statusProxyStageName": self.statusProxyStageName,
    "statusProxyMarketUser": self.statusProxyMarketUser,
    "statusProxyMarketPassword": self.statusProxyMarketPassword,
    "marketDataProxyUrl": self.marketDataProxyUrl,
    "marketDataProxyUser": self.marketDataProxyUser,
    "marketDataProxyPassword": self.marketDataProxyPassword,
    "statusProxyBlockchainUser": self.statusProxyBlockchainUser,
    "statusProxyBlockchainPassword": self.statusProxyBlockchainPassword,
    "ethRpcProxyUser": self.ethRpcProxyUser,
    "ethRpcProxyPassword": self.ethRpcProxyPassword,
    "ethRpcProxyUrl": self.ethRpcProxyUrl,
  }
