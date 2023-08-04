import os

TESTRAIL_RUN_ID = os.getenv('TESTRAIL_URL', '').strip()
TESTRAIL_URL = os.getenv('TESTRAIL_URL', None)
TESTRAIL_USER = os.getenv('TESTRAIL_USER', None)
TESTRAIL_PWD = os.getenv('TESTRAIL_PWD', None)
