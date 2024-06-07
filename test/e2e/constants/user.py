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

# users for group chat test
group_chat_user_1 = UserAccount('group_chat_user_1', '77_80Y+2Eh', [
    'trophy', 'math', 'robust', 'lake', 'extend', 'cabbage', 'bicycle', 'begin', 'either', 'car', 'race', 'cousin'], '0xcd488381c1664c9585b7940f1c4b20f884b8b4a9')
group_chat_user_2 = UserAccount('group_chat_user_2', '521/97Qv\:', [
    'opera', 'great', 'open', 'sight', 'still', 'quantum', 'flight', 'torch', 'mule', 'cage', 'noise', 'horn'

], '0x472078f0110d0bb0dfc73389ce89d8a83c8c0502')
group_chat_user_3 = UserAccount('group_chat_user_3', '29T\I8Cv_G', [
    'bless', 'enter', 'wet', 'foot', 'lazy', 'will', 'reform', 'enemy', 'rubber', 'void', 'journey', 'fence'
], '0x4b04b8e22e8295d0ae3177774e4acfd0badacf09')

# usernames and passwords for join community test
community_user_1 = UserAccount('community_user_1', '|Br2w547YN', [
    'skirt', 'tired', 'finger', 'dinosaur', 'equal', 'garlic', 'snap', 'tired', 'friend', 'rack', 'net', 'imitate'
], '0x21371358f1ba09204475e87444962ea4519771e1')
community_user_2 = UserAccount('community_user_2', 'vSq5T702_p', [
    'will', 'horn', 'tail', 'stock', 'puzzle', 'warfare', 'pledge', 'uniform', 'ozone', 'taste', 'someone', 'silk'
], '0x935034600f2ba486324cee6ae3f96ad8c8915ac6')

user_with_random_attributes_1 = UserAccount(
''.join((random.choice(
            string.ascii_letters + string.digits + random.choice('_- '))
                for i in range(5, 25))
        ).strip(' '),
        ''.join((random.choice(
            string.ascii_letters + string.digits + string.punctuation)
                for _ in range(10, 28))
        ), [], ''
)

user_with_random_attributes_2 = UserAccount(
''.join((random.choice(
            string.ascii_letters + string.digits + random.choice('_- '))
                for i in range(5, 25))
        ).strip(' '),
        ''.join((random.choice(
            string.ascii_letters + string.digits + string.punctuation)
                for _ in range(10, 28))
        ), [], ''
)

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

token_list_item = namedtuple('TokenListItem', ['title', 'object'])

ens_user_name = ''.join(
    random.choices(string.digits + string.ascii_lowercase, k=8))

community_tags = ['Activism', 'Art', 'Blockchain', 'Books & blogs', 'Career', 'Collaboration', 'Commerce', 'Culture', 'DAO', 'DIY', 'DeFi', 'Design', 'Education', 'Entertainment', 'Environment', 'Ethereum', 'Event', 'Fantasy', 'Fashion', 'Food', 'Gaming', 'Global', 'Health', 'Hobby', 'Innovation', 'Language', 'Lifestyle', 'Local', 'Love', 'Markets', 'Movies & TV', 'Music', 'NFT', 'NSFW', 'News', 'Non-profit', 'Org', 'Pets', 'Play', 'Podcast', 'Politics', 'Privacy', 'Product', 'Psyche', 'Security', 'Social', 'Software dev', 'Sports', 'Tech', 'Travel', 'Vehicles', 'Web3']
