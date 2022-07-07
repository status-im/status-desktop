#pragma once

#include "Types.h"

#include <QtCore>

namespace Status::StatusGo::Accounts
{
    RpcResponse<QJsonArray> generateAddresses(const QVector<QString>& paths);

    RpcResponse<QString> generateAlias(const QString& publicKey);

    RpcResponse<QJsonObject> storeDerivedAccounts(const QString& accountId, const QString& hashedPassword,
                                                  const QVector<QString>& paths);

    RpcResponse<QJsonObject> storeAccount(const QString& id, const QString& hashedPassword);

    bool saveAccountAndLogin(const QString& hashedPassword, const QJsonObject& account,
                                                 const QJsonArray& subaccounts, const QJsonObject& settings,
                                                 const QJsonObject& nodeConfig);

    /// opens database and returns accounts list.
    RpcResponse<QJsonArray> openAccounts(const char* dataDirPath);

    /// TODO harmonise password parameters (hashed or plain)?
    RpcResponse<QJsonObject> login(const QString& name, const QString& keyUid, const QString& hashedPassword,
                                   const QString& thumbnail, const QString& large);
    RpcResponse<QJsonObject> loginWithConfig(const QString& name, const QString& keyUid, const QString& hashedPassword,
                                             const QString& thumbnail, const QString& large, const QJsonObject& nodeConfig);
    RpcResponse<QJsonObject> logout();
}
