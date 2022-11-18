#include "MessagesApi.h"
#include "Metadata/api_response.h"
#include "InputMessage.h"
#include "Utils.h"

#include <Helpers/conversions.h>

#include <nlohmann/json.hpp>

using json = nlohmann::json;

using namespace Status::StatusGo;

void Messages::sendMessage(const InputMessage &message)
{
    std::vector<json> params{message};
    json inputJson = {{"jsonrpc", "2.0"}, {"method", "wakuext_sendChatMessage"}, {"params", params}};
    const auto result = Utils::statusGoCallPrivateRPC(inputJson.dump().c_str());
    const auto resultJson = json::parse(result);
    checkPrivateRpcCallResultAndReportError(resultJson);
}
