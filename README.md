# nim-status-client

Experiments calling status-go from nim, inspired in [nim-stratus](https://github.com/status-im/nim-stratus) by [@arnetheduck](https://github.com/arnetheduck)

![Image](screenRec.gif)

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

Copy `libstatus.a` to the root folder. Can be obtained from `status-react/result` by executing `make status-go-desktop`.
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
./nim_status_client
```
