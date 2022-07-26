#pragma once

#include "Helpers/BuildConfiguration.h"

#include <QObject>

#include <string>
#include <map>
#include <memory.h>

namespace Status::Helpers {

constexpr bool isDebugBuild()
{
  #if defined BUILD_DEBUG
    return true;
  #else
    return false;
  #endif
}

/// Case insensitive comparision with optional limitation to first \c len characters
/// \note \c T entry type must support \c tolower
/// \todo test me
template<typename T>
bool iequals(const T& a, const T& b, size_t len = -1)
{
    return len < a.size() && len < b.size() &&
           std::equal(a.begin(), len >= 0 ? a.end() : a.begin() + len,
                      b.begin(), len >= 0 ? b.end() : b.begin() + len,
                      [](auto a, auto b) {
                          return tolower(a) == tolower(b);
                      });
}

template<typename KeyType, typename ValT>
std::vector<KeyType> getKeys(const std::map<KeyType, ValT>& map)
{
    std::vector<KeyType> keys;
    keys.reserve(map.size());
    for (const auto& [key, _] : map)
        keys.push_back(key);
    return keys;
}

static void doDeleteLater(QObject *obj) {
    obj->deleteLater();
}

// TODO: use https://en.cppreference.com/w/cpp/memory/shared_ptr/allocate_shared
template<typename T, typename ...Args>
std::shared_ptr<T> makeSharedQObject(Args&& ...args) {
    return std::shared_ptr<T>(new T(std::forward<Args>(args)...), doDeleteLater);
}

}
