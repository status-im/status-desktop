#pragma once

#include "Types.h"
#include "accounts_types.h"

#include <QtCore>

namespace Status::StatusGo::Accounts
{
    RpcResponse<QJsonArray> generateAddresses(const std::vector<Accounts::DerivationPath> &paths);

    RpcResponse<QString> generateAlias(const QString& publicKey);

    RpcResponse<QJsonObject> storeDerivedAccounts(const QString& accountId, const HashedPassword& password,
                                                  const std::vector<Accounts::DerivationPath>& paths);

    RpcResponse<QJsonObject> storeAccount(const QString& id, const HashedPassword& password);

    bool saveAccountAndLogin(const StatusGo::HashedPassword& password, const QJsonObject& account,
                             const QJsonArray& subaccounts, const QJsonObject& settings,
                             const QJsonObject& nodeConfig);

    /// opens database and returns accounts list.
    RpcResponse<QJsonArray> openAccounts(const char* dataDirPath);

    RpcResponse<QJsonObject> login(const QString& name, const QString& keyUid, const HashedPassword& password,
                                   const QString& thumbnail, const QString& large);
    RpcResponse<QJsonObject> loginWithConfig(const QString& name, const QString& keyUid, const HashedPassword& password,
                                             const QString& thumbnail, const QString& large, const QJsonObject& nodeConfig);
    RpcResponse<QJsonObject> logout();
}
