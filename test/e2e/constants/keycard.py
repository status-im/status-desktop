from enum import Enum


class Keycard(Enum):
    KEYCARD_PIN = '111111'
    KEYCARD_INCORRECT_PIN = '222222'
    KEYCARD_CORRECT_PUK = '111111111111'
    KEYCARD_INCORRECT_PUK = '222222222222'
    KEYCARD_NAME = 'Test Keycard'
    ACCOUNT_NAME = 'Test Account'
    KEYCARD_POPUP_HEADER_CREATE_SEED = 'Create a new Keycard account with a new seed phrase'
    KEYCARD_POPUP_HEADER_IMPORT_SEED = 'Import or restore a Keycard via a seed phrase'
    KEYCARD_POPUP_HEADER_SET_UP_EXISTING = 'Set up a new Keycard with an existing account'
    KEYCARD_INSTRUCTIONS_PLUG_IN = 'Plug in Keycard reader...'
    KEYCARD_INSTRUCTIONS_INSERT_KEYCARD = 'Insert Keycard...'
    KEYCARD_RECOGNIZED = 'Keycard recognized'
    KEYCARD_CHOOSE_PIN = 'Choose a Keycard PIN'
    KEYCARD_ENTER_PIN = "Enter this Keycard’s PIN"
    KEYCARD_ENTER_PIN_2 = "Enter Keycard PIN"
    KEYCARD_PIN_NOTE = 'It is very important that you do not lose this PIN'
    KEYCARD_REPEAT_PIN = 'Repeat Keycard PIN'
    KEYCARD_PIN_SET = 'Keycard PIN set'
    KEYCARD_PIN_VERIFIED = 'Keycard PIN verified!'
    KEYCARD_NAME_KEYCARD = 'Name this Keycard'
    KEYCARD_NAME_ACCOUNTS = 'Name accounts'
    KEYCARD_NEW_ACCOUNT_CREATED = 'New account successfully created'
    KEYCARD_READY = 'Keycard is ready to use!'
    KEYCARD_SELECT_KEYPAIR = 'Select a key pair'
    KEYCARD_SELECT_WHICH_PAIR = 'Select which key pair you’d like to move to this Keycard'
    KEYCARD_KEYPAIR_INFO = 'Moving this key pair will require you to use your Keycard to login'
    KEYCARD_MIGRATING = 'Migrating key pair to Keycard'
    KEYCARD_KEYPAIR_MIGRATED = 'Keypair successfully migrated'
    KEYCARD_COMPLETE_MIGRATION = 'To complete migration close Status and log in with your new Keycard'
    KEYCARD_EMPTY = 'Keycard is empty'
    KEYCARD_NO_KEYPAIR = 'There is no key pair on this Keycard'
    KEYCARD_NOT = 'This is not a Keycard'
    KEYCARD_NOT_RECOGNIZED_NOTE = 'The card inserted is not a recognised Keycard,\nplease remove and try and again'
    KEYCARD_LOCKED = 'Keycard locked'
    KEYCARD_LOCKED_NOTE = 'You will need to unlock it before proceeding'
    KEYCARD_ACCOUNTS = 'Accounts on this Keycard'
    KEYCARD_FACTORY_RESET_TITLE = 'A factory reset will delete the key on this Keycard.\nAre you sure you want to do this?'
    KEYCARD_FACTORY_RESET_SUCCESSFUL = 'Keycard successfully factory reset'
    KEYCARD_YOU_CAN_USE_AS_EMPTY = 'You can now use this Keycard as if it\nwas a brand new empty Keycard'
    KEYCARD_INCORRECT_PIN_MESSAGE = 'PIN incorrect'
    KEYCARD_4_ATTEMPTS_REMAINING = '4 attempts remaining'
    KEYCARD_3_ATTEMPTS_REMAINING = '3 attempts remaining'
    KEYCARD_2_ATTEMPTS_REMAINING = '2 attempts remaining'
    KEYCARD_1_ATTEMPT_REMAINING = '1 attempt remaining'
    KEYCARD_LOCKED_INCORRECT_PIN = 'Pin entered incorrectly too many times'
    KEYCARD_LOCKED_INCORRECT_PUK = 'Puk entered incorrectly too many times'
    KEYCARD_UNLOCK = 'Unlock this Keycard'
    KEYCARD_ENTER_PUK = 'Enter PUK'
    KEYCARD_UNLOCK_SUCCESSFUL = 'Unlock successful'
    KEYCARD_PUK_IS_INCORRECT = 'The PUK is incorrect, try entering it again'