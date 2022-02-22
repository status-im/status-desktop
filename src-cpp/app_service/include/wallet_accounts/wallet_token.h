#pragma once

#include <QJsonValue>
#include <QString>
#include <QVector>

namespace Wallets
{
class WalletTokenDto
{
public:
    QString name;
    QString address;
    QString symbol;
    int decimals;
    bool hasIcon;
    QString color;
    bool isCustom;
    float balance;
    float currencyBalance;
};

} // namespace Wallets
