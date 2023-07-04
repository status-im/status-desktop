import ../../../../../app_service/service/community_tokens/service
import ../../../../../app_service/service/community/dto/community
import ../../../../../app_service/common/types
import ../../../shared_models/currency_amount

type
  AccessInterface* {.pure inheritable.} = ref object of RootObj

method delete*(self: AccessInterface) {.base.} =
  raise newException(ValueError, "No implementation available")

method load*(self: AccessInterface) {.base.} =
  raise newException(ValueError, "No implementation available")

method airdropTokens*(self: AccessInterface, communityId: string, tokensJsonString: string, walletsJsonString: string) {.base.} =
  raise newException(ValueError, "No implementation available")

method computeAirdropFee*(self: AccessInterface, communityId: string, tokensJsonString: string, walletsJsonString: string) {.base.} =
  raise newException(ValueError, "No implementation available")

method selfDestructCollectibles*(self: AccessInterface, communityId: string, collectiblesToBurnJsonString: string, contractUniqueKey: string) {.base.} =
  raise newException(ValueError, "No implementation available")

method burnTokens*(self: AccessInterface, communityId: string, contractUniqueKey: string, amount: float64) {.base.} =
  raise newException(ValueError, "No implementation available")

method deployCollectibles*(self: AccessInterface, communityId: string, address: string, name: string, symbol: string, description: string, supply: float64, infiniteSupply: bool, transferable: bool,
                           selfDestruct: bool, chainId: int, imageCropInfoJson: string) {.base.} =
  raise newException(ValueError, "No implementation available")

method deployAssets*(self: AccessInterface, communityId: string, address: string, name: string, symbol: string, description: string, supply: float64, infiniteSupply: bool, decimals: int,
                     chainId: int, imageCropInfoJson: string) {.base.} =
  raise newException(ValueError, "No implementation available")

method onUserAuthenticated*(self: AccessInterface, password: string) {.base.} =
  raise newException(ValueError, "No implementation available")

method resetTempValues*(self: AccessInterface) {.base.} =
  raise newException(ValueError, "No implementation available")

method computeDeployFee*(self: AccessInterface, chainId: int, accountAddress: string, tokenType: TokenType) {.base.} =
  raise newException(ValueError, "No implementation available")

method computeSelfDestructFee*(self: AccessInterface, collectiblesToBurnJsonString: string, contractUniqueKey: string) {.base.} =
  raise newException(ValueError, "No implementation available")

method computeBurnFee*(self: AccessInterface, contractUniqueKey: string, amount: float64) {.base.} =
  raise newException(ValueError, "No implementation available")

method onDeployFeeComputed*(self: AccessInterface, ethCurrency: CurrencyAmount, fiatCurrency: CurrencyAmount, errorCode: ComputeFeeErrorCode) {.base.} =
  raise newException(ValueError, "No implementation available")

method onSelfDestructFeeComputed*(self: AccessInterface, ethCurrency: CurrencyAmount, fiatCurrency: CurrencyAmount, errorCode: ComputeFeeErrorCode) {.base.} =
  raise newException(ValueError, "No implementation available")

method onAirdropFeesComputed*(self: AccessInterface, args: AirdropFeesArgs) {.base.} =
  raise newException(ValueError, "No implementation available")

method onBurnFeeComputed*(self: AccessInterface, ethCurrency: CurrencyAmount, fiatCurrency: CurrencyAmount, errorCode: ComputeFeeErrorCode) {.base.} =
  raise newException(ValueError, "No implementation available")

method onCommunityTokenDeployStateChanged*(self: AccessInterface, communityId: string, chainId: int, transactionHash: string, deployState: DeployState) {.base.} =
  raise newException(ValueError, "No implementation available")

method onRemoteDestructStateChanged*(self: AccessInterface, communityId: string, tokenName: string, chainId: int, transactionHash: string, status: ContractTransactionStatus) {.base.} =
  raise newException(ValueError, "No implementation available")

method onBurnStateChanged*(self: AccessInterface, communityId: string, tokenName: string, chainId: int, transactionHash: string, status: ContractTransactionStatus) {.base.} =
  raise newException(ValueError, "No implementation available")

method onAirdropStateChanged*(self: AccessInterface, communityId: string, tokenName: string, chainId: int, transactionHash: string, status: ContractTransactionStatus) {.base.} =
  raise newException(ValueError, "No implementation available")
