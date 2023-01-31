#pragma once

#include <string>
#include <memory>

#include <DOtherSide/DOtherSide.h>

extern "C" {
    typedef void (*VoidDeleter)(void *);
    typedef void (*CharDeleter)(char *);
}

using VoidPointer = std::unique_ptr<void, VoidDeleter>;
using CharPointer = std::unique_ptr<char, CharDeleter>;

