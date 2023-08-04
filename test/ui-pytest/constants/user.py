from collections import namedtuple

UserAccount = namedtuple('User', ['name', 'password'])
user_account = UserAccount('squisher', '*P@ssw0rd*')
user_account_one = UserAccount('tester123', 'TesTEr16843/!@00')
user_account_two = UserAccount('Athletic', 'TesTEr16843/!@00')
user_account_three = UserAccount('Nervous', 'TesTEr16843/!@00')
