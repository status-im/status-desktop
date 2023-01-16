import sha3
import pyperclip

print("Type your password...")
password = input()

hasher = sha3.keccak_256()
hasher.update(password.encode())
hash = '0x' + hasher.hexdigest().upper()
pyperclip.copy(hash)

print(f'Hash: {hash} is copied to clipboard')