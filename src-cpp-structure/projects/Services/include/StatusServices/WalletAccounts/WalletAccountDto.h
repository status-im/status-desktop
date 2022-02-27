#pragma once

#include <StatusServices/CommonService>

#include <QtCore>

namespace Status::WalletAccount
{
    struct WalletToken
    {
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

    struct WalletAccountDto
    {
        QString name;
        QString address;
        QString path;
        QString color;
        QString publicKey;
        QString walletType;
        bool isWallet;
        bool isChat;
        QVector<WalletToken> tokens; // this is not set by mapping remote DTO, but built on the app side (set later)

        static WalletAccountDto toWalletAccountDto(const QJsonObject& jsonObj)
        {
            auto result = WalletAccountDto();

            try
            {
                result.name = Json::getMandatoryProp(jsonObj, "name")->toString();
                result.address = Json::getMandatoryProp(jsonObj, "address")->toString();
                result.path = Json::getMandatoryProp(jsonObj, "path")->toString();
                result.color = Json::getMandatoryProp(jsonObj, "color")->toString();
                result.publicKey = Json::getMandatoryProp(jsonObj, "public-key")->toString();
                result.walletType = Json::getMandatoryProp(jsonObj, "type")->toString();
                result.isWallet = Json::getMandatoryProp(jsonObj, "wallet")->toBool();
                result.isChat = Json::getMandatoryProp(jsonObj, "chat")->toBool();
            }
            catch (std::exception e)
            {
                qWarning() << QObject::tr("Mapping WalletAccountDto failed: %1").arg(e.what());
            }

            return result;
        }
    };
}
