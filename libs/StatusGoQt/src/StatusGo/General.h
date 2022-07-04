#pragma once

#include "Types.h"

#include <QJsonObject>

namespace Status::StatusGo::General
{

RpcResponse<QJsonObject> initKeystore(const char* keystoreDir);

}
