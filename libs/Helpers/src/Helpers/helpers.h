#include "Helpers/BuildConfiguration.h"

namespace Status::Helpers {

constexpr bool isDebugBuild()
{
  #if defined BUILD_DEBUG
    return true;
  #else
    return false;
  #endif
}

}
