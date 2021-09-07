{.used.}

type
  Setting* {.pure.} = enum
    Appearance = "appearance",
    Bookmarks = "bookmarks",
    Currency = "currency"
    EtherscanLink = "etherscan-link"
    InstallationId = "installation-id"
    MessagesFromContactsOnly = "messages-from-contacts-only"
    Mnemonic = "mnemonic"
    Networks_Networks = "networks/networks"
    Networks_CurrentNetwork = "networks/current-network"
    NodeConfig = "node-config"
    PublicKey = "public-key"
    DappsAddress = "dapps-address"
    Stickers_PacksInstalled = "stickers/packs-installed"
    Stickers_Recent = "stickers/recent-stickers"
    Gifs_Recent = "gifs/recent-gifs"
    Gifs_Favorite = "gifs/favorite-gifs"
    WalletRootAddress = "wallet-root-address"
    LatestDerivedPath = "latest-derived-path"
    PreferredUsername = "preferred-name"
    Usernames = "usernames"
    SigningPhrase = "signing-phrase"
    Fleet = "fleet"
    VisibleTokens = "wallet/visible-tokens"
    PinnedMailservers = "pinned-mailservers"
    WakuBloomFilterMode = "waku-bloom-filter-mode"
    SendUserStatus = "send-status-updates?"
    CurrentUserStatus = "current-user-status"