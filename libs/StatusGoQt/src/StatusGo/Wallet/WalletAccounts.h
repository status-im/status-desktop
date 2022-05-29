#pragma once

#include "Types.h"

#include <QtCore>

namespace Status::StatusGo::Wallet
{
    RpcResponse<QJsonArray> getAccounts();

    RpcResponse<QJsonObject> generateNewAccount(const QString& password, const QString& accountName,
                                                const QString& color);

    RpcResponse<QJsonObject> addAccountsFromPrivateKey(const QString& privateKey, const QString& password,
                                                   const QString& accountName, const QString& color);

    RpcResponse<QJsonObject> addAccountsFromSeed(const QString& seedPhrase, const QString& password,
                                             const QString& accountName, const QString& color);

    RpcResponse<QJsonObject> addWatchOnlyAccount(const QString& address, const QString& accountName,
                                                 const QString& color);

    RpcResponse<QJsonObject> deleteAccount(const QString& address);
}
