from collections import namedtuple

import configs

UserAccount = namedtuple('User', ['name', 'password', 'seed_phrase'])
user_account_one = UserAccount('squisher', '*P@ssw0rd*', [
    'rail', 'witness', 'era', 'asthma', 'empty', 'cheap', 'shed', 'pond', 'skate', 'amount', 'invite', 'year'
])
user_account_two = UserAccount('athletic', '*P@ssw0rd*', [
    'measure', 'cube', 'cousin', 'debris', 'slam', 'ignore', 'seven', 'hat', 'satisfy', 'frown', 'casino', 'inflict'
])
user_account_three = UserAccount('Nervous', 'TesTEr16843/!@00', [])

community_params = {
    'name': 'Name',
    'description': 'Description',
    'logo': {'fp': configs.testpath.TEST_FILES / 'tv_signal.png', 'zoom': None, 'shift': None},
    'banner': {'fp': configs.testpath.TEST_FILES / 'banner.png', 'zoom': None, 'shift': None},
    'intro': 'Intro',
    'outro': 'Outro'
}

UserCommunityInfo = namedtuple('CommunityInfo', ['name', 'description', 'members', 'image'])
UserChannel = namedtuple('Channel', ['name', 'image', 'selected'])

account_list_item = namedtuple('AccountListItem', ['name', 'color', 'emoji'])