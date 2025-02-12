import strutils, base64, times, hashes
import nimcrypto/[aes, bcmode]

const
  KEY_SIZE = 32  # AES-256
  IV_SIZE = 16

  # Generate pseudo-random strings based on compilation time
  COMPILE_TIME = CompileDate & CompileTime
  SEED = hash(COMPILE_TIME)

  # Helper to generate random-looking strings
  CHARSET = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
  
  KEY_PART1 = block:
    var str = ""
    for i in 0..<24:  # 24 chars
      let idx = int((SEED + i * 1337) mod CHARSET.len)
      str.add(CHARSET[idx])
    str

  KEY_PART2 = block:
    var str = ""
    for i in 0..<8:  # 8 chars
      let idx = int((SEED + i * 7331) mod CHARSET.len)
      str.add(CHARSET[idx])
    str

  # Verify key length at compile time
  assert (KEY_PART1.len + KEY_PART2.len) == KEY_SIZE, "Invalid key length"

proc assembleKey(): array[KEY_SIZE, byte] =
  # Combine parts into encryption key
  var key: array[KEY_SIZE, byte]
  copyMem(key[0].addr, KEY_PART1[0].unsafeAddr, KEY_PART1.len)
  copyMem(key[KEY_PART1.len].addr, KEY_PART2[0].unsafeAddr, KEY_PART2.len)
  return key

proc obfuscateCredential*(input: string): string =
  ## Encrypts sensitive data using AES-256-CBC
  if input.len == 0: return ""

  # Generate random IV
  var iv: array[IV_SIZE, byte]
  if not randomBytes(iv):
    raise newException(IOError, "Failed to generate random IV")

  # Get encryption key
  let key = assembleKey()

  # Initialize AES-256-CBC
  var ctx: CBC[aes256]
  ctx.init(key, iv)
  defer: ctx.clear()

  # Pad input
  let blockSize = 16
  var paddedInput = input
  let padding = blockSize - (input.len mod blockSize)
  paddedInput.add(chr(padding).repeat(padding))

  # Encrypt
  var encrypted = newString(paddedInput.len)
  ctx.encrypt(paddedInput.cstring, encrypted.cstring, paddedInput.len)

  # Combine IV and encrypted data
  result = encode(iv & encrypted.toOpenArrayByte(0, encrypted.high))

proc deobfuscateCredential*(input: string): string =
  ## Decrypts data encrypted with obfuscateCredential
  if input.len == 0: return ""

  try:
    let combined = decode(input)
    if combined.len < IV_SIZE: return ""

    # Extract IV and get key
    var iv: array[IV_SIZE, byte]
    copyMem(iv[0].addr, combined[0].addr, IV_SIZE)
    let key = assembleKey()

    # Initialize AES-256-CBC
    var ctx: CBC[aes256]
    ctx.init(key, iv)
    defer: ctx.clear()

    # Decrypt
    let encrypted = combined[IV_SIZE..^1]
    var decrypted = newString(encrypted.len)
    ctx.decrypt(encrypted.cstring, decrypted.cstring, encrypted.len)

    # Remove padding
    let paddingLen = ord(decrypted[^1])
    if paddingLen > 0 and paddingLen <= 16:
      return decrypted[0..^(paddingLen+1)]
    return decrypted

  except Exception:
    return ""

when isMainModule:
  let original = "secret_password123"
  let encrypted = obfuscateCredential(original)
  let decrypted = deobfuscateCredential(encrypted)
  assert decrypted == original
  assert encrypted != original
  echo "Test passed!"