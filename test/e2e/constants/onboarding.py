from collections import namedtuple
from enum import Enum


class OnboardingMessages(Enum):
    WRONG_LOGIN_LESS_LETTERS = 'Username must be at least 5 character(s)'
    WRONG_LOGIN_SYMBOLS_NOT_ALLOWED = 'Only letters, numbers, underscores, periods, whitespaces and hyphens allowed'
    WRONG_PASSWORD = 'Password must be at least 10 characters long'
    PASSWORDS_DONT_MATCH = "Passwords don't match"
    PASSWORD_INCORRECT = 'Password incorrect'


password_strength_elements = namedtuple('Password_Strength_Elements',
                                        ['strength_indicator', 'strength_color', 'strength_messages'])
very_weak_lower_elements = password_strength_elements('Very weak', '#ff2d55', ['• Lower case'])
very_weak_upper_elements = password_strength_elements('Very weak', '#ff2d55', ['• Upper case'])
very_weak_numbers_elements = password_strength_elements('Very weak', '#ff2d55', ['• Numbers'])
very_weak_symbols_elements = password_strength_elements('Very weak', '#ff2d55', ['• Symbols'])
weak_elements = password_strength_elements('Weak', '#fe8f59', ['• Numbers', '• Symbols'])
so_so_elements = password_strength_elements('So-so', '#ffca0f', ['• Lower case', '• Numbers', '• Symbols'])
good_elements = password_strength_elements('Good', '#9ea85d',
                                           ['• Lower case', '• Upper case', '• Numbers', '• Symbols'])
great_elements = password_strength_elements('Great', '#4ebc60',
                                            ['• Lower case', '• Upper case', '• Numbers', '• Symbols'])
