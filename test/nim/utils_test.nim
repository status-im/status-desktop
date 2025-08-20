import unittest
import std/strutils

import app/global/utils

suite "utils tests":

  var utils: Utils

  setup:
    # This will run before each test
    echo "Setting up test environment..."
    utils = newUtils()
    utils.setup()

  test "isHexFormat - valid hex strings":
    check utils.isHexFormat("0x1234567890abcdef") == true
    check utils.isHexFormat("0x0") == true
    check utils.isHexFormat("0x123") == true
    check utils.isHexFormat("0xABCDEF") == true
    check utils.isHexFormat("0xabcdef") == true
    check utils.isHexFormat("0x0123456789ABCDEF") == true

  test "isHexFormat - invalid hex strings":
    check utils.isHexFormat("1234567890abcdef") == false  # missing 0x prefix
    check utils.isHexFormat("0x") == false  # empty after prefix
    check utils.isHexFormat("0xGHIJ") == false  # invalid hex characters
    check utils.isHexFormat("0x123g") == false  # contains 'g'
    check utils.isHexFormat("abc123") == false  # no prefix
    check utils.isHexFormat("") == false  # empty string
    check utils.isHexFormat("0x 123") == false  # contains space
    check utils.isHexFormat("0x123-456") == false  # contains dash

  test "isChatKey - valid chat keys (uncompressed)":
    # Valid uncompressed public key (132 characters including 0x)
    let validUncompressed = "0x04" & "a".repeat(128)
    check utils.isChatKey(validUncompressed) == true

    # Another valid uncompressed key
    let validUncompressed2 = "0x04" & "1234567890abcdef".repeat(8)
    check utils.isChatKey(validUncompressed2) == true

  test "isChatKey - valid chat keys (compressed)":
    # Test with actual compressed key format (starts with zQ3sh, 48-50 chars total)
    let validCompressed1 = "zQ3sh123456789ABCDEFGHjkmnpqrstuvwxyzabcdefghijk" # 48 chars
    let validCompressed2 = "zQ3sh123456789ABCDEFGHjkmnpqrstuvwxyzabcdefghijkm" # 49 chars
    let validCompressed3 = "zQ3sh123456789ABCDEFGHjkmnpqrstuvwxyzabcdefghijkmn" # 50 chars

    check utils.isChatKey(validCompressed1) == true
    check utils.isChatKey(validCompressed2) == true
    check utils.isChatKey(validCompressed3) == true

  test "isChatKey - invalid chat keys":
    # Too short
    check utils.isChatKey("0x04" & "a".repeat(60)) == false

    # Too long
    check utils.isChatKey("0x04" & "a".repeat(130)) == false

    # Wrong length for uncompressed (130 chars instead of 132)
    check utils.isChatKey("0x04" & "a".repeat(126)) == false
    
    # Missing 0x prefix
    check utils.isChatKey("04" & "a".repeat(128)) == false

    # Invalid hex characters
    check utils.isChatKey("0x04" & "g".repeat(128)) == false

    # Empty string
    check utils.isChatKey("") == false
    
    # Just 0x
    check utils.isChatKey("0x") == false

  test "isChatKey - edge cases":
    # Test with mixed case
    let mixedCase = "0x04" & "AbCdEf".repeat(21) & "Ab"
    check utils.isChatKey(mixedCase) == true
    
    # Test with valid compressed key format
    let compressedKey = "zQ3sh" & "123456789ABCDEFGHjkmnpqrstuvwxyzabcdefghijk"
    check utils.isChatKey(compressedKey) == true

    # Test with valid length but invalid hex
    let invalidHex = "0x04" & "a".repeat(120) & "xyz12345"
    check utils.isChatKey(invalidHex) == false

  test "isHexFormat and isChatKey integration":
    # A valid chat key should also be a valid hex format (for uncompressed)
    let validChatKey = "0x04" & "1234567890abcdef".repeat(8)
    check utils.isHexFormat(validChatKey) == true
    check utils.isChatKey(validChatKey) == true

    # A valid hex that's not a chat key
    let validHexNotChatKey = "0x123456"
    check utils.isHexFormat(validHexNotChatKey) == true
    check utils.isChatKey(validHexNotChatKey) == false

  test "isChatKey - specific length requirements":
    # Test exactly 132 characters (uncompressed)
    let exactly132 = "0x04" & "1".repeat(128)
    check utils.isChatKey(exactly132) == true
    
    # Test 131 characters (should fail)
    let chars131 = "0x04" & "1".repeat(127)
    check utils.isChatKey(chars131) == false

    # Test 133 characters (should fail)
    let chars133 = "0x04" & "1".repeat(129)
    check utils.isChatKey(chars133) == false

  test "compressed key validation":
    # Test valid compressed key format (48 chars)
    check utils.isCompressedPubKey("zQ3sh123456789ABCDEFGHjkmnpqrstuvwxyzabcdefghijk") == true

    # Test valid compressed key format (50 chars)
    check utils.isCompressedPubKey("zQ3sh123456789ABCDEFGHjkmnpqrstuvwxyzabcdefghjkmno") == true

    # Test invalid prefix
    check utils.isCompressedPubKey("zQ3xx123456789ABCDEFGHjkmnpqrstuvwxyzabcdefg") == false
    
    # Test too short (47 chars)
    check utils.isCompressedPubKey("zQ3sh123456789ABCDEFGHjkmnpqrstuvwxyzabcdef") == false

    # Test too long (51 chars)
    check utils.isCompressedPubKey("zQ3sh123456789ABCDEFGHjkmnpqrstuvwxyzabcdefghjk") == false

    # Test invalid characters (using 'I', 'O', 'l' which are not in the charset)
    check utils.isCompressedPubKey("zQ3sh123456789ABCDEFGHjkmnpqrstuvwxyzabcdeIO") == false
