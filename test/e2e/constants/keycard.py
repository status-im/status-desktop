from enum import Enum


class Keycard(Enum):
    KEYCARD_PIN = '000000'
    KEYCARD_NAME = 'Test Keycard'
    ACCOUNT_NAME = 'Test Account'
    KEYCARD_POPUP_HEADER = 'Create a new Keycard account with a new seed phrase'
    KEYCARD_POPUP_HEADER_IMPORT = 'Import or restore a Keycard via a seed phrase'
    KEYCARD_INSTRUCTIONS_PLUG_IN = 'Plug in Keycard reader...'
    KEYCARD_INSTRUCTIONS_INSERT_KEYCARD = 'Insert Keycard...'
    KEYCARD_RECOGNIZED = 'Keycard recognized'
    KEYCARD_CHOOSE_PIN = 'Choose a Keycard PIN'
    KEYCARD_NOTE = 'It is very important that you do not lose this PIN'
    KEYCARD_REPEAT_PIN = 'Repeat Keycard PIN'
    KEYCARD_PIN_SET = 'Keycard PIN set'
    KEYCARD_NAME_IT = 'Name this Keycard'
    KEYCARD_NAME_ACCOUNTS = 'Name accounts'
    KEYCARD_NEW_ACCOUNT_CREATED = 'New account successfully created'
    KEYCARD_READY = 'Keycard is ready to use!'
