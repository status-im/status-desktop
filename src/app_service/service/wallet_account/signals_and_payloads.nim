import backend/helpers/token

#################################################
# Special signal emitted by main module and handled in wallet account service
#################################################

const SIGNAL_IMPORT_PARTIALLY_OPERABLE_ACCOUNTS* = "importPartiallyOperableAccounts"

#################################################
# Signals emitted by wallet account service
#################################################

const SIGNAL_WALLET_ACCOUNT_SAVED* = "walletAccount/accountSaved"
const SIGNAL_WALLET_ACCOUNT_DELETED* = "walletAccount/accountDeleted"
const SIGNAL_WALLET_ACCOUNT_UPDATED* = "walletAccount/walletAccountUpdated"
const SIGNAL_WALLET_ACCOUNT_NETWORK_ENABLED_UPDATED* = "walletAccount/networkEnabledUpdated"
const SIGNAL_WALLET_ACCOUNT_TOKENS_REBUILT* = "walletAccount/tokensRebuilt"
const SIGNAL_WALLET_ACCOUNT_TOKENS_BEING_FETCHED* = "walletAccount/tokenFetching"
const SIGNAL_WALLET_ACCOUNT_DERIVED_ADDRESSES_FETCHED* = "walletAccount/derivedAddressesFetched"
const SIGNAL_WALLET_ACCOUNT_DERIVED_ADDRESSES_FROM_MNEMONIC_FETCHED* = "walletAccount/derivedAddressesFromMnemonicFetched"
const SIGNAL_WALLET_ACCOUNT_ADDRESS_DETAILS_FETCHED* = "walletAccount/addressDetailsFetched"
const SIGNAL_WALLET_ACCOUNT_POSITION_UPDATED* = "walletAccount/positionUpdated"
const SIGNAL_WALLET_ACCOUNT_OPERABILITY_UPDATED* = "walletAccount/operabilityUpdated"
const SIGNAL_WALLET_ACCOUNT_CHAIN_ID_FOR_URL_FETCHED* = "walletAccount/chainIdForUrlFetched"
const SIGNAL_WALLET_ACCOUNT_PREFERRED_SHARING_CHAINS_UPDATED* = "walletAccount/preferredSharingChainsUpdated"
const SIGNAL_WALLET_ACCOUNT_HIDDEN_UPDATED* = "walletAccount/accountHiddenChanged"

const SIGNAL_KEYPAIR_SYNCED* = "keypairSynced"
const SIGNAL_KEYPAIR_NAME_CHANGED* = "keypairNameChanged"
const SIGNAL_KEYPAIR_DELETED* = "keypairDeleted"
const SIGNAL_IMPORTED_KEYPAIRS* = "importedKeypairs"

const SIGNAL_NEW_KEYCARD_SET* = "newKeycardSet"
const SIGNAL_KEYCARD_REBUILD* = "keycardRebuild"
const SIGNAL_KEYCARD_DELETED* = "keycardDeleted"
const SIGNAL_ALL_KEYCARDS_DELETED* = "allKeycardsDeleted"
const SIGNAL_KEYCARD_ACCOUNTS_REMOVED* = "keycardAccountsRemoved"
const SIGNAL_KEYCARD_LOCKED* = "keycardLocked"
const SIGNAL_KEYCARD_UNLOCKED* = "keycardUnlocked"
const SIGNAL_KEYCARD_UID_UPDATED* = "keycardUidUpdated"
const SIGNAL_KEYCARD_NAME_CHANGED* = "keycardNameChanged"

#################################################
# Payload sent via above defined signals
#################################################

type ImportAccountsArgs* = ref object of Args
  keyUid*: string
  password*: string

type AccountArgs* = ref object of Args
  account*: WalletAccountDto

type KeypairArgs* = ref object of Args
  keypair*: KeypairDto
  keyPairName*: string
  oldKeypairName*: string

type KeypairsArgs* = ref object of Args
  keypairs*: seq[KeypairDto]
  error*: string

type KeycardArgs* = ref object of Args
  success*: bool
  oldKeycardUid*: string
  keycard*: KeycardDto

type DerivedAddressesArgs* = ref object of Args
  uniqueId*: string
  derivedAddresses*: seq[DerivedAddressDto]
  error*: string

type TokensPerAccountArgs* = ref object of Args
  accountsTokens*: OrderedTable[string, seq[WalletTokenDto]] # [wallet address, list of tokens]
  hasBalanceCache*: bool
  hasMarketValuesCache*: bool

type KeycardActivityArgs* = ref object of Args
  success*: bool
  oldKeycardUid*: string
  keycard*: KeycardDto

type ChainIdForUrlArgs* = ref object of Args
  chainId*: int
  success*: bool
  url*: string
  isMainUrl*: bool
