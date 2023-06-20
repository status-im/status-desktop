import sys, os, re
import sqlcipher3
from getpass import getpass
from common import PasswordFunctions

def open_db(file_path, passwordHash: str):
    db = sqlcipher3.connect(file_path)
    pageSize = 8192 if file_path.endswith("-v4.db") else 1024

    print(f'> Opening database. Selected cipher_page_size: {pageSize}')
    db.execute(f'PRAGMA key = "{passwordHash}"')
    db.execute(f'PRAGMA cipher_page_size = {pageSize}') #1024 for older db, 8192 for newer
    db.execute('PRAGMA kdf_iter = 256000')
    db.execute('PRAGMA cipher_hmac_algorithm = HMAC_SHA1')
    db.execute('PRAGMA cipher_kdf_algorithm = PBKDF2_HMAC_SHA1')
    # db.execute('PRAGMA cipher_compatibility = 3;')

    return db

class Config:
    def __init__(self):
        self.args = sys.argv[1:]

    def input_base_path(self):
        if len(self.args) > 0:
            self.base_path = self.args[0]
        else:
            self.base_path = input('> Input a base path: ')
        if not self.base_path.endswith('/'):
            self.base_path += '/'
            
    def read_accounts(self):
        db = sqlcipher3.connect(self.base_path + '/accounts.sql')
        self.accounts = db.execute('SELECT name, keyUid FROM accounts').fetchall()
        db.close()

        if len(self.accounts) == 0:
            print("no accoutns found")
            exit(0)

        print(f'> Accounts found: ')
        for i, a in enumerate(self.accounts):
            print(f'{i}: {a}')

    def find_database(self):
        regex = re.compile(f'{self.selectedKeyUid}(\-v4)?.db$')
        for _, _, files in os.walk(self.base_path):
            for file in files:
                if regex.match(file):
                    return file
        return ''

    def select_account(self):
        if len(self.args) > 1:
            self.account_index = int(self.args[1])
        else:
            self.account_index = int(input('> Select an account by index: '))
        self.selectedKeyUid = self.accounts[self.account_index][1] # KeyUid is second
        self.database_path = self.base_path + self.find_database()
        print(f'selected database: {self.database_path}')

    def input_password(self):
        if len(self.args) > 2:
            password = self.args[2]
        else:
            password = getpass("> Input password: ")
        config.password_hash = PasswordFunctions.hash_password(password, old_desktop=False)


config = Config()
config.input_base_path()
config.read_accounts()
config.select_account()
config.input_password()

## Select and open database

db = open_db(config.database_path, config.password_hash)

## use the `db` instance to execute queries

tables = db.execute("SELECT name FROM sqlite_master WHERE type='table';").fetchall()
print(f"> Database opened. {len(tables)} tables found.")

## loop sql operations

while True:
    cmd = input("SQL> ")
    if cmd == "exit":
        break
    output = db.execute(cmd).fetchall()
    print(output)

db.close()
