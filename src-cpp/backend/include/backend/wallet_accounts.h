#pragma once

#include <QJsonArray>

#include "backend/types.h"

namespace Backend::Wallet::Accounts
{
Backend::RpcResponse<QJsonArray> getAccounts();
Backend::RpcResponse<QString> generateNewAccount(const QString& password, const QString& accountName, const QString& color);
Backend::RpcResponse<QString> addAccountsFromPrivateKey(const QString& privateKey, const QString& password, const QString& accountName, const QString& color);
Backend::RpcResponse<QString> addAccountsFromSeed(const QString& seedPhrase, const QString& password, const QString& accountName, const QString& color);
Backend::RpcResponse<QString> addWatchOnlyAccount(const QString& address, const QString& accountName , const QString& color);
Backend::RpcResponse<QString> deleteAccount(const QString& address);
} // namespace Backend::Wallet::Accounts
