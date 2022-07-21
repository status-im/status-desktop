#include "Helpers/BuildConfiguration.h"

#include <string>

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

}
