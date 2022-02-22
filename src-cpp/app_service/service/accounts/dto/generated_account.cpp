#include "accounts/generated_account.h"
#include "backend/accounts.h"

#include <QDebug>
#include <QJsonArray>
#include <QJsonObject>
#include <QJsonValue>
#include <QStringList>

bool Accounts::GeneratedAccountDto::isValid() const
{
    return id.length() > 0 && publicKey.length() > 0 && address.length() > 0 && keyUid.length() > 0;
}

Accounts::DerivedAccountDetails Accounts::toDerivedAccountDetails(const QJsonValue& jsonObj,
                                                                  const QString& derivationPath)
{
    // Mapping this DTO is not strightforward since only keys are used for id. We
    // handle it a bit different.
    auto result = Accounts::DerivedAccountDetails();

    result.derivationPath = derivationPath;
    result.publicKey = jsonObj["publicKey"].toString();
    result.address = jsonObj["address"].toString();

    return result;
}

Accounts::DerivedAccounts Accounts::toDerivedAccounts(const QJsonObject& jsonObj)
{
    auto result = Accounts::DerivedAccounts();
    foreach(const QString& derivationPath, jsonObj.keys())
    {
        QJsonValue derivedObj = jsonObj.value(derivationPath);
        if(derivationPath == Backend::Accounts::PathWhisper)
        {
            result.whisper = Accounts::toDerivedAccountDetails(derivedObj, derivationPath);
        }
        else if(derivationPath == Backend::Accounts::PathWalletRoot)
        {
            result.walletRoot = Accounts::toDerivedAccountDetails(derivedObj, derivationPath);
        }
        else if(derivationPath == Backend::Accounts::PathDefaultWallet)
        {
            result.defaultWallet = Accounts::toDerivedAccountDetails(derivedObj, derivationPath);
        }
        else if(derivationPath == Backend::Accounts::PathEIP1581)
        {
            result.eip1581 = Accounts::toDerivedAccountDetails(derivedObj, derivationPath);
        }
    }

    return result;
}

Accounts::GeneratedAccountDto Accounts::toGeneratedAccountDto(const QJsonValue& jsonObj)
{
    auto result = GeneratedAccountDto();

    result.id = jsonObj["id"].toString();
    result.address = jsonObj["address"].toString();
    result.keyUid = jsonObj["keyUid"].toString();
    result.mnemonic = jsonObj["mnemonic"].toString();
    result.publicKey = jsonObj["publicKey"].toString();
    if(!jsonObj["derived"].isUndefined())
    {
        result.derivedAccounts = Accounts::toDerivedAccounts(jsonObj["derived"].toObject());
    }

    return result;
}
