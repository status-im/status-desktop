import web3/ethtypes
import ./dto/contract
import ./dto/method_dto
import ./dto/network
import ./dto/coder
import ./dto/edn_dto
import ./dto/transaction

export contract
export method_dto
export network
export coder
export edn_dto
export transaction

type 
  ServiceInterface* {.pure inheritable.} = ref object of RootObj
  ## Abstract class for this service access.

method delete*(self: ServiceInterface) {.base.} =
  raise newException(ValueError, "No implementation available")

method init*(self: ServiceInterface) {.base.} =
  raise newException(ValueError, "No implementation available")

method findByAddress*(self: ServiceInterface, contracts: seq[Erc20ContractDto], address: Address): Erc20ContractDto 
  {.base.} =
  raise newException(ValueError, "No implementation available")

method findBySymbol*(self: ServiceInterface, contracts: seq[Erc20ContractDto], symbol: string): Erc20ContractDto 
  {.base.} =
  raise newException(ValueError, "No implementation available")

method findContract*(self: ServiceInterface, chainId: int, name: string): ContractDto {.base.} =
  raise newException(ValueError, "No implementation available")

method allErc20Contracts*(self: ServiceInterface): seq[Erc20ContractDto] {.base.} =
  raise newException(ValueError, "No implementation available")

method allErc20ContractsByChainId*(self: ServiceInterface, chainId: int): seq[Erc20ContractDto] {.base.} =
  raise newException(ValueError, "No implementation available")

method findErc20Contract*(self: ServiceInterface, chainId: int, symbol: string): Erc20ContractDto {.base.} =
  raise newException(ValueError, "No implementation available")

method findErc20Contract*(self: ServiceInterface, chainId: int, address: Address): Erc20ContractDto {.base.} =
  raise newException(ValueError, "No implementation available")

method allErc721ContractsByChainId*(self: ServiceInterface, chainId: int): seq[Erc721ContractDto] {.base.} =
  raise newException(ValueError, "No implementation available")

method findErc721Contract*(self: ServiceInterface, chainId: int, name: string): Erc721ContractDto {.base.} =
  raise newException(ValueError, "No implementation available")