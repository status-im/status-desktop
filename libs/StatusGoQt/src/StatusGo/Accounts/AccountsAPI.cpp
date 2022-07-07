#include "AccountsAPI.h"

#include "Utils.h"
#include "Metadata/api_response.h"

#include <libstatus.h>

#include <nlohmann/json.hpp>

#include <iostream>

using json = nlohmann::json;

namespace Status::StatusGo::Accounts
{

Accounts::MultiAccounts getAccounts() {
    // or even nicer with a raw string literal
    json inputJson = {
        {"jsonrpc", "2.0"},
        {"method", "accounts_getAccounts"},
        {"params", json::array()}
    };

    auto result = Utils::statusGoCallPrivateRPC(inputJson.dump().c_str());
    auto resultJson = json::parse(result);
    checkPrivateRpcCallResultAndReportError(resultJson);

    return resultJson.get<CallPrivateRpcResponse>().result;
}

void generateAccountWithDerivedPath(const QString &hashedPassword, const QString &name, const QColor &color, const QString &emoji,
                                    const QString &path, const QString &derivedFrom)
{
    std::vector<json> params = {hashedPassword, name, color, emoji, path, derivedFrom};
    json inputJson = {
        {"jsonrpc", "2.0"},
        {"method", "accounts_generateAccountWithDerivedPath"},
        {"params", params}
    };

    auto result = Utils::statusGoCallPrivateRPC(inputJson.dump().c_str());
    auto resultJson = json::parse(result);
    checkPrivateRpcCallResultAndReportError(resultJson);
}

void addAccountWithMnemonicAndPath(const QString &mnemonic, const QString &hashedPassword, const QString &name,
                                   const QColor &color, const QString &emoji, const QString &path)
{
    std::vector<json> params = {mnemonic, hashedPassword, name, color, emoji, path};
    json inputJson = {
        {"jsonrpc", "2.0"},
        {"method", "accounts_addAccountWithMnemonicAndPath"},
        {"params", params}
    };

    auto result = Utils::statusGoCallPrivateRPC(inputJson.dump().c_str());
    auto resultJson = json::parse(result);
    checkPrivateRpcCallResultAndReportError(resultJson);
}

void addAccountWatch(const QString &address, const QString &name, const QColor &color, const QString &emoji)
{
    std::vector<json> params = {address, name, color, emoji};
    json inputJson = {
        {"jsonrpc", "2.0"},
        {"method", "accounts_addAccountWatch"},
        {"params", params}
    };

    auto result = Utils::statusGoCallPrivateRPC(inputJson.dump().c_str());
    auto resultJson = json::parse(result);
    checkPrivateRpcCallResultAndReportError(resultJson);
}

void deleteAccount(const QString &address)
{
    std::vector<json> params = {address};
    json inputJson = {
        {"jsonrpc", "2.0"},
        {"method", "accounts_deleteAccount"},
        {"params", params}
    };

    auto result = Utils::statusGoCallPrivateRPC(inputJson.dump().c_str());
    auto resultJson = json::parse(result);
    checkPrivateRpcCallResultAndReportError(resultJson);
}

void deleteMultiaccount(const QString &keyUID, const fs::path &keyStoreDir)
{
    // We know go bridge won't misbehave with the input arguments
    auto result = DeleteMultiaccount(const_cast<char*>(keyUID.toStdString().c_str()), const_cast<char*>(keyStoreDir.string().c_str()));
    auto resultJson = json::parse(result);
    checkApiError(resultJson);
}

}
