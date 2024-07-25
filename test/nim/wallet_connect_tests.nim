import unittest

import app/modules/shared_modules/wallet_connect/helpers

suite "wallet connect":

  test "hexToDec":
    check(hexToDec("0x3") == "3")
    check(hexToDec("f") == "15")

  test "convertFeesInfoToHex":
    const feesInfoJson = "{\"maxFees\":\"24528.282681\",\"maxFeePerGas\":1.168013461,\"maxPriorityFeePerGas\":0.036572351,\"gasPrice\":\"1.168013461\"}"

    check(convertFeesInfoToHex(feesInfoJson) == """{"maxFeePerGas":"0x459E7895","maxPriorityFeePerGas":"0x22E0CBF"}""")
