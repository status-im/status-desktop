import logging
import random
import string
from typing import Optional
from eth_account.hdaccount import Language, generate_mnemonic, Mnemonic
from eth_account import Account

try:
    Account.enable_unaudited_hdwallet_features()
except Exception:
    logging.getLogger(__name__).debug(
        "Failed to enable unaudited HD wallet features", exc_info=True
    )


def generate_seed_phrase(word_count: Optional[int] = None) -> str:
    """Generate a valid BIP39 seed phrase.

    Args:
        word_count: Number of words in the seed phrase (12, 18, or 24).
                   If None, randomly selects from [12, 18, 24].

    Returns:
        Valid BIP39 seed phrase as a string.
    """
    if word_count is None:
        word_count = random.choice([12, 18, 24])

    if word_count not in [12, 18, 24]:
        raise ValueError("word_count must be 12, 18, or 24")

    language = Language.ENGLISH
    mnemonic_helper = Mnemonic(language)

    words = ""
    while not mnemonic_helper.is_mnemonic_valid(mnemonic=words):
        words = generate_mnemonic(num_words=word_count, lang=language)
    return words


def generate_12_word_seed_phrase() -> str:
    """Generate a 12-word seed phrase."""
    return generate_seed_phrase(12)


def generate_24_word_seed_phrase() -> str:
    """Generate a 24-word seed phrase."""
    return generate_seed_phrase(24)


def generate_ethereum_address() -> str:
    """Generate a random EIP-55 checksummed Ethereum address."""
    acct = Account.create()
    return acct.address.lower()


def generate_account_name(length: int = 12) -> str:
    """Generate a simple name for UI entries."""
    length = max(4, min(length, 24))
    letters = string.ascii_letters
    return "".join(random.choice(letters) for _ in range(length))


def get_wallet_address_from_mnemonic(
    seed_phrase: str, derivation_path: str = "m/44'/60'/0'/0/0"
) -> str:
    account = Account.from_mnemonic(seed_phrase, account_path=derivation_path)
    return account.address
