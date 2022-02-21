#include <QDebug>
#include <QJsonDocument>
#include <QJsonObject>

#include "backend/types.h"
#include "backend/utils.h"
#include "backend/wallet_accounts.h"
#include "libstatus.h"

namespace Backend::Wallet::Accounts
{
RpcResponse<QJsonArray> getAccounts()
{
    QJsonObject inputJSON{{"jsonrpc", "2.0"}, {"method", "accounts_getAccounts"}, {"params", QJsonValue()}};
    auto result = CallPrivateRPC(Utils::jsonToStr(inputJSON).toUtf8().data());
    auto obj = QJsonDocument::fromJson(result).object();
    Backend::Utils::throwOnError(obj);
    return RpcResponse<QJsonArray>(result, obj["result"].toArray(), RpcError(-1, QJsonDocument::fromJson(result)["error"].toString()));
}

RpcResponse<QString> generateNewAccount(const QString& password, const QString& accountName, const QString& color)
{
    QString hashedPassword(Backend::Utils::hashString(password));
    QJsonArray payload = {hashedPassword, accountName, color};
    QJsonObject inputJSON{{"jsonrpc", "2.0"}, {"method", "accounts_generateAccount"}, {"params", payload}};
    auto result = CallPrivateRPC(Utils::jsonToStr(inputJSON).toUtf8().data());
    auto response = QJsonDocument::fromJson(result);
    return  RpcResponse<QString>(result,response["result"].toString(),
            RpcError(response["error"]["code"].toDouble(), response["error"]["message"].toString()));
}

RpcResponse<QString> addAccountsFromPrivateKey(const QString& privateKey, const QString& password, const QString& accountName, const QString& color)
{
    QString hashedPassword(Backend::Utils::hashString(password));
    QJsonArray payload = {privateKey, hashedPassword, accountName, color};
    QJsonObject inputJSON{{"jsonrpc", "2.0"}, {"method", "accounts_addAccountWithMnemonic"}, {"params", payload}};
    auto result = CallPrivateRPC(Utils::jsonToStr(inputJSON).toUtf8().data());
    auto response = QJsonDocument::fromJson(result);
    return  RpcResponse<QString>(result,response["result"].toString(),
            RpcError(response["error"]["code"].toDouble(), response["error"]["message"].toString()));
}

RpcResponse<QString> addAccountsFromSeed(const QString& seedPhrase, const QString& password, const QString& accountName, const QString& color)
{
    QString hashedPassword(Backend::Utils::hashString(password));
    QJsonArray payload = {seedPhrase, hashedPassword, accountName, color};
    QJsonObject inputJSON{{"jsonrpc", "2.0"}, {"method", "accounts_addAccountWithPrivateKey"}, {"params", payload}};
    auto result = CallPrivateRPC(Utils::jsonToStr(inputJSON).toUtf8().data());
    auto response = QJsonDocument::fromJson(result);
    return  RpcResponse<QString>(result,response["result"].toString(),
            RpcError(response["error"]["code"].toDouble(), response["error"]["message"].toString()));
}

RpcResponse<QString> addWatchOnlyAccount(const QString& address, const QString& accountName , const QString& color)
{
    QJsonArray payload = {address, accountName, color};
    QJsonObject inputJSON{{"jsonrpc", "2.0"}, {"method", "accounts_addAccountWatch"}, {"params", payload}};
    auto result = CallPrivateRPC(Utils::jsonToStr(inputJSON).toUtf8().data());
    auto response = QJsonDocument::fromJson(result);
    return  RpcResponse<QString>(result,response["result"].toString(),
            RpcError(response["error"]["code"].toDouble(), response["error"]["message"].toString()));
}

RpcResponse<QString> deleteAccount(const QString& address)
{
    QJsonArray payload = {address};
    QJsonObject inputJSON{{"jsonrpc", "2.0"}, {"method", "accounts_deleteAccount"}, {"params", payload}};
    auto result = CallPrivateRPC(Utils::jsonToStr(inputJSON).toUtf8().data());
    auto response = QJsonDocument::fromJson(result);
    return  RpcResponse<QString>(result,response["result"].toString(),
            RpcError(response["error"]["code"].toDouble(), response["error"]["message"].toString()));
}

} // namespace Backend::Wallet::Accounts
