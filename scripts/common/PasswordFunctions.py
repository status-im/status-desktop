from Crypto.Hash import keccak

def hash_password(password, old_desktop=False):
    hasher = keccak.new(digest_bits=256)
    hasher.update(password.encode())
    hash = hasher.hexdigest()
    return '0x' + (hash.upper() if old_desktop else hash.lower())
