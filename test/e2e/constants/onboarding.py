from enum import Enum


class OnboardingMessages(Enum):
    WRONG_LOGIN_LESS_LETTERS = 'Username must be at least 5 character(s)'
    WRONG_LOGIN_SYMBOLS_NOT_ALLOWED = 'Only letters, numbers, underscores, whitespaces and hyphens allowed'
    WRONG_PASSWORD = 'Password must be at least 10 characters long'
    PASSWORDS_DONT_MATCH = "Passwords don't match"
    PASSWORD_INCORRECT = 'Password incorrect'
