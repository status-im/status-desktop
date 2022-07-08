#pragma once

#include "Common/Constants.h"
#include "Common/SigningPhrases.h"
#include "Common/Json.h"

#include <QtCore>

namespace Status::Onboarding
{

struct DerivedAccountDetails
{
    QString publicKey;
    QString address;
    QString derivationPath;

    static DerivedAccountDetails toDerivedAccountDetails(const QJsonObject& jsonObj, const QString& derivationPath)
    {
        // Mapping this DTO is not strightforward since only keys are used for id. We
        // handle it a bit different.
        auto result = DerivedAccountDetails();

        try
        {
            result.derivationPath = derivationPath;
            result.publicKey = Json::getMandatoryProp(jsonObj, "publicKey")->toString();
            result.address = Json::getMandatoryProp(jsonObj, "address")->toString();
        }
        catch (std::exception e)
        {
            qWarning() << QString("Mapping DerivedAccountDetails failed: %1").arg(e.what());
        }

        return result;
    }
};

struct DerivedAccounts
{
    DerivedAccountDetails whisper;
    DerivedAccountDetails walletRoot;
    DerivedAccountDetails defaultWallet;
    DerivedAccountDetails eip1581;

    static DerivedAccounts toDerivedAccounts(const QJsonObject& jsonObj)
    {
        auto result = DerivedAccounts();

        for(const auto &derivationPath : jsonObj.keys())
        {
            auto derivedObj = jsonObj.value(derivationPath).toObject();
            if(derivationPath == Constants::General::PathWhisper)
            {
                result.whisper = DerivedAccountDetails::toDerivedAccountDetails(derivedObj, derivationPath);
            }
            else if(derivationPath == Constants::General::PathWalletRoot)
            {
                result.walletRoot = DerivedAccountDetails::toDerivedAccountDetails(derivedObj, derivationPath);
            }
            else if(derivationPath == Constants::General::PathDefaultWallet)
            {
                result.defaultWallet = DerivedAccountDetails::toDerivedAccountDetails(derivedObj, derivationPath);
            }
            else if(derivationPath == Constants::General::PathEIP1581)
            {
                result.eip1581 = DerivedAccountDetails::toDerivedAccountDetails(derivedObj, derivationPath);
            }
        }

        return result;
    }
};

struct StoredAccountDto
{
    QString publicKey;
    QString address;

};

static StoredAccountDto toStoredAccountDto(const QJsonObject& jsonObj)
{
    auto result = StoredAccountDto();

    try {
        result.address = Json::getMandatoryProp(jsonObj, "address")->toString();
        result.publicKey = Json::getMandatoryProp(jsonObj, "publicKey")->toString();
    } catch (std::exception e) {
        qWarning() << QString("Mapping StoredAccountDto failed: %1").arg(e.what());
    }

    return result;
}

struct GeneratedAccountDto
{
    QString id;
    QString publicKey;
    QString address;
    QString keyUid;
    QString mnemonic;
    DerivedAccounts derivedAccounts;

    // The following two are set additionally.
    QString alias;
    QString identicon;

    bool isValid() const
    {
        return !(id.isEmpty() || publicKey.isEmpty() || address.isEmpty() || keyUid.isEmpty());
    }

    static GeneratedAccountDto toGeneratedAccountDto(const QJsonObject& jsonObj)
    {
        auto result = GeneratedAccountDto();

        try
        {
            result.id = Json::getMandatoryProp(jsonObj, "id")->toString();
            result.address = Json::getMandatoryProp(jsonObj, "address")->toString();
            result.keyUid = Json::getMandatoryProp(jsonObj, "keyUid")->toString();
            result.mnemonic = Json::getMandatoryProp(jsonObj, "mnemonic")->toString();
            result.publicKey = Json::getMandatoryProp(jsonObj, "publicKey")->toString();

            auto derivedObj = Json::getProp(jsonObj, "derived")->toObject();
            if(!derivedObj.isEmpty())
            {
                result.derivedAccounts = DerivedAccounts::toDerivedAccounts(derivedObj);
            }
        }
        catch (std::exception e)
        {
            qWarning() << QString("Mapping GeneratedAccountDto failed: %1").arg(e.what());
        }

        return result;
    }
};

}
