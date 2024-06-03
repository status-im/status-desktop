from enum import Enum


class SyncingSettings(Enum):
    SYNC_A_NEW_DEVICE_INSTRUCTIONS_HEADER = 'Sync a New Device'
    SYNC_A_NEW_DEVICE_INSTRUCTIONS_SUBTITLE = 'You own your data. Sync it among your devices.'
    SYNC_CODE_IS_WRONG_TEXT = 'This does not look like a sync code'
    SYNC_SETUP_ERROR_PRIMARY = 'Failed to generate sync code'
    SYNC_SETUP_ERROR_SECONDARY = 'Failed to start pairing server'
