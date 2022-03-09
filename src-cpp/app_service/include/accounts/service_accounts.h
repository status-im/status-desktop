#pragma once

#include "account.h"
#include "generated_account.h"
#include "service_interface.h"
#include <QString>
#include <QVector>

namespace Accounts
{

class Service : public ServiceInterface
{
private:
    QVector<GeneratedAccountDto> m_generatedAccounts;

    bool m_isFirstTimeAccountLogin;
    AccountDto m_loggedInAccount;
    GeneratedAccountDto m_importedAccount;

public:
    Service();
    ~Service();

    void init() override;

    virtual QVector<AccountDto> openedAccounts() override;

    QVector<GeneratedAccountDto> generatedAccounts() override;

    bool setupAccount(QString accountId, QString password) override;

    AccountDto getLoggedInAccount() override;

    GeneratedAccountDto getImportedAccount() override;

    bool isFirstTimeAccountLogin() override;

    QString validateMnemonic(QString mnemonic) override;

    bool importMnemonic(QString mnemonic) override;

    QString login(AccountDto account, QString password) override;

    void clear() override;

    QString generateAlias(QString publicKey) override;

    QString generateIdenticon(QString publicKey) override;

    bool verifyAccountPassword(QString account, QString password) override;

    DerivedAccounts storeDerivedAccounts(QString accountId, QString hashedPassword, QVector<QString> paths);

    QJsonObject getAccountDataForAccountId(QString accountId);

    QJsonArray getSubaccountDataForAccountId(QString accountId);

    QJsonObject getAccountSettings(QString accountId, QString installationId);

    QJsonObject getDefaultNodeConfig(QString installationId);

    QJsonObject prepareAccountJsonObject(const GeneratedAccountDto account);

    QJsonArray prepareSubaccountJsonObject(GeneratedAccountDto account);

    QJsonObject prepareAccountSettingsJsonObject(const GeneratedAccountDto account, QString installationId);

    AccountDto saveAccountAndLogin(
        QString hashedPassword, QJsonObject account, QJsonArray subaccounts, QJsonObject settings, QJsonObject config);
};

} // namespace Accounts
