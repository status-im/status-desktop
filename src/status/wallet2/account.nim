import options, json, strformat

from ../../eventemitter import Args
import ../types

type CollectibleList* = ref object
    collectibleType*, collectiblesJSON*, error*: string
    loading*: int

type Collectible* = ref object
    name*, image*, id*, collectibleType*, description*, externalUrl*: string

type OpenseaCollection* = ref object
    name*, slug*, imageUrl*: string
    ownedAssetCount*: int

type OpenseaAsset* = ref object
    id*: int
    name*, description*, permalink*, imageThumbnailUrl*, imageUrl*, address*: string

type CurrencyArgs* = ref object of Args
    currency*: string

type Asset* = ref object
    name*, symbol*, value*, fiatBalanceDisplay*, fiatBalance*,  accountAddress*, address*: string

type WalletAccount* = ref object
    name*, address*, iconColor*, path*, walletType*, publicKey*: string
    balance*: Option[string]
    realFiatBalance*: Option[float]
    assetList*: seq[Asset]
    wallet*, chat*: bool
    collectiblesLists*: seq[CollectibleList]
    transactions*: tuple[hasMore: bool, data: seq[Transaction]]

proc newWalletAccount*(name, address, iconColor, path, walletType, publicKey: string,
  wallet, chat: bool, assets: seq[Asset]): WalletAccount =
  result = new WalletAccount
  result.name = name
  result.address = address
  result.iconColor = iconColor
  result.path = path
  result.walletType = walletType
  result.publicKey = publicKey
  result.wallet = wallet
  result.chat = chat
  result.assetList = assets
  result.balance = none[string]()
  result.realFiatBalance = none[float]()

type AccountArgs* = ref object of Args
    account*: WalletAccount

proc `$`*(self: OpenseaCollection): string =
  return fmt"OpenseaCollection(name:{self.name}, slug:{self.slug}, owned asset count:{self.ownedAssetCount})"

proc `$`*(self: OpenseaAsset): string =
  return fmt"OpenseaAsset(id:{self.id}, name:{self.name}, address:{self.address}, imageUrl: {self.imageUrl}, imageThumbnailUrl: {self.imageThumbnailUrl})"

proc toOpenseaCollection*(jsonCollection: JsonNode): OpenseaCollection =
    return OpenseaCollection(
        name: jsonCollection{"name"}.getStr,
        slug: jsonCollection{"slug"}.getStr,
        imageUrl: jsonCollection{"image_url"}.getStr,
        ownedAssetCount: jsonCollection{"owned_asset_count"}.getInt
    )

proc toOpenseaAsset*(jsonAsset: JsonNode): OpenseaAsset =
    return OpenseaAsset(
        id: jsonAsset{"id"}.getInt,
        name: jsonAsset{"name"}.getStr,
        description: jsonAsset{"description"}.getStr,
        permalink: jsonAsset{"permalink"}.getStr,
        imageThumbnailUrl: jsonAsset{"image_thumbnail_url"}.getStr,
        imageUrl: jsonAsset{"image_url"}.getStr,
        address: jsonAsset{"asset_contract"}{"address"}.getStr
    )