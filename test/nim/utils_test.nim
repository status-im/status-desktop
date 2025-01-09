import unittest, strutils

import app/global/utils/time_utils

suite "adding timestamp to url":
  test "adding timestamp to an image url with query containing ?":
    let url =
      "https://Localhost:35651/contactImages?imageName=thumbnail?publicKey=0x04d76f84ec"
    let result = time_utils.addTimestampToURL(url)

    check(result.startsWith(url & "&timestamp="))

  test "adding timestamp to an image url with query containing &":
    let url =
      "https://Localhost:35651/contactImages&imageName=thumbnail&publicKey=0x04d76f84e8dc"
    let result = time_utils.addTimestampToURL(url)

    check(result.startsWith(url & "?timestamp="))

  test "image contains a mix of & and ? queries, & is added":
    let url =
      "https://Localhost:35651/contactImages?imageName=thumbnail&publicKey=0x04d76f84e8dc"
    let result = time_utils.addTimestampToURL(url)

    check(result.startsWith(url & "&timestamp="))

  test "adding timestamp to an empty image url":
    let result = time_utils.addTimestampToURL("")

    let expectedResult = ""
    check(result == expectedResult)
