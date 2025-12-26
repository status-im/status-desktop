# Windows Build Process Fixes

This document explains the automated fixes added to the Makefile for Windows/MinGW builds.

## Overview

Three main issues were fixed and automated:
1. **nim-sds library build** - Ensures the library is built before linking
2. **Import library generation** - Creates `.dll.a` files for MinGW from DLLs
3. **DLL copying** - Copies all required DLLs to `bin/` directory for runtime

## Changes Made

### 1. nim-sds Build Automation

**Location:** Lines ~255-282 in Makefile

**What it does:**
- Builds the `nim-sds` library if it doesn't exist
- On Windows, automatically creates the import library (`libsds.dll.a`) after building the DLL
- Uses `dlltool` to generate the import library from the DLL

**Key targets:**
- `nim-sds` - Builds nim-sds library and import library (Windows only)
- `$(NIMSDS_LIBFILE)` - Dependency that triggers the build

**How it works:**
```makefile
$(NIMSDS_LIBFILE): | deps
    # Builds libsds.dll
    $(MAKE) -C $(NIM_SDS_SOURCE_DIR) libsds
    
    # Creates import library
    dlltool --dllname libsds.dll --def libsds.def --output-lib libsds.dll.a
```

### 2. StatusQ Import Library Generation

**Location:** Lines ~376-397 in Makefile

**What it does:**
- After StatusQ is installed, automatically creates `libStatusQ.dll.a` import library
- Creates a `.def` file with the exported symbols (`statusq_registerQmlTypes`, `statusq_getMobileUIScaleFactor`)
- Uses `dlltool` to generate the MinGW-compatible import library

**Key targets:**
- `statusq-import-lib` - Creates the import library
- `statusq` - Now depends on `statusq-import-lib` on Windows

**Files created:**
- `bin/StatusQ/StatusQ.def` - Module definition file
- `bin/StatusQ/libStatusQ.dll.a` - Import library for MinGW

**How it works:**
```makefile
$(STATUSQ_DEF): $(STATUSQ_DLL)
    # Creates .def file with exports
    echo "EXPORTS" > StatusQ.def
    echo "statusq_registerQmlTypes" >> StatusQ.def
    echo "statusq_getMobileUIScaleFactor" >> StatusQ.def

$(STATUSQ_IMPORT_LIB): $(STATUSQ_DLL) $(STATUSQ_DEF)
    # Creates import library
    dlltool --dllname StatusQ.dll --def StatusQ.def --output-lib libStatusQ.dll.a
```

### 3. DLL Copying for Runtime

**Location:** Lines ~680-690 in Makefile

**What it does:**
- Copies all required DLLs to the `bin/` directory before building
- Ensures the executable can find DLLs at runtime (Windows searches the executable's directory)

**Key targets:**
- `copy-windows-dlls` - Copies all DLLs to bin/

**DLLs copied:**
- `StatusQ.dll`
- `DOtherSide.dll`
- `libstatus.dll`
- `libkeycard.dll`
- `libsds.dll`

**How it works:**
```makefile
copy-windows-dlls: | statusq dotherside $(STATUSGO) $(STATUSKEYCARDGO) $(NIMSDS_LIBFILE)
    cp $(STATUSQ_INSTALL_PATH)/StatusQ/StatusQ.dll $(STATUSQ_INSTALL_PATH)/
    cp $(DOTHERSIDE_LIBFILE) $(STATUSQ_INSTALL_PATH)/
    # ... copies other DLLs
```

### 4. Updated Dependencies

**Location:** Line ~692 in Makefile

**What changed:**
- `nim_status_client` now depends on:
  - `nim-sds` (Windows only) - Ensures nim-sds is built
  - `copy-windows-dlls` (Windows only) - Ensures DLLs are in place

**Before:**
```makefile
$(NIM_STATUS_CLIENT): ... | statusq dotherside ...
```

**After:**
```makefile
$(NIM_STATUS_CLIENT): ... | statusq dotherside ... $(if $(filter win32,$(mkspecs)),nim-sds copy-windows-dlls)
```

## Requirements

### Tools Required

1. **dlltool** - Part of MinGW toolchain
   - Location: Usually in `C:\ProgramData\scoop\apps\gcc\current\bin\dlltool.exe`
   - Used to create import libraries from DLLs

2. **nim-sds source** - Must be cloned
   - Default location: `../nim-sds` (relative to status-app)
   - Can be overridden with `NIM_SDS_SOURCE_DIR` environment variable

## Usage

### Normal Build

Just run the normal build command:
```bash
make nim_status_client
```

The build process will automatically:
1. Build nim-sds if needed
2. Build StatusQ and create import library
3. Copy DLLs to bin directory
4. Build the executable

### Manual Steps (if needed)

If you need to rebuild just the import libraries:

```bash
# Rebuild StatusQ import library
make statusq-import-lib

# Rebuild nim-sds import library  
make nim-sds

# Copy DLLs manually
make copy-windows-dlls
```

## Troubleshooting

### Error: "dlltool not found"
- Ensure MinGW is installed and in PATH
- Or set the full path to dlltool in the Makefile

### Error: "nim-sds directory not found"
- Clone nim-sds: `git clone https://github.com/waku-org/nim-sds.git ../nim-sds`
- Or set `NIM_SDS_SOURCE_DIR` environment variable

### Import library creation fails silently
- Check that `dlltool` is available: `which dlltool` (Git Bash) or `where dlltool` (PowerShell)
- Verify the DLL exists before creating import library
- Check the `.def` file was created correctly

## Technical Details

### Why Import Libraries Are Needed

On Windows with MinGW:
- MSVC creates `.lib` files (not compatible with MinGW linker)
- MinGW linker needs `.dll.a` import libraries
- These contain stub functions that redirect to the DLL at runtime

### Symbol Export

The `statusq_registerQmlTypes` function is exported from StatusQ.dll using:
- `Q_DECL_EXPORT` macro in C++
- `extern "C"` linkage for C compatibility
- Listed in the `.def` file for import library generation

## Future Improvements

1. **Auto-detect exports** - Use `objdump` or `pexports` to automatically extract symbols
2. **Better error handling** - Fail build if import library creation fails
3. **Cleanup targets** - Add targets to remove generated import libraries
4. **Cross-platform** - Ensure these changes don't affect Linux/macOS builds

