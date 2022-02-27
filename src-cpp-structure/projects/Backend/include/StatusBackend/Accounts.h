#pragma once

#include "Types.h"

#include <QtCore>

namespace Backend::Accounts
{
    RpcResponse<QJsonArray> generateAddresses(const QVector<QString>& paths);

    RpcResponse<QString> generateIdenticon(const QString& publicKey);

    RpcResponse<QString> generateAlias(const QString& publicKey);

    RpcResponse<QJsonObject> storeDerivedAccounts(const QString& accountId, const QString& hashedPassword,
                                                  const QVector<QString>& paths);

    RpcResponse<QJsonObject> saveAccountAndLogin(const QString& hashedPassword, const QJsonObject& account,
                                                 const QJsonArray& subaccounts, const QJsonObject& settings,
                                                 const QJsonObject& nodeConfig);

    RpcResponse<QJsonArray> openAccounts(const QString& path);

    RpcResponse<QJsonObject> login(const QString& name, const QString& keyUid, const QString& hashedPassword,
                                   const QString& identicon, const QString& thumbnail, const QString& large);
}
