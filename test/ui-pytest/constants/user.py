from collections import namedtuple

UserAccount = namedtuple('User', ['name', 'password', 'seed_phrase'])
user_account_default = UserAccount('squisher', '*P@ssw0rd*', [
    'rail', 'witness', 'era', 'asthma', 'empty', 'cheap', 'shed', 'pond', 'skate', 'amount', 'invite', 'year'
])
user_account_one = UserAccount('tester123', 'TesTEr16843/!@00', [])
user_account_two = UserAccount('Athletic', 'TesTEr16843/!@00', [])
user_account_three = UserAccount('Nervous', 'TesTEr16843/!@00', [])


UserCommunity = namedtuple('Community', ['name', 'description', 'members', 'image'])
