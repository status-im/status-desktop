#pragma once

#include "ServiceInterface.h"

namespace Status::Accounts
{

    class Service : public ServiceInterface
    {
    public:
        Service();

        void init(const QString& statusgoDataDir) override;

        [[nodiscard]] QVector<AccountDto> openedAccounts() override;

        [[nodiscard]] const QVector<GeneratedAccountDto>& generatedAccounts() const override;

        bool setupAccount(const QString& accountId, const QString& password) override;

        [[nodiscard]] const AccountDto& getLoggedInAccount() const override;

        [[nodiscard]] const GeneratedAccountDto& getImportedAccount() const override;

        [[nodiscard]] bool isFirstTimeAccountLogin() const override;

        QString validateMnemonic(const QString& mnemonic) override;

        bool importMnemonic(const QString& mnemonic) override;

        QString login(AccountDto account, const QString& password) override;

        void clear() override;

        QString generateAlias(const QString& publicKey) override;

        QString generateIdenticon(const QString& publicKey) override;

        bool verifyAccountPassword(const QString& account, const QString& password) override;

    private:
        QJsonObject prepareAccountJsonObject(const GeneratedAccountDto& account) const;

        DerivedAccounts storeDerivedAccounts(const QString& accountId, const QString& hashedPassword,
                                             const QVector<QString>& paths);

        AccountDto saveAccountAndLogin(const QString& hashedPassword, const QJsonObject& account,
                                       const QJsonArray& subaccounts, const QJsonObject& settings,
                                       const QJsonObject& config);

        QJsonObject getAccountDataForAccountId(const QString& accountId) const;

        QJsonArray prepareSubaccountJsonObject(const GeneratedAccountDto& account) const;

        QJsonArray getSubaccountDataForAccountId(const QString& accountId) const;

        QString generateSigningPhrase(const int count) const;

        QJsonObject prepareAccountSettingsJsonObject(const GeneratedAccountDto& account,
                                                     const QString& installationId) const;

        QJsonObject getAccountSettings(const QString& accountId, const QString& installationId) const;

        QJsonObject getDefaultNodeConfig(const QString& installationId) const;

    private:
        QVector<GeneratedAccountDto> m_generatedAccounts;

        QString m_statusgoDataDir;
        bool m_isFirstTimeAccountLogin;
        AccountDto m_loggedInAccount;
        GeneratedAccountDto m_importedAccount;
    };
}
