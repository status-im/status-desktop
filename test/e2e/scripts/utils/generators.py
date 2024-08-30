import random
import string
from zpywallet import HDWallet
from zpywallet.network import EthereumMainNet
from eth_account.hdaccount import generate_mnemonic, Mnemonic


def random_name_string():
    return ''.join((random.choice(
        string.ascii_letters + string.digits + random.choice('_- '))
        for _ in range(5, 25))
    ).strip(' ')


def random_password_string():
    return ''.join((random.choice(
        string.ascii_letters + string.digits + string.punctuation)
        for _ in range(10, 28))
    )


def random_ens_string():
    return ''.join(
        random.choices(string.digits + string.ascii_lowercase, k=8))


def random_mnemonic():
    words = ''
    while not Mnemonic().is_mnemonic_valid(mnemonic=words):
        new_words = generate_mnemonic(num_words=random.choice([12, 18, 24]), lang='english')
        words = new_words
    return words


def random_wallet_account_name():
    return ''.join((random.choice(
        string.ascii_letters + string.digits)
        for _ in range(5, 21)))


def get_wallet_address_from_mnemonic(mnemonic_data) -> str:
    w = HDWallet.from_mnemonic(mnemonic=mnemonic_data, passphrase='', network=EthereumMainNet)
    child_w = w.get_child_for_path("m/44'/60'/0'/0/0")
    address_from_mnemonic = child_w.address()
    return address_from_mnemonic
