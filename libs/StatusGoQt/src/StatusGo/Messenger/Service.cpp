#include "Service.h"

#include "Utils.h"

namespace Status::StatusGo::Messenger
{

bool startMessenger()
{
    QJsonObject payload{
        {"jsonrpc", "2.0"},
        {"method", "wakuext_startMessenger"},
        {"params", QJsonArray()}
    };

    auto callResult = Utils::callPrivateRpc<QJsonObject>(Utils::jsonToByteArray(payload));
    if(callResult.containsError())
        qWarning() << "Failed starting Messenger service. Error: " << callResult.error.message;
    return !callResult.containsError();
}

}
