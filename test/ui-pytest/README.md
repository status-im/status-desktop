# Status desktop ui-tests

# Setup:
Skip any of the steps, if sure that you have the correct version of the required tool.
## All Platforms
### 1. Install Qt 5.15
https://doc.qt.io/qt-6/get-and-install-qt.html
### 2. Setup Squish License Server
https://hackmd.io/@status-desktop/HkbWpk2e5
### 3. Install PyCharm
Download and install:
https://www.jetbrains.com/pycharm/download/other.html
Please, select any build depending on OS, but NOT an Apple Silicon (dmg)

How to: https://www.jetbrains.com/help/pycharm/installation-guide.html

## Windows
### 4. Install Squish
https://status-misc.ams3.digitaloceanspaces.com/squish/squish-7.1-20230301-1424-qt515x-win64-msvc142.exe
### 5. Install Python
Download and install for all users: https://www.python.org/ftp/python/3.10.11/python-3.10.11-amd64.exe
### 6. Install Requirements
```
YOUR_PYTHON_PATH/pip3.exe install -r ./requirements.txt
```
### 7. Setup Environment Variables
Add in system environment variables:
```
SQUISH_DIR=PATH_TO_THE_SQUISH_ROOT_FOLDER
PYTHONPATH=%SQUISH_DIR%/lib;%SQUISH_DIR%/lib/python;%PYTHONPATH%
```
RESTART PC
### 8. Verify environment variables
```
echo %SQUISH_DIR%
echo %PYTHONPATH%
```
### 9. Setup Python for Squish
Download 'PythonChanger.py' in %SQUISH_DIR%: 
https://kb.froglogic.com/squish/howto/changing-python-installation-used-squish-binary-packages/PythonChanger.py
```
YOUR_PYTHON_PATH/python3.10 SQUISH_DIR/PythonChanger.py --revert
YOUR_PYTHON_PATH/python3.10 SQUISH_DIR/PythonChanger.py
```
- Replace "YOUR PYTHON PATH" on to Python3.10 file location path 
- Replace "SQUISH DIR" on to the Squish root folder path
### 10 Test:
Executing tests located in 'test_self.py' file
```
pytest ./tests/test_self.py
```
Executing test 'test_import_squish' from 'test_self.py' file
```
pytest ./tests/test_self.py::test_import_squish
```
Executing all tests with 'import_squish' in test name
```
pytest -k import_squish
```
Executing all tests with tag 'self'
```
pytest -m self
```

## Linux
### 4. Install Squish
https://status-misc.ams3.digitaloceanspaces.com/squish/squish-7.1-20230222-1555-qt515x-linux64.run
### 5. Install Python
```bash
sudo apt-get install software-properties-common
```
```bash
sudo add-apt-repository ppa:deadsnakes/ppa
```
```bash
sudo apt-get update
```
```bash
sudo apt-get install python3.10
```
```bash
sudo apt install python3-pip
```
### 6. Install Requirements
```bash
sudo pip3 install -r ./requirements.txt
```
### 7. Setup Environment Variables
```bash
gedit ~/.profile
```
```
export SQUISH_DIR=PATH_TO_THE_SQUISH_ROOT_FOLDER
export PYTHONPATH=$SQUISH_DIR/lib:$SQUISH_DIR/lib/python:$PYTHONPATH
export LD_LIBRARY_PATH=$SQUISH_DIR/lib:$SQUISH_DIR/python3/lib:$LD_LIBRARY_PATH
```
RESTART PC

## Mac
### 4. Install Squish
https://status-misc.ams3.digitaloceanspaces.com/squish/squish-7.1-20230328-1608-qt515x-macaarch64.dmg
### 5. Install Python
```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
```
```bash
brew update --auto-update
brew install wget
brew install python@3.10
```
### 6. Install Requirements
```bash
sudo pip3 install -r ./requirements.txt
```
### 7. Setup Environment Variables
```bash
touch ~/.zprofile
open ~/.zprofile
```
```
export SQUISH_DIR=PATH_TO_THE_SQUISH_ROOT_FOLDER
export PYTHONPATH=$SQUISH_DIR/lib:$SQUISH_DIR/lib/python:$PYTHONPATH
export LD_LIBRARY_PATH=$SQUISH_DIR/lib:$LD_LIBRARY_PATH
```
RESTART PC

## Linux or MAC:
### 8. Verify environment variables
```bash
echo $USERNAME
echo $PYTHONPATH
echo $LD_LIBRARY_PATH
```
### 9. Setup Python for Squish
https://kb.froglogic.com/squish/howto/changing-python-installation-used-squish-binary-packages/
```bash
brew install wget
wget -O $SQUISH_DIR/PythonChanger.py https://kb.froglogic.com/squish/howto/changing-python-installation-used-squish-binary-packages/PythonChanger.py
python3.10 $SQUISH_DIR/PythonChanger.py --revert
python3.10 $SQUISH_DIR/PythonChanger.py
```
### 10 Test:
```bash
echo "Executing tests located in 'test_self.py' file"
pytest ./tests/test_self.py
echo "Executing test 'test_import_squish' from 'test_self.py' file"
pytest ./tests/test_self.py::test_import_squish
echo "Executing all tests with 'import_squish' in test name"
pytest -k import_squish
echo "Executing all tests with tag 'self'"
pytest -m self
```
For more info, read: https://docs.pytest.org/en/latest/getting-started.html
