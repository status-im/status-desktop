#include "ChatAPI.h"

#include "Utils.h"
#include "Metadata/api_response.h"

#include <libstatus.h>

#include <nlohmann/json.hpp>

using json = nlohmann::json;

using namespace Status::StatusGo;

Chats::AllChannelGroupsDto Chats::getChats()
{
    json inputJson = {
        {"jsonrpc", "2.0"},
        {"method", "chat_getChats"},
        {"params", json::array()}
    };

    auto result = Utils::statusGoCallPrivateRPC(inputJson.dump().c_str());
    const auto resultJson = json::parse(result);
    checkPrivateRpcCallResultAndReportError(resultJson);

    return resultJson.get<CallPrivateRpcResponse>().result;
}
