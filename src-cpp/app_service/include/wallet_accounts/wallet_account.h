#ifndef WALLETACCOUNTDTO_H
#define WALLETACCOUNTDTO_H

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

WalletAccountDto toWalletAccountDto(const QJsonValue jsonObj);

//WalletAccountDto getCurrencyBalance*(): float =
//    return self.tokens.map(t => t.currencyBalance).foldl(a + b, 0.0)

} // namespace Wallets

#endif // WALLETACCOUNTDTO_H
