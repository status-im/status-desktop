import random
import string
from collections import namedtuple
from dataclasses import dataclass, field
from typing import Optional

import configs
from scripts.utils.generators import random_name_string, random_password_string


@dataclass
class UserAccount:
    name: str = None
    password: str = None
    seed_phrase: Optional[list] = field(default_factory=list)
    status_address: Optional[str] = None


class RandomUser(UserAccount):
    def __init__(self):
        super().__init__(
            name=random_name_string(),
            password=random_password_string()
        )


class ReturningUser(UserAccount):
    def __init__(self, seed_phrase, status_address):
        super().__init__(
            name=random_name_string(),
            password=random_password_string(),
            seed_phrase=seed_phrase,
            status_address=status_address
        )


user_account_one = UserAccount('squisher', '0000000000', [
    'rail', 'witness', 'era', 'asthma', 'empty', 'cheap', 'shed', 'pond', 'skate', 'amount', 'invite', 'year'
], '0x3286c371ef648fe6232324b27ee0515f4ded24d9')
user_account_two = UserAccount('athletic', '0000000000', [
    'measure', 'cube', 'cousin', 'debris', 'slam', 'ignore', 'seven', 'hat', 'satisfy', 'frown', 'casino', 'inflict'
], '0x99C096bB5F12bDe37DE9dbee8257Ebe2a5667C46')

community_params = {
    'name': ''.join(random.choices(string.ascii_letters +
                                   string.digits, k=30)),
    'description': ''.join(random.choices(string.ascii_letters +
                                          string.digits, k=140)),
    'logo': {'fp': configs.testpath.TEST_IMAGES / 'comm_logo.jpeg', 'zoom': None, 'shift': None},
    'banner': {'fp': configs.testpath.TEST_IMAGES / 'comm_banner.jpeg', 'zoom': None, 'shift': None},
    'intro': ''.join(random.choices(string.ascii_letters +
                                    string.digits, k=200)),
    'outro': ''.join(random.choices(string.ascii_letters +
                                    string.digits, k=80))
}

UserCommunityInfo = namedtuple('CommunityInfo', ['name', 'description', 'members', 'image'])
UserChannel = namedtuple('Channel', ['name', 'selected', 'visible'])

account_list_item = namedtuple('AccountListItem', ['name', 'color', 'emoji'])
wallet_account_list_item = namedtuple('WalletAccountListItem', ['name', 'icon_color', 'icon_emoji', 'object'])

account_list_item_2 = namedtuple('AccountListItem', ['name2', 'color2', 'emoji2'])
wallet_account_list_item_2 = namedtuple('WalletAccountListItem', ['name', 'icon', 'object'])

wallet_account = namedtuple('PrivateKeyAddressPair', ['private_key', 'wallet_address'])
private_key_address_pair_1 = wallet_account('2daa36a3abe381a9c01610bf10fda272fbc1b8a22179a39f782c512346e3e470',
                                            '0xd89b48cbcb4244f84a4fb5d3369c120e8f8aa74e')

token_list_item = namedtuple('TokenListItem', ['title', 'object'])

community_tags = ['Activism', 'Art', 'Blockchain', 'Books & blogs', 'Career', 'Collaboration', 'Commerce', 'Culture',
                  'DAO', 'DIY', 'DeFi', 'Design', 'Education', 'Entertainment', 'Environment', 'Ethereum', 'Event',
                  'Fantasy', 'Fashion', 'Food', 'Gaming', 'Global', 'Health', 'Hobby', 'Innovation', 'Language',
                  'Lifestyle', 'Local', 'Love', 'Markets', 'Movies & TV', 'Music', 'NFT', 'NSFW', 'News', 'Non-profit',
                  'Org', 'Pets', 'Play', 'Podcast', 'Politics', 'Privacy', 'Product', 'Psyche', 'Security', 'Social',
                  'Software dev', 'Sports', 'Tech', 'Travel', 'Vehicles', 'Web3']

permission_data = [
    {
        'checkbox_state': True,
        'first_asset': 'Dai Stablecoin',
        'second_asset': False,
        'amount': '10',
        'allowed_to': 'becomeMember',
        'in_channel': False,
        'asset_title': '10 DAI',
        'second_asset_title': False,
        'allowed_to_title': 'Become member'
    },
    {
        'checkbox_state': True,
        'first_asset': 'Ether',
        'second_asset': False,
        'amount': '1',
        'allowed_to': 'becomeAdmin',
        'in_channel': False,
        'asset_title': '1 ETH',
        'second_asset_title': False,
        'allowed_to_title': 'Become an admin'
    },
    {
        'checkbox_state': True,
        'first_asset': 'Ether',
        'second_asset': 'Dai Stablecoin',
        'amount': '10',
        'allowed_to': 'viewAndPost',
        'in_channel': '#general',
        'asset_title': '10 ETH',
        'second_asset_title': '10 DAI',
        'allowed_to_title': 'View and post'
    },
    {
        'checkbox_state': True,
        'first_asset': 'Ether',
        'second_asset': 'Dai Stablecoin',
        'amount': '10',
        'allowed_to': 'viewOnly',
        'in_channel': '#general',
        'asset_title': '10 ETH',
        'second_asset_title': '10 DAI',
        'allowed_to_title': 'View only'
    },
    {
        'checkbox_state': False,
        'first_asset': False,
        'second_asset': False,
        'amount': False,
        'allowed_to': 'becomeAdmin',
        'in_channel': False,
        'asset_title': False,
        'second_asset_title': False,
        'allowed_to_title': 'Become an admin'
    }
]

permission_data_member = [
    {
        'checkbox_state': True,
        'first_asset': 'Dai Stablecoin',
        'amount': '1',
        'allowed_to': 'becomeMember',
        'asset_title': '1 DAI',
        'allowed_to_title': 'Become member'
    },
    {
        'checkbox_state': True,
        'first_asset': 'Aragon',
        'amount': '2',
        'allowed_to': 'becomeMember',
        'asset_title': '2 ANT',
        'allowed_to_title': 'Become member'
    },
    {
        'checkbox_state': True,
        'first_asset': '1inch',
        'amount': '3',
        'allowed_to': 'becomeMember',
        'asset_title': '3 1INCH',
        'allowed_to_title': 'Become member'
    },
    {
        'checkbox_state': True,
        'first_asset': 'ABYSS',
        'amount': '4',
        'allowed_to': 'becomeMember',
        'asset_title': '4 ABYSS',
        'allowed_to_title': 'Become member'
    },
    {
        'checkbox_state': True,
        'first_asset': 'Bytom',
        'amount': '5',
        'allowed_to': 'becomeMember',
        'asset_title': '5 BTM',
        'allowed_to_title': 'Become member'
    }
]
