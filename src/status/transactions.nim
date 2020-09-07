import
  options, strutils

import
  stint
from eth/common/eth_types import EthAddress
from eth/common/utils import parseAddress

import
  libstatus/types
from libstatus/utils as status_utils import toUInt64, gwei2Wei

proc buildTransaction*(source: EthAddress, value: Uint256, gas = "", gasPrice = ""): EthSend =
  result = EthSend(
    source: source,
    value: value.some,
    gas: (if gas.isEmptyOrWhitespace: Quantity.none else: Quantity(cast[uint64](parseFloat(gas).toUInt64)).some),
    gasPrice: (if gasPrice.isEmptyOrWhitespace: int.none else: gwei2Wei(parseFloat(gasPrice)).truncate(int).some)
  )

proc buildTokenTransaction*(source, contractAddress: EthAddress, gas = "", gasPrice = ""): EthSend =
  result = buildTransaction(source, 0.u256, gas, gasPrice)
  result.to = contractAddress.some