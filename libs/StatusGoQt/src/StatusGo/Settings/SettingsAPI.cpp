#include "SettingsAPI.h"

#include "Utils.h"
#include "Metadata/api_response.h"

#include <libstatus.h>

#include <nlohmann/json.hpp>

using json = nlohmann::json;

using namespace Status::StatusGo;

Settings::SettingsDto Settings::getSettings()
{
    json inputJson = {
        {"jsonrpc", "2.0"},
        {"method", "settings_getSettings"},
        {"params", json::array()}
    };

    auto result = Utils::statusGoCallPrivateRPC(inputJson.dump().c_str());
    const auto resultJson = json::parse(result);
    checkPrivateRpcCallResultAndReportError(resultJson);

    return resultJson.get<CallPrivateRpcResponse>().result;
}
