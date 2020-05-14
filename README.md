# nim-status-client

Experiments calling status-go from nim, inspired in [nim-stratus](https://github.com/status-im/nim-stratus) by [@arnetheduck](https://github.com/arnetheduck)

### 1. Install nim 1.2.0

```
# linux
apt-get install nim

# macos
brew install nim
```

### 2. Install QT, and add it to the PATH

```
# Linux
export PATH=$PATH:/path/to/Qt/5.14.2/gcc_64/bin

# macos
export PATH=$PATH:/path/to/Qt/5.14.2/clang_64/bin
```

### 3. Clone and build DOtherside

For Linux:

```
sudo apt-get install build-essential libgl1-mesa-dev
sudo apt-get install doxygen
```

```
git clone https://github.com/filcuc/DOtherSide
cd DOtherSide
mkdir build && cd build
cmake ..
make
```

### 4. Setup Library Path

```
export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/path/to/dotherside/build/lib
```

### 5. Copy libstatus to repo

Copy `libstatus.a` to the `./lib` folder. Can be obtained from `status-react/result` by executing `make status-go-desktop`.
**macos:** rename `libstatus.a` to `libstatus.dylib` _before_ copying over. Alternatively, modify `desktop/default.nix` to output `libstatus.dylib` before copying over.

### 6. Install nim dependencies

Ignore errors about `nim_status_client` failing to build.

```
nimble install
```

### 7. Build `nim-status-client`

```
# linux
make build

# macos
make build-osx
```

### 8. Run the app

```
./bin/nim_status_client
```

### 9. "Cold" reload using VSCode

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
