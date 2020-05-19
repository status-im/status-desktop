# nim-status-client

Experiments calling status-go from nim, inspired in [nim-stratus](https://github.com/status-im/nim-stratus) by [@arnetheduck](https://github.com/arnetheduck)

## Building

### 1. Prerequisites

* QT: Install QT https://www.qt.io/download-qt-installer and add it to the PATH
```
# Linux
export PATH=$PATH:/path/to/Qt/5.14.2/gcc_64/bin

# macos
export PATH=$PATH:/path/to/Qt/5.14.2/clang_64/bin
```

Linux users can also install Qt through the system's package manager:
```
# Debian/Ubuntu:
sudo apt install qtbase5-dev qtdeclarative5-dev qml-module-qt-labs-platform
```

* go - (used to build status-go)
```
# linux
Follow the instructions on https://golang.org/doc/install

# macos
brew install go
```

* The following packages are required in Ubuntu:
```
sudo apt install build-essential cmake mesa-common-dev libglu1-mesa-dev libpcre++-dev
```

### 2. Clone the repo and build `nim-status-client`
```
git clone https://github.com/status-im/nim-status-client/ --recurse-submodules
make
```

if you previously cloned the repo without the `--recurse-submodule` options, then do

```
git submodule update --init --recursive
make
```

for more output use `make V=1`

**Trouble Shooting**:

If the `make` command fails due to already installed homebrew packages, such as:

```
Error: protobuf 3.11.4 is already installed
To upgrade to 3.11.4_1, run `brew upgrade protobuf`.
make[1]: *** [install-os-dependencies] Error 1
make: *** [vendor/status-go/build/bin/libstatus.a] Error 2
```

This can be fixed by uninstalling the package e.g. `brew uninstall protobuf` followed by rerunning `make`.


### 3. Setup Library Path
```
export LD_LIBRARY_PATH=vendor/DOtherSide/build/lib/
```

### 4. Run the app

```
./bin/nim_status_client
```

## Development

If only making changes in QML `ui/` re-rerunning the app is enough
If making changes in the nim code `src/` then doing `make` again is needed (it's very fast after the first run)

## Cold Reload

### 5. "Cold" reload using VSCode

We can setup a "cold" reload, whereby the app will be rebuilt and restarted when changes in the source are saved. This will not save state, as the app will be restarted, but it will save us some time from manually restarting the app. We can handily force an app rebuild/relaunch with the shortcut `Cmd+Shift+b` (execute the default build task, which we'll setup below).

To enable a meagre app reload during development, first creates a task in `.vscode/tasks.json`. This task sets up the default build task for the workspace, and depends on the task that compiles our nim:

```json
({
  "label": "Build Nim Status Client",
  "type": "shell",
  "command": "nim",
  "args": [
    "c",
    "-L:lib/libstatus.dylib",
    "-L:-lm",
    "-L:\"-framework Foundation -framework Security -framework IOKit -framework CoreServices\"",
    "--outdir:./bin",
    "src/nim_status_client.nim"
  ],
  "options": {
    "cwd": "${workspaceRoot}"
  }
},
{
  "label": "Run nim_status_client",
  "type": "shell",
  "command": "bash",
  "args": ["./run.sh"],
  "options": {
    "cwd": "${workspaceRoot}/.vscode"
  },
  "dependsOn": ["Build Nim Status Client"],
  "group": {
    "kind": "build",
    "isDefault": true
  }
})
```

Next, add a `.vscode/run.sh` file, changing the `DOtherSide` lib path to be specific to your environment:

```bash
export LD_LIBRARY_PATH="/Users/emizzle/repos/github.com/filcuc/DOtherSide/build/lib"
../bin/nim_status_client
```

# Auto build on save (for the "cold" reload effect)

Finally, to get trigger this default build task when our files our saved, we need to enable a task to be run while `.nim` files are saved, and when `.qml` files are saved.

### Build on save

To build on save of our source files, first install the "Trigger Task on Save" VS Code extension to detect changes to our changable files, which will trigger a build/run. Once installed, update `settings.json` like so:

```json
"files.autoSave": "afterDelay",
"triggerTaskOnSave.tasks": {
  "Run nim_status_client": ["ui/**/*", "src/*.nim"]
},
"triggerTaskOnSave.restart": true,
"triggerTaskOnSave.showStatusBarToggle": true

```


# Building windows release
This has been tested only on Linux Ubuntu and Windows 10

### Generating the executable
1. Install the toolchain for cross compiling Linux->Windows
```
sudo apt install mingw-w64
curl https://www.libsdl.org/release/SDL2-devel-2.0.12-mingw.tar.gz > SDL2-devel-2.0.12-mingw.tar.gz
tar xvfz SDL2-devel-2.0.12-mingw.tar.gz
sudo cp -r SDL2-2.0.12/x86_64-w64-mingw32/bin/* /usr/x86_64-w64-mingw32/bin/.
sudo cp -r SDL2-2.0.12/x86_64-w64-mingw32/include/SDL2/* /usr/x86_64-w64-mingw32/include/.
sudo cp -r SDL2-2.0.12/x86_64-w64-mingw32/include/lib/* /usr/x86_64-w64-mingw32/lib/.
rm -Rf SDL2-devel-2.0.12-mingw.tar.gz SDL2-2.0.12/
```
2. `make build-windows`

### Preparing executable for usage
> **TODO:** These instructions need to be automated somehow, maybe using AppVeyor since it already has a QT environment installed. 
All these instructions must be executed in Windows, and you must have QT installed
1. Create the following structure:
```
C:/status 
--> ui/
--> client/
```
2. Download and unzip the latest DLL release from [status-im/dotherside](https://github.com/status-im/dotherside/releases/download/v0.6.5-win-status-go/libDOtherside-windows-msvc2017_x64-qt-5.13.2.zip)
3. Place `DOtherSide.dll` inside `C:/status/client/`
4. From the nim-status-client repo, copy the content of [`ui`](https://github.com/status-im/nim-status-client/tree/master/ui) inside `C:/status/ui`
5. Copy the QT dlls and plugiins with:
```
C:\Qt\5.14.2\msvc2017_64\bin>windeployqt.exe C:\status\client\DOtherSide.dll --qmldir C:\status\ui 
```
6. Done, you can now execute `C:/status/client/nim_status_client.exe` in a console
