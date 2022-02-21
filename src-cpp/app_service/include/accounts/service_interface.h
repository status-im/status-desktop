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

    virtual bool setupAccount(QString accountId, QString password) = 0;

    virtual AccountDto getLoggedInAccount() = 0;

    virtual GeneratedAccountDto getImportedAccount() = 0;

    virtual bool isFirstTimeAccountLogin() = 0;

    virtual QString validateMnemonic(QString mnemonic) = 0;

    virtual bool importMnemonic(QString mnemonic) = 0;

    virtual QString login(AccountDto account, QString password) = 0;

    virtual void clear() = 0;

    virtual QString generateAlias(QString publicKey) = 0;

    virtual QString generateIdenticon(QString publicKey) = 0;

    virtual bool verifyAccountPassword(QString account, QString password) = 0;
};

} // namespace Accounts
