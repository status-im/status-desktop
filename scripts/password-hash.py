import pyperclip
from common import PasswordFunctions

print("Type your password...")
password = input()
hash = PasswordFunctions.hash_password(password)
pyperclip.copy(hash)
print(f'Hash: {hash} is copied to clipboard')

