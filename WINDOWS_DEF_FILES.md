# Windows Import Library Definition Files

This document describes the `.def` files used to create MinGW import libraries on Windows.

## File Locations

### Static Template Files (for reference/documentation)
- `windows-build-files/libsds.def` - Definition file for nim-sds library
- `windows-build-files/StatusQ.def` - Definition file for StatusQ library

### Generated Files (created during build)
- `../nim-sds/build/libsds.def` - Generated from Makefile (line 261-274)
- `bin/StatusQ/StatusQ.def` - Generated from Makefile (line 393-396)

## File Contents

### libsds.def
```
EXPORTS
SdsCleanupReliabilityManager
SdsMarkDependenciesMet
SdsNewReliabilityManager
SdsResetReliabilityManager
SdsSetEventCallback
SdsStartPeriodicTasks
SdsUnwrapReceivedMessage
SdsWrapOutgoingMessage
libsdsNimDestroyGlobals
libsdsNimMain
```

### StatusQ.def
```
EXPORTS
statusq_getMobileUIScaleFactor
statusq_registerQmlTypes
```

## Makefile Changes

The `.def` files are automatically generated in the Makefile at:

### libsds.def generation (lines 261-274)
```makefile
$(NIMSDS_DEF): $(NIMSDS_DLL)
	@echo -e "\033[92mCreating:\033[39m libsds.def"
	@mkdir -p $(NIMSDS_LIBDIR)
	@(echo "EXPORTS"; \
	  echo "SdsCleanupReliabilityManager"; \
	  echo "SdsMarkDependenciesMet"; \
	  echo "SdsNewReliabilityManager"; \
	  echo "SdsResetReliabilityManager"; \
	  echo "SdsSetEventCallback"; \
	  echo "SdsStartPeriodicTasks"; \
	  echo "SdsUnwrapReceivedMessage"; \
	  echo "SdsWrapOutgoingMessage"; \
	  echo "libsdsNimDestroyGlobals"; \
	  echo "libsdsNimMain") > $(NIMSDS_DEF)
```

### StatusQ.def generation (lines 393-396)
```makefile
$(STATUSQ_DEF): $(STATUSQ_DLL)
	@echo -e "\033[92mCreating:\033[39m StatusQ.def"
	@mkdir -p $(STATUSQ_INSTALL_PATH)/StatusQ || true
	@(echo "EXPORTS"; \
	  echo "statusq_getMobileUIScaleFactor"; \
	  echo "statusq_registerQmlTypes") > $(STATUSQ_DEF)
```

## Purpose

These `.def` files list the exported symbols from the DLLs. They are used by `dlltool` to create MinGW-compatible import libraries (`.dll.a` files) that allow the linker to resolve symbols at link time.

## Why These Symbols?

### libsds.def
All symbols exported from `libsds.dll` as determined by:
```bash
objdump -p libsds.dll | grep Sds
```

These are the C functions that status-go's CGO code calls.

### StatusQ.def
The two C functions exported from StatusQ.dll:
- `statusq_registerQmlTypes` - Called from Nim to register QML types
- `statusq_getMobileUIScaleFactor` - Called from Nim for mobile UI scaling

## Alternative: Using Static Files

If you prefer to use the static files instead of generating them, you could modify the Makefile to copy from the static location:

```makefile
$(NIMSDS_DEF): windows-build-files/libsds.def
	@mkdir -p $(NIMSDS_LIBDIR)
	@cp windows-build-files/libsds.def $(NIMSDS_DEF)
```

However, the current approach (generating them) ensures they're always in sync with the actual DLL exports.

