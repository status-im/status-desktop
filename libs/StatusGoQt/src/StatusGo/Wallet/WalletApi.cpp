#include "WalletApi.h"

#include "Utils.h"
#include "Metadata/api_response.h"

#include "Accounts/accounts_types.h"

#include <libstatus.h>

#include <nlohmann/json.hpp>

#include <iostream>

namespace Accounts = Status::StatusGo::Accounts;

using json = nlohmann::json;

namespace Status::StatusGo::Wallet
{

DerivedAddresses getDerivedAddressesForPath(const HashedPassword &password, const Accounts::EOAddress &derivedFrom, const Accounts::DerivationPath &path, int pageSize, int pageNumber)
{
    std::vector<json> params = {password, derivedFrom, path, pageSize, pageNumber};
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
