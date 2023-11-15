import os

CI_BUILD_URL = os.getenv('BUILD_URL', '')

RUN_NAME = os.getenv('TESTRAIL_RUN_NAME', '')
PROJECT_ID = os.getenv('TESTRAIL_PROJECT_ID', '')
URL = os.getenv('TESTRAIL_URL', '')
USR = os.getenv('TESTRAIL_USR', '')
PSW = os.getenv('TESTRAIL_PSW', '')
