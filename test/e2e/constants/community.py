from enum import Enum


class PermissionsElements(Enum):
    WELCOME_TITLE = "Permissions"
    WELCOME_SUBTITLE = 'You can manage your community by creating and issuing membership and access permissions'
    WELCOME_CHECKLIST_ELEMENT_1 = 'Give individual members access to private channels'
    WELCOME_CHECKLIST_ELEMENT_2 = 'Monetise your community with subscriptions and fees'
    WELCOME_CHECKLIST_ELEMENT_3 = 'Require holding a token or NFT to obtain exclusive membership rights'
    DUPLICATE_WARNING = 'Permission with same properties is already active, edit properties to create a new permission.'


class TokensElements(Enum):
    WELCOME_TITLE = "Community tokens"
    WELCOME_SUBTITLE = 'You can mint custom tokens and import tokens for your community'
    WELCOME_CHECKLIST_ELEMENT_1 = 'Create remotely destructible soulbound tokens for admin permissions'
    WELCOME_CHECKLIST_ELEMENT_2 = 'Reward individual members with custom tokens for their contribution'
    WELCOME_CHECKLIST_ELEMENT_3 = 'Mint tokens for use with community and channel permissions'
    INFOBOX_TITLE = 'Get started'
    INFOBOX_TEXT = 'In order to Mint, Import and Airdrop community tokens, you first need to mint your Owner token which will give you permissions to access the token management features for your community.'


class MintOwnerTokensElements(Enum):
    OWNER_TOKEN_CHEKLIST_ELEMENT_1 = 'Only 1 will ever exist'
    OWNER_TOKEN_CHEKLIST_ELEMENT_2 = 'Hodler is the owner of the Community'
    OWNER_TOKEN_CHEKLIST_ELEMENT_3 = 'Ability to airdrop / destroy TokenMaster token'
    OWNER_TOKEN_CHEKLIST_ELEMENT_4 = 'Ability to mint and airdrop Community tokens'
    MASTER_TOKEN_CHEKLIST_ELEMENT_1 = 'Unlimited supply'
    MASTER_TOKEN_CHEKLIST_ELEMENT_2 = 'Grants full Community admin rights'
    MASTER_TOKEN_CHEKLIST_ELEMENT_3 = 'Ability to mint and airdrop Community tokens'
    MASTER_TOKEN_CHEKLIST_ELEMENT_4 = 'Non-transferrable'
    MASTER_TOKEN_CHEKLIST_ELEMENT_5 = 'Remotely destructible by the Owner token hodler'
    SIGN_TRANSACTION_MINT_TITLE = ' Owner and TokenMaster tokens on '
    OWNER_TOKEN_NAME = 'Owner-'
    MASTER_TOKEN_NAME = 'TMaster-'
    OWNER_TOKEN_SYMBOL = 'OWN'
    MASTER_TOKEN_SYMBOL = 'TM'
    TOAST_AIRDROPPING_TOKEN_1 = 'Airdropping '
    TOAST_AIRDROPPING_TOKEN_2 = ' Owner token to you...'
    TOAST_TOKENS_BEING_MINTED = ' Owner and TokenMaster tokens are being minted...'


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
    DELETE_PERMISSION_TOAST = 'Community permission deleted'
    KICKED_USER_TOAST = ' was kicked from '
    BLOCKED_USER_TOAST = ' blocked'
    UNBLOCKED_USER_TOAST = ' unblocked'
    REMOVED_CONTACT_TOAST = 'Contact removed'
    BANNED_USER_TOAST = ' was banned from '
    UNBANNED_USER_TOAST = ' unbanned from '
    UNBANNED_USER_CONFIRM = 'You were unbanned from '


class LimitWarnings(Enum):
    MEMBER_ROLE_LIMIT_WARNING = 'Max of 5 ‘become member’ permissions for this Community has been reached. You will need to delete an existing ‘become member’ permission before you can add a new one.'


class BlockPopupWarnings(Enum):
    BLOCK_WARNING_PART_1 = 'Blocking a user purges the database of all messages that you’ve previously received from '
    BLOCK_WARNING_PART_2 = ' in all contexts. This can take a moment.'
    UNBLOCK_TEXT_1 = 'Unblocking '
    UNBLOCK_TEXT_2 = ' will allow new messages you receive from '
    UNBLOCK_TEXT_3 = ' to reach you.'


class Channel(Enum):
    DEFAULT_CHANNEL_NAME = 'general'
    DEFAULT_CHANNEL_DESC = 'General channel for the community'
