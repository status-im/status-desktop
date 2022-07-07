#include "WalletApi.h"

#include "Utils.h"
#include "Metadata/api_response.h"

#include <libstatus.h>

#include <nlohmann/json.hpp>

#include <iostream>

using json = nlohmann::json;

namespace Status::StatusGo::Wallet
{

DerivedAddresses getDerivedAddressesForPath(const QString &hashedPassword, const QString &derivedFrom, const QString &path, int pageSize, int pageNumber)
{
    std::vector<json> params = {hashedPassword, derivedFrom, path, pageSize, pageNumber};
    json inputJson = {
        {"jsonrpc", "2.0"},
        {"method", "wallet_getDerivedAddressesForPath"},
        {"params", params}
    };

    auto result = Utils::statusGoCallPrivateRPC(inputJson.dump().c_str());
    const auto resultJson = json::parse(result);
    checkPrivateRpcCallResultAndReportError(resultJson);

    return resultJson.get<CallPrivateRpcResponse>().result;
}

} // namespaces
