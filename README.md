# nim-status-client

Experiments calling status-go from nim, inspired in [nim-stratus](https://github.com/status-im/nim-stratus) by [@arnetheduck](https://github.com/arnetheduck)

## Building

### 0. Prerequesites

* QT

Linux users should install Qt through the system's package manager:

```
# Debian/Ubuntu:
sudo apt install qtbase5-dev qtdeclarative5-dev qml-module-qt-labs-platform qtquickcontrols2-5-dev
```

If that's not possible, manually install QT from https://www.qt.io/download-qt-installer
and add it to the PATH

```
# Linux
export PATH=$PATH:/path/to/Qt/5.14.2/gcc_64/bin

# macos
export PATH=$PATH:/path/to/Qt/5.14.2/clang_64/bin
```

* Go - (used to build status-go)

```
# Linux
<TODO>

# macOS
brew install go
```

### 1. Install QT, and add it to the PATH

```
# Linux users should use their distro's package manager, but in case they do a manual install:
export PATH=$PATH:/path/to/Qt/5.14.2/gcc_64/bin
export QTDIR=/path/to/Qt/5.14.2/

# macOS:
export PATH=$PATH:/path/to/Qt/5.14.2/clang_64/bin
export QTDIR=/path/to/Qt/5.14.2/
```

### 2. Clone the repo and build `nim-status-client`
```
git clone https://github.com/status-im/nim-status-client
cd nim-status-client
make update
make
```

For more output use `make V=1 ...`.

Use 4 CPU cores with `make -j4 ...`.

Users with manually installed Qt5 packages need to run `make QTDIR="/path/to/Qt" ...`

**Troubleshooting**:

If the `make` command fails due to already installed Homebrew packages, such as:

```
Error: protobuf 3.11.4 is already installed
To upgrade to 3.11.4_1, run `brew upgrade protobuf`.
make[1]: *** [install-os-dependencies] Error 1
make: *** [vendor/status-go/build/bin/libstatus.a] Error 2
```

This can be fixed by uninstalling the package e.g. `brew uninstall protobuf` followed by rerunning `make`.


### 3. Run the app

```
make run
# or
LD_LIBRARY_PATH=vendor/DOtherSide/lib ./bin/nim_status_client
```

## Development

If only making changes in QML `ui/` re-rerunning the app is enough
If making changes in the nim code `src/` then doing `make` again is needed (it's very fast after the first run)

## Cold Reload

### "Cold" reload using VSCode

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
