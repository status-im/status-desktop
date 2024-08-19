import random
import string


def random_name_string():
    return ''.join((random.choice(
        string.ascii_letters + string.digits + random.choice('_- '))
        for _ in range(5, 25))
    ).strip(' ')


def random_password_string():
    return ''.join((random.choice(
        string.ascii_letters + string.digits + string.punctuation)
        for _ in range(10, 28))
    )


def random_ens_string():
    return ''.join(
        random.choices(string.digits + string.ascii_lowercase, k=8))
