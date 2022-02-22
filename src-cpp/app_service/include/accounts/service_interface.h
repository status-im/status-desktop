#pragma once

#include "../app_service.h"
#include "account.h"
#include "generated_account.h"
#include <QJsonValue>
#include <QString>
#include <QVector>

namespace Accounts
{

class ServiceInterface : public AppService
{
public:
    virtual QVector<AccountDto> openedAccounts() = 0;

    virtual QVector<GeneratedAccountDto> generatedAccounts() = 0;

    virtual bool setupAccount(const QString& accountId, const QString& password) = 0;

    virtual AccountDto getLoggedInAccount() = 0;

    virtual GeneratedAccountDto getImportedAccount() = 0;

    virtual bool isFirstTimeAccountLogin() = 0;

    virtual QString validateMnemonic(const QString& mnemonic) = 0;

    virtual bool importMnemonic(const QString& mnemonic) = 0;

    virtual QString login(const AccountDto& account, const QString& password) = 0;

    virtual void clear() = 0;

    virtual QString generateAlias(const QString& publicKey) = 0;

    virtual QString generateIdenticon(const QString& publicKey) = 0;

    virtual bool verifyAccountPassword(const QString& account, const QString& password) = 0;
};

} // namespace Accounts
