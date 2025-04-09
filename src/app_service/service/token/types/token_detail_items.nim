# In case of community tokens only the description will be available
type TokenDetailsItem* = ref object of RootObj
    description*: string
    assetWebsiteUrl*: string

type
  TokenPreferencesItem* = ref object of RootObj
    key*: string
    position*: int
    groupPosition*: int
    visible*: bool
    communityId*: string

type
  TokenMarketValuesItem* = object
    marketCap*: float64
    highDay*: float64
    lowDay*: float64
    changePctHour*: float64
    changePctDay*: float64
    changePct24hour*: float64
    change24hour*: float64
