from collections import namedtuple
from enum import Enum


class OnboardingMessages(Enum):
    WRONG_LOGIN_LESS_LETTERS = 'Display Names must be at least 5 character(s) long'
    WRONG_LOGIN_SYMBOLS_NOT_ALLOWED = 'Invalid characters (use A-Z and 0-9, hyphens and underscores only)'
    WRONG_PASSWORD = 'Minimum 10 character(s)'
    PASSWORDS_DONT_MATCH = "Passwords don't match"
    PASSWORD_INCORRECT = 'Password incorrect'


class OnboardingScreensHeaders(Enum):
    YOUR_EMOJIHASH_AND_IDENTICON_RING_SCREEN_TITLE = 'Your emojihash and identicon ring'
    YOUR_PROFILE_SCREEN_TITLE = 'Your profile'


class KeysExistText(Enum):
    KEYS_EXIST_TITLE = 'Keys for this account already exist'
    KEYS_EXIST_TEXT = (
        "Keys for this account already exist and can't be added again. If you've lost your password, passcode or Keycard, uninstall the app, reinstall and access your keys by entering your recovery phrase. In case of Keycard try recovering using PUK or reinstall the app and try login with the Keycard option.")


password_strength_elements = namedtuple('Password_Strength_Elements',
                                        ['strength_indicator', 'strength_color', 'strength_messages'])
very_weak_lower_elements = password_strength_elements('Very weak', '#ff2d55', ['✓ Lower case'])
very_weak_upper_elements = password_strength_elements('Very weak', '#ff2d55', ['✓ Upper case'])
very_weak_numbers_elements = password_strength_elements('Very weak', '#ff2d55', ['✓ Numbers'])
very_weak_symbols_elements = password_strength_elements('Very weak', '#ff2d55', ['✓ Symbols'])
weak_elements = password_strength_elements('Weak', '#fe8f59', ['✓ Numbers', '✓ Symbols'])
okay_elements = password_strength_elements('Okay', '#ffca0f', ['✓ Lower case', '✓ Numbers', '✓ Symbols'])
good_elements = password_strength_elements('Good', '#9ea85d',
                                           ['✓ Lower case', '✓ Upper case', '✓ Numbers', '✓ Symbols'])
strong_elements = password_strength_elements('Very strong', '#4ebc60',
                                             ['✓ Lower case', '✓ Upper case', '✓ Numbers', '✓ Symbols'])
