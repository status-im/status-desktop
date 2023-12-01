import unittest

import app/modules/main/wallet_section/wallet_connect/helpers

suite "wallet connect":

  test "parse deep link url":
    const testUrl = "https://status.app/wc?uri=wc%3Aa4f32854428af0f5b6635fb7a3cb2cfe174eaad63b9d10d52ef1c686f8eab862%402%3Frelay-protocol%3Dirn%26symKey%3D4ccbae2b4c81c26fbf4a6acee9de2771705d467de9a1d24c80240e8be59de6be"

    let (resOk, wcUri) = extractAndCheckUriParameter(testUrl)

    check(resOk)
    check(wcUri == "wc:a4f32854428af0f5b6635fb7a3cb2cfe174eaad63b9d10d52ef1c686f8eab862@2?relay-protocol=irn&symKey=4ccbae2b4c81c26fbf4a6acee9de2771705d467de9a1d24c80240e8be59de6be")

  test "parse another valid deep link url":
    const testUrl = "https://status.app/notwc?uri=lt%3Asomevalue"

    let (resOk, wcUri) = extractAndCheckUriParameter(testUrl)

    check(not resOk)
    check(wcUri == "")

  test "parse a WC no-prefix deeplink":
    const testUrl = "https://status.app/wc?uri=w4%3Atest"

    let (resOk, wcUri) = extractAndCheckUriParameter(testUrl)

    check(not resOk)
    check(wcUri == "")
