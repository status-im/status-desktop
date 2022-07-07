#include "General.h"

#include "Utils.h"

#include <libstatus.h>

namespace Status::StatusGo::General
{

RpcResponse<QJsonObject> initKeystore(const char* keystoreDir)
{
    try
    {
        auto result = InitKeystore(const_cast<char*>(keystoreDir));
        QJsonObject jsonResult;
        if(!Utils::checkReceivedResponse(result, jsonResult)) {
            throw std::domain_error("parsing response failed");
        }

        return Utils::buildPrivateRPCResponse(jsonResult);
    }
    catch (std::exception& e)
    {
        // TODO: either use optional/smartpointers or exceptions instead of plain objects
        auto response = RpcResponse<QJsonObject>(QJsonObject());
        // TODO: don't translate exception messages. Exceptions are for developers and should never reach users
        response.error.message = QObject::tr("an error opening accounts occurred, msg: %1").arg(e.what());
        return response;
    }
    catch (...)
    {
        auto response = RpcResponse<QJsonObject>(QJsonObject());
        response.error.message = QObject::tr("an error opening accounts occurred");
        return response;
    }
}

}
