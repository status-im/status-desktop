import random
from typing import Optional
from eth_account.hdaccount import generate_mnemonic, Mnemonic


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

    words = ""
    while not Mnemonic().is_mnemonic_valid(mnemonic=words):
        words = generate_mnemonic(num_words=word_count, lang="english")
    return words


def generate_12_word_seed_phrase() -> str:
    """Generate a 12-word seed phrase."""
    return generate_seed_phrase(12)


def generate_24_word_seed_phrase() -> str:
    """Generate a 24-word seed phrase."""
    return generate_seed_phrase(24)
