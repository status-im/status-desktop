import os

AUT_PORT = 61500 + int(os.getenv('EXECUTOR_NUMBER', 0))
SERVER_PORT = 4322 + int(os.getenv('EXECUTOR_NUMBER', 0))
CURSOR_ANIMATION = False
