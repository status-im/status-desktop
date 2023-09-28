import os

TESTRAIL_RUN_ID = os.getenv('TESTRAIL_RUN_ID', '').strip()
TESTRAIL_URL = os.getenv('TESTRAIL_URL', None)
TESTRAIL_USR = os.getenv('TESTRAIL_USR', None)
TESTRAIL_PWD = os.getenv('TESTRAIL_PWD', None)
