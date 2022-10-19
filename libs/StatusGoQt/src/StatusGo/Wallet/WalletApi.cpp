#include "WalletApi.h"

#include "Metadata/api_response.h"
#include "Utils.h"

#include "Accounts/accounts_types.h"

#include <libstatus.h>

#include <nlohmann/json.hpp>

#include <iostream>

namespace Accounts = Status::StatusGo::Accounts;

using json = nlohmann::json;

namespace Status::StatusGo::Wallet
{

DerivedAddresses getDerivedAddressesForPath(const HashedPassword& password,
                                            const Accounts::EOAddress& derivedFrom,
                                            const Accounts::DerivationPath& path,
                                            int pageSize,
                                            int pageNumber)
{
    std::vector<json> params = {password, derivedFrom, path, pageSize, pageNumber};
    json inputJson = {{"jsonrpc", "2.0"}, {"method", "wallet_getDerivedAddressesForPath"}, {"params", params}};

    auto result = Utils::statusGoCallPrivateRPC(inputJson.dump().c_str());
    const auto resultJson = json::parse(result);
    checkPrivateRpcCallResultAndReportError(resultJson);

    return resultJson.get<CallPrivateRpcResponse>().result;
}

SavedAddresses getSavedAddresses()
{
    json inputJson = {{"jsonrpc", "2.0"}, {"method", "wallet_getSavedAddresses"}};

    auto result = Utils::statusGoCallPrivateRPC(inputJson.dump().c_str());
    const auto resultJson = json::parse(result);
    checkPrivateRpcCallResultAndReportError(resultJson);

    const auto& data = resultJson.get<CallPrivateRpcResponse>().result;
    return data.is_null() ? json::array() : data;
}

void saveAddress(const SavedAddress& address)
{
    std::vector<json> params = {address};
    json inputJson = {{"jsonrpc", "2.0"}, {"method", "wakuext_upsertSavedAddress"}, {"params", params}};

    auto result = Utils::statusGoCallPrivateRPC(inputJson.dump().c_str());
    auto resultJson = json::parse(result);
    checkPrivateRpcCallResultAndReportError(resultJson);
}

NetworkConfigurations getEthereumChains(bool onlyEnabled)
{
    std::vector<json> params = {onlyEnabled};
    json inputJson = {{"jsonrpc", "2.0"}, {"method", "wallet_getEthereumChains"}, {"params", params}};

    auto result = Utils::statusGoCallPrivateRPC(inputJson.dump().c_str());
    const auto resultJson = json::parse(result);
    checkPrivateRpcCallResultAndReportError(resultJson);

    const auto& data = resultJson.get<CallPrivateRpcResponse>().result;
    return data.is_null() ? json::array() : data;
}

Tokens getTokens(const ChainID& chainId)
{
    std::vector<json> params = {chainId};
    json inputJson = {{"jsonrpc", "2.0"}, {"method", "wallet_getTokens"}, {"params", params}};

    auto result = Utils::statusGoCallPrivateRPC(inputJson.dump().c_str());
    const auto resultJson = json::parse(result);
    checkPrivateRpcCallResultAndReportError(resultJson);

    const auto& data = resultJson.get<CallPrivateRpcResponse>().result;
    return data.is_null() ? json::array() : data;
}

TokenBalances getTokensBalancesForChainIDs(const std::vector<ChainID>& chainIds,
                                           const std::vector<Accounts::EOAddress> accounts,
                                           const std::vector<Accounts::EOAddress> tokens)
{
    std::vector<json> params = {chainIds, accounts, tokens};
    json inputJson = {{"jsonrpc", "2.0"}, {"method", "wallet_getTokensBalancesForChainIDs"}, {"params", params}};

    auto result = Utils::statusGoCallPrivateRPC(inputJson.dump().c_str());
    const auto resultJson = json::parse(result);
    checkPrivateRpcCallResultAndReportError(resultJson);

    TokenBalances resultData;
    const auto& data = resultJson.get<CallPrivateRpcResponse>().result;
    // Workaround to exception "type must be array, but is object" for custom key-types
    // TODO: find out why
    std::map<std::string, std::map<std::string, BigInt>> dataMap = data.is_null() ? nlohmann::json() : data;
    for(const auto& keyIt : dataMap)
    {
        std::map<Accounts::EOAddress, BigInt> val;
        for(const auto& valIt : keyIt.second)
            val.emplace(QString::fromStdString(valIt.first), valIt.second);
        resultData.emplace(QString::fromStdString(keyIt.first), std::move(val));
    }
    return resultData;
}

} // namespace Status::StatusGo::Wallet
