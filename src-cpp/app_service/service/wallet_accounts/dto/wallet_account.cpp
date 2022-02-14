#include "wallet_accounts/wallet_account.h"
//#include "backend/accounts.h"
#include <QJsonArray>
#include <QJsonObject>
#include <QJsonValue>
#include <QStringList>

Wallets::WalletAccountDto Wallets::toWalletAccountDto(const QJsonValue jsonObj)
{
    auto result = Wallets::WalletAccountDto();
    result.name = jsonObj["name"].toString();
    result.address = jsonObj["address"].toString();
    result.path = jsonObj["path"].toString();
    result.color = jsonObj["color"].toString();
    result.isWallet = jsonObj["wallet"].toBool();
    result.isChat = jsonObj["chat"].toBool();
    result.publicKey = jsonObj["public-key"].toString();
    result.walletType = jsonObj["type"].toString();
    return result;
}
