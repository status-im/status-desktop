import io_interface
import app_service/service/ens/service as ens_service

type
  Controller* = ref object of RootObj
    delegate: io_interface.AccessInterface
    ensService: ens_service.Service

proc newController*(
  delegate: io_interface.AccessInterface,
  ensService: ens_service.Service,
): Controller =
  result = Controller()
  result.delegate = delegate
  result.ensService = ensService

proc delete*(self: Controller) =
  discard

proc init*(self: Controller) =
  discard

proc resolveEnsAddress*(self: Controller, ensName: string): string =
  # Use ENS utilities for address resolution
  let chainId = self.ensService.getChainId()
  return ens_utils.addressOf(chainId, ensName)

proc resolveEnsResourceUrl*(self: Controller, ensName: string): (string, string, string) =
  # Use existing ENS service method
  return self.ensService.resourceUrl(ensName)
