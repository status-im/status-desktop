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

    bool m_isFirstTimeAccountLogin = false;
    AccountDto m_loggedInAccount;
    GeneratedAccountDto m_importedAccount;

public:
    void init() override;

    QVector<AccountDto> openedAccounts() override;

    QVector<GeneratedAccountDto> generatedAccounts() override;

    bool setupAccount(const QString& accountId, const QString& password) override;

    AccountDto getLoggedInAccount() override;

    GeneratedAccountDto getImportedAccount() override;

    bool isFirstTimeAccountLogin() override;

    QString validateMnemonic(const QString& mnemonic) override;

    bool importMnemonic(const QString& mnemonic) override;

    QString login(const AccountDto& account, const QString& password) override;

    void clear() override;

    QString generateAlias(const QString& publicKey) override;

    QString generateIdenticon(const QString& publicKey) override;

    bool verifyAccountPassword(const QString& account, const QString& password) override;

    DerivedAccounts
    storeDerivedAccounts(const QString& accountId, const QString& hashedPassword, const QVector<QString>& paths);

    QJsonObject getAccountDataForAccountId(const QString& accountId);

    QJsonArray getSubaccountDataForAccountId(const QString& accountId);

    QJsonObject getAccountSettings(const QString& accountId, const QString& installationId);

    AccountDto saveAccountAndLogin(const QString& hashedPassword,
                                   const QJsonObject& account,
                                   const QJsonArray& subaccounts,
                                   const QJsonObject& settings,
                                   const QJsonObject& config);
};

} // namespace Accounts
