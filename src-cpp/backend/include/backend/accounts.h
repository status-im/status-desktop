#pragma once

#include "backend/types.h"
#include <QJsonArray>
#include <QString>
#include <QVector>

namespace Backend
{
namespace Accounts
{
const QString ZERO_ADDRESS = "0x0000000000000000000000000000000000000000";

const QString PATH_WALLET_ROOT = "m/44'/60'/0'/0";
// EIP1581 Root Key, the extended key from which any whisper key/encryption key can be derived
const QString PATH_EIP_1581 = "m/43'/60'/1581'";
// BIP44-0 Wallet key, the default wallet key
const QString PATH_DEFAULT_WALLET = PATH_WALLET_ROOT + "/0";
// EIP1581 Chat Key 0, the default whisper key
const QString PATH_WHISPER = PATH_EIP_1581 + "/0'/0";

RpcResponse<QJsonArray> generateAddresses(QVector<QString> paths);

RpcResponse<QString> generateIdenticon(QString publicKey);

RpcResponse<QString> generateAlias(QString publicKey);

RpcResponse<QJsonObject> storeDerivedAccounts(QString accountId, QString hashedPassword, QVector<QString> paths);

RpcResponse<QJsonObject> saveAccountAndLogin(
    QString hashedPassword, QJsonObject account, QJsonArray subaccounts, QJsonObject settings, QJsonObject nodeConfig);

RpcResponse<QJsonArray> openAccounts(QString path);

RpcResponse<QJsonObject>
login(QString name, QString keyUid, QString hashedPassword, QString identicon, QString thumbnail, QString large);

} // namespace Accounts
} // namespace Backend
