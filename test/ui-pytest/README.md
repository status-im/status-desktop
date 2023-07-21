# Status desktop ui-tests

# Setup:
Skip any of the steps, if sure that you have the correct version of the required tool.
## 1. All Platforms
### 1.1 Install Qt 5.15
https://doc.qt.io/qt-6/get-and-install-qt.html
### 1.2 Setup Squish License Server
https://hackmd.io/@status-desktop/HkbWpk2e5
### 1.3 Install PyCharm
Download and install:
https://www.jetbrains.com/pycharm/download/other.html
Please, select any build depending on OS, but NOT an Apple Silicon (dmg)

How to: https://www.jetbrains.com/help/pycharm/installation-guide.html

## 2 Windows
### 2.1 Install Squish
https://status-misc.ams3.digitaloceanspaces.com/squish/squish-7.1-20230301-1424-qt515x-win64-msvc142.exe
### 2.1 Install Python
Download and install for all users: https://www.python.org/ftp/python/3.10.11/python-3.10.11-amd64.exe
### 2.3 Install Requirements
```
YOUR_PYTHON_PATH/Scripts/pip3.10.exe install -r ../ui-pytest/requirements.txt
```
### 2.4 Setup Environment Variables
Add in system environment variables:
```
SQUISH_DIR=PATH_TO_THE_SQUISH_ROOT_FOLDER
PYTHONPATH=%SQUISH_DIR%/bin;%SQUISH_DIR%/lib;%SQUISH_DIR%/lib/python
PATH=YOUR_QT_PATH/5.15.2/msvc2019_64/bin
```
RESTART PC
### 2.5 Verify environment variables
```
echo %SQUISH_DIR%
echo %PYTHONPATH%
```
### 2.6 Setup Python for Squish
Download 'PythonChanger.py' in %SQUISH_DIR%: 
https://kb.froglogic.com/squish/howto/changing-python-installation-used-squish-binary-packages/PythonChanger.py
```
YOUR_PYTHON_PATH/python3.10.exe SQUISH_DIR/PythonChanger.py --revert
YOUR_PYTHON_PATH/python3.10.exe SQUISH_DIR/PythonChanger.py
```
- Replace "YOUR PYTHON PATH" on to Python3.10 file location path 
- Replace "SQUISH DIR" on to the Squish root folder path


## 2 Linux
### 2.1 Install Squish
https://status-misc.ams3.digitaloceanspaces.com/squish/squish-7.1-20230222-1555-qt515x-linux64.run
### 2.2 Install Python
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
### 2.3 Install Requirements
Download and install tesseract-ocr https://github.com/UB-Mannheim/tesseract/wiki
```bash
sudo apt install tesseract-ocr
```
```bash
sudo pip3 install -r ../ui-pytest/requirements.txt
```
### 2.4 Setup Environment Variables
```bash
gedit ~/.profile
```
```
export SQUISH_DIR=PATH_TO_THE_SQUISH_ROOT_FOLDER
export PYTHONPATH=$SQUISH_DIR/lib:$SQUISH_DIR/lib/python:$PYTHONPATH
export LD_LIBRARY_PATH=$SQUISH_DIR/lib:$SQUISH_DIR/python3/lib:$LD_LIBRARY_PATH
```
RESTART PC

## 2. Mac
### 2.1 Install Squish
https://status-misc.ams3.digitaloceanspaces.com/squish/squish-7.1-20230328-1608-qt515x-macaarch64.dmg
### 2.2 Install Intell Python
```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
```
```bash
brew update --auto-update
brew install wget
brew install python@3.10
```
### 2.3 Install Requirements
```bash
brew install tesseract
```
```bash
sudo pip3.10 install -r ../ui-pytest/requirements.txt
```
### 2.4 Setup Environment Variables
```bash
touch ~/.zprofile
open ~/.zprofile
```
```
export SQUISH_DIR=PATH_TO_THE_SQUISH_ROOT_FOLDER
export PYTHONPATH=$SQUISH_DIR/lib:$SQUISH_DIR/lib/python:$PYTHONPATH
export LD_LIBRARY_PATH=$SQUISH_DIR/lib:$LD_LIBRARY_PATH
```
### 2.4.1 Pillow
```bash
sudo open /etc/gdm3/custom.conf
```
Uncomment the line: `WaylandEnable=false` to force the login screen to use Xorg and save changes

RESTART PC

## 2 Linux or MAC:
### 2.5 Verify environment variables
```bash
echo $SQUISH_DIR
echo $PYTHONPATH
echo $LD_LIBRARY_PATH
```
### 2.6. Setup Python for Squish
https://kb.froglogic.com/squish/howto/changing-python-installation-used-squish-binary-packages/
```bash
brew install wget
wget -O $SQUISH_DIR/PythonChanger.py https://kb.froglogic.com/squish/howto/changing-python-installation-used-squish-binary-packages/PythonChanger.py
python3.10 $SQUISH_DIR/PythonChanger.py --revert
python3.10 $SQUISH_DIR/PythonChanger.py
```
### Launch tests examples:
```
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
