#pragma once

#include <StatusGo/Types.h>

#include "AccountsServiceInterface.h"

namespace Status::Onboarding
{

/*!
 * \brief The Service class
 *
 * \todo Refactor static dependencies
 *      :/resources/default-networks.json
 *      :/resources/node-config.json
 *      :/resources/fleets.json
 *      :/resources/infura_key
 * \todo AccountsService
 * \todo Consider removing unneded states (first time account login, user)
 */
class AccountsService : public AccountsServiceInterface
{
public:
    AccountsService();

    /// \see ServiceInterface
    bool init(const fs::path& statusgoDataDir) override;

    /// \see ServiceInterface
    [[nodiscard]] std::vector<MultiAccount> openAndListAccounts() override;

    /// \see ServiceInterface
    [[nodiscard]] const std::vector<GeneratedMultiAccount>& generatedAccounts() const override;

    /// \see ServiceInterface
    bool setupAccountAndLogin(const QString& accountId, const QString& password, const QString& displayName) override;

    /// \see ServiceInterface
    [[nodiscard]] const MultiAccount& getLoggedInAccount() const override;

    [[nodiscard]] const GeneratedMultiAccount& getImportedAccount() const override;

    /// \see ServiceInterface
    [[nodiscard]] bool isFirstTimeAccountLogin() const override;

    /// \see ServiceInterface
    bool setKeyStoreDir(const QString &key) override;

    QString login(MultiAccount account, const QString& password) override;

    void clear() override;

    QString generateAlias(const QString& publicKey) override;

    void deleteMultiAccount(const MultiAccount &account) override;

private:
    QJsonObject prepareAccountJsonObject(const GeneratedMultiAccount& account, const QString& displayName) const;

    DerivedAccounts storeDerivedAccounts(const QString& accountId, const StatusGo::HashedPassword& password,
                                         const std::vector<Accounts::DerivationPath>& paths);
    StoredMultiAccount storeAccount(const QString& accountId, const StatusGo::HashedPassword& password);

    MultiAccount saveAccountAndLogin(const StatusGo::HashedPassword& password, const QJsonObject& account,
                                   const QJsonArray& subaccounts, const QJsonObject& settings,
                                   const QJsonObject& config);

    QJsonObject getAccountDataForAccountId(const QString& accountId, const QString& displayName) const;

    QJsonArray prepareSubaccountJsonObject(const GeneratedMultiAccount& account, const QString& displayName) const;

    QJsonArray getSubaccountDataForAccountId(const QString& accountId, const QString& displayName) const;

    QString generateSigningPhrase(int count) const;

    QJsonObject prepareAccountSettingsJsonObject(const GeneratedMultiAccount& account,
                                                 const QString& installationId,
                                                 const QString& displayName) const;

    QJsonObject getAccountSettings(const QString& accountId, const QString& installationId, const QString& displayName) const;

    QJsonObject getDefaultNodeConfig(const QString& installationId) const;

private:
    std::vector<GeneratedMultiAccount> m_generatedAccounts;

    fs::path m_statusgoDataDir;
    fs::path m_keyStoreDir;
    bool m_isFirstTimeAccountLogin;
    // TODO: don't see the need for this state here
    MultiAccount m_loggedInAccount;
    GeneratedMultiAccount m_importedAccount;

    // Here for now. Extract them if used by other services
    static constexpr auto m_keyStoreDirName = "keystore";
};

}
