#pragma once

#include "AccountDto.h"
#include "GeneratedAccountDto.h"

#include <filesystem>

namespace fs = std::filesystem;

namespace Status::Onboarding
{

class AccountsServiceInterface
{
public:

    virtual ~AccountsServiceInterface() = default;

    /// Generates and cache addresses accessible by \c generatedAccounts
    virtual bool init(const fs::path& statusgoDataDir) = 0;

    /// opens database and returns accounts list.
    [[nodiscard]] virtual std::vector<AccountDto> openAndListAccounts() = 0;

    /// Retrieve cached accounts generated in \c init
    [[nodiscard]] virtual const std::vector<GeneratedAccountDto>& generatedAccounts() const = 0;

    /// Configure an generated account. \a accountID must be sourced from \c generatedAccounts
    virtual bool setupAccountAndLogin(const QString& accountID, const QString& password, const QString& displayName) = 0;

    /// Account that is currently logged-in
    [[nodiscard]] virtual const AccountDto& getLoggedInAccount() const = 0;

    [[nodiscard]] virtual const GeneratedAccountDto& getImportedAccount() const = 0;

    /// Check if the login was never done in the current \c data directory
    [[nodiscard]] virtual bool isFirstTimeAccountLogin() const = 0;

    /// Set and initializes the keystore directory. \see StatusGo::General::initKeystore
    virtual bool setKeyStoreDir(const QString &key) = 0;

    virtual QString login(AccountDto account, const QString& password) = 0;

    virtual void clear() = 0;

    virtual QString generateAlias(const QString& publicKey) = 0;

    virtual QString generateIdenticon(const QString& publicKey) = 0;
};

}
