#include "WalletAccounts.h"

#include "Utils.h"

namespace Status::StatusGo::Wallet
{

RpcResponse<QJsonArray> getAccounts()
{
    QJsonObject payload{
        {"jsonrpc", "2.0"},
        {"method", "accounts_getAccounts"},
        {"params", QJsonValue()}
    };

    return Utils::callPrivateRpc<QJsonArray>(Utils::jsonToByteArray(std::move(payload)));
}

RpcResponse<QJsonObject> generateNewAccount(const QString& password, const QString& accountName, const QString& color)
{
    QString hashedPassword(Utils::hashString(password));
    QJsonArray params = {
        hashedPassword,
        accountName,
        color
    };

    QJsonObject payload{
        {"jsonrpc", "2.0"},
        {"method", "accounts_generateAccount"},
        {"params", params}
    };

    return Utils::callPrivateRpc<QJsonObject>(Utils::jsonToByteArray(std::move(payload)));
}

RpcResponse<QJsonObject> addAccountsFromPrivateKey(const QString& privateKey, const QString& password,
                                                   const QString& accountName, const QString& color)
{
    QString hashedPassword(Utils::hashString(password));
    QJsonArray params = {
        privateKey,
        hashedPassword,
        accountName,
        color
    };

    QJsonObject payload{
        {"jsonrpc", "2.0"},
        {"method", "accounts_addAccountWithMnemonic"},
        {"params", params}
    };

    return Utils::callPrivateRpc<QJsonObject>(Utils::jsonToByteArray(std::move(payload)));
}

RpcResponse<QJsonObject> addAccountsFromSeed(const QString& seedPhrase, const QString& password, const QString& accountName, const QString& color)
{
    QString hashedPassword(Utils::hashString(password));

    QJsonArray params = {
        seedPhrase,
        hashedPassword,
        accountName,
        color
    };

    QJsonObject payload {
        {"jsonrpc", "2.0"},
        {"method", "accounts_addAccountWithPrivateKey"},
        {"params", params}
    };

    return Utils::callPrivateRpc<QJsonObject>(Utils::jsonToByteArray(std::move(payload)));
}

RpcResponse<QJsonObject> addWatchOnlyAccount(const QString& address, const QString& accountName , const QString& color)
{
    QJsonArray params = {
        address,
        accountName,
        color
    };

    QJsonObject payload {
        {"jsonrpc", "2.0"},
        {"method", "accounts_addAccountWatch"},
        {"params", params}
    };

    return Utils::callPrivateRpc<QJsonObject>(Utils::jsonToByteArray(std::move(payload)));
}

RpcResponse<QJsonObject> deleteAccount(const QString& address)
{
    QJsonArray params = {
        address
    };

    QJsonObject payload {
        {"jsonrpc", "2.0"},
        {"method", "accounts_deleteAccount"},
        {"params", params}
    };

    return Utils::callPrivateRpc<QJsonObject>(Utils::jsonToByteArray(std::move(payload)));
}

}