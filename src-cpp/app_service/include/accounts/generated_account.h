#pragma once

#include <QJsonDocument>
#include <QString>

namespace Accounts
{
class DerivedAccountDetails
{
public:
    QString publicKey;
    QString address;
    QString derivationPath;
};

class DerivedAccounts
{
public:
    DerivedAccountDetails whisper;
    DerivedAccountDetails walletRoot;
    DerivedAccountDetails defaultWallet;
    DerivedAccountDetails eip1581;
};

class GeneratedAccountDto
{
public:
    QString id;
    QString publicKey;
    QString address;
    QString keyUid;
    QString mnemonic;
    DerivedAccounts derivedAccounts;

    // The following two are set additionally.
    QString alias;
    QString identicon;

    bool isValid() const;
};

DerivedAccountDetails toDerivedAccountDetails(const QJsonValue& jsonObj, const QString& derivationPath);

DerivedAccounts toDerivedAccounts(const QJsonObject& jsonObj);

GeneratedAccountDto toGeneratedAccountDto(const QJsonValue& jsonObj);
} // namespace Accounts
