#pragma once

#include "wallet_token.h"

#include <QJsonValue>
#include <QString>
#include <QVector>

namespace Wallets
{
class WalletAccountDto
{
public:
    QString name;
    QString address;
    QString path;
    QString color;
    QString publicKey;
    QString walletType;
    bool isWallet;
    bool isChat;
    QVector<WalletTokenDto> tokens;
};

WalletAccountDto toWalletAccountDto(const QJsonValue& jsonObj);

} // namespace Wallets
