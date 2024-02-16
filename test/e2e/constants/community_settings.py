from enum import Enum


class PermissionsElements(Enum):
    WELCOME_TITLE = "Permissions"
    WELCOME_SUBTITLE = 'You can manage your community by creating and issuing membership and access permissions'
    WELCOME_CHECKLIST_ELEMENT_1 = 'Give individual members access to private channels'
    WELCOME_CHECKLIST_ELEMENT_2 = 'Monetise your community with subscriptions and fees'
    WELCOME_CHECKLIST_ELEMENT_3 = 'Require holding a token or NFT to obtain exclusive membership rights'


class TokensElements(Enum):
    WELCOME_TITLE = "Community tokens"
    WELCOME_SUBTITLE = 'You can mint custom tokens and import tokens for your community'
    WELCOME_CHECKLIST_ELEMENT_1 = 'Create remotely destructible soulbound tokens for admin permissions'
    WELCOME_CHECKLIST_ELEMENT_2 = 'Reward individual members with custom tokens for their contribution'
    WELCOME_CHECKLIST_ELEMENT_3 = 'Mint tokens for use with community and channel permissions'
    INFOBOX_TITLE = 'Get started'
    INFOBOX_TEXT = 'In order to Mint, Import and Airdrop community tokens, you first need to mint your Owner token which will give you permissions to access the token management features for your community.'


class AirdropsElements(Enum):
    WELCOME_TITLE = "Airdrop community tokens"
    WELCOME_SUBTITLE = 'You can mint custom tokens and collectibles for your community'
    WELCOME_CHECKLIST_ELEMENT_1 = 'Reward individual members with custom tokens for their contribution'
    WELCOME_CHECKLIST_ELEMENT_2 = 'Incentivise joining, retention, moderation and desired behaviour'
    WELCOME_CHECKLIST_ELEMENT_3 = 'Require holding a token or NFT to obtain exclusive membership rights'
    INFOBOX_TITLE = 'Get started'
    INFOBOX_TEXT = 'In order to Mint, Import and Airdrop community tokens, you first need to mint your Owner token which will give you permissions to access the token management features for your community.'


class ToastMessages(Enum):
    CREATE_PERMISSION_TOAST = 'Community permission created'
    UPDATE_PERMISSION_TOAST = 'Community permission updated'
    DELETE_PERMISSION_TOAST = 'Community permission updated'
