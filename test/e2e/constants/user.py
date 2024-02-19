import random
import string
from collections import namedtuple

import configs

UserAccount = namedtuple('User', ['name', 'password', 'seed_phrase', 'status_address'])
user_account_one = UserAccount('squisher', '0000000000', [
    'rail', 'witness', 'era', 'asthma', 'empty', 'cheap', 'shed', 'pond', 'skate', 'amount', 'invite', 'year'
], '0x3286c371ef648fe6232324b27ee0515f4ded24d9')
user_account_two = UserAccount('athletic', '0000000000', [
    'measure', 'cube', 'cousin', 'debris', 'slam', 'ignore', 'seven', 'hat', 'satisfy', 'frown', 'casino', 'inflict'
], '0x99C096bB5F12bDe37DE9dbee8257Ebe2a5667C46')
user_account_three = UserAccount('nervous', '0000000000', [], '')

user_account_one_changed_password = UserAccount('squisher', 'NewPassword@12345', [], '')

user_account_one_changed_name = UserAccount('NewUserName', '0000000000', [], '')

user_with_funds = UserAccount('User_with_funds', '0000000000', [
    'vocal', 'fruit', 'ordinary', 'meadow', 'south', 'athlete', 'inherit', 'since', 'version', 'pitch', 'oppose',
    'lonely'
], '0x26d6e10a6af4eb4d12ff4cf133a843eb4fa88d0b')

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

ens_user_name = ''.join(
    random.choices(string.digits + string.ascii_lowercase, k=8))

community_tags = ['Activism', 'Art', 'Blockchain', 'Books & blogs', 'Career', 'Collaboration', 'Commerce', 'Culture', 'DAO', 'DIY', 'DeFi', 'Design', 'Education', 'Entertainment', 'Environment', 'Ethereum', 'Event', 'Fantasy', 'Fashion', 'Food', 'Gaming', 'Global', 'Health', 'Hobby', 'Innovation', 'Language', 'Lifestyle', 'Local', 'Love', 'Markets', 'Movies & TV', 'Music', 'NFT', 'NSFW', 'News', 'Non-profit', 'Org', 'Pets', 'Play', 'Podcast', 'Politics', 'Privacy', 'Product', 'Psyche', 'Security', 'Social', 'Software dev', 'Sports', 'Tech', 'Travel', 'Vehicles', 'Web3']
