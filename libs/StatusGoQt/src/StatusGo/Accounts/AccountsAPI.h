#pragma once

#include "Types.h"

#include "Accounts/ChatOrWalletAccount.h"
#include "Accounts/accounts_types.h"

#include <vector>
#include <filesystem>

namespace Accounts = Status::StatusGo::Accounts;

namespace fs = std::filesystem;

namespace Status::StatusGo::Accounts
{

/// \brief Retrieve all available accounts Wallet and Chat
/// \note status-go returns accounts in \c CallPrivateRpcResponse.result
/// \throws \c CallPrivateRpcError
Accounts::ChatOrWalletAccounts getAccounts();

/// \brief Generate a new account
/// \note the underlying status-go api, SaveAccounts@accounts.go, returns `nil` for \c CallPrivateRpcResponse.result
/// \see \c getAccounts
/// \throws \c CallPrivateRpcError
void generateAccountWithDerivedPath(const HashedPassword &password, const QString &name,
                                    const QColor &color, const QString &emoji,
                                    const DerivationPath &path, const Accounts::EOAddress &derivedFrom);

/// \brief Add a new account from an existing mnemonic
/// \note the underlying status-go api, SaveAccounts@accounts.go, returns `nil` for \c CallPrivateRpcResponse.result
/// \see \c getAccounts
/// \throws \c CallPrivateRpcError
void addAccountWithMnemonicAndPath(const QString &mnemonic, const HashedPassword &password, const QString &name,
                                   const QColor &color, const QString &emoji, const DerivationPath &path);

/// \brief Add a watch only account
/// \note the underlying status-go api, SaveAccounts@accounts.go, returns `nil` for \c CallPrivateRpcResponse.result
/// \see \c getAccounts
/// \throws \c CallPrivateRpcError
void addAccountWatch(const EOAddress &address, const QString &name, const QColor &color, const QString &emoji);

/// \brief Delete an existing account
/// \note the underlying status-go api, DeleteAccount@accounts.go, returns `os.Remove(keyFile)`
/// \see \c getAccounts
/// \throws \c CallPrivateRpcError
void deleteAccount(const EOAddress &address);

/// \brief Delete an existing account
/// \note the underlying status-go api, DeleteAccount@accounts.go, returns `os.Remove(keyFile)`
/// \see \c getAccounts
/// \throws \c CallPrivateRpcError
void deleteMultiaccount(const QString &keyUID, const fs::path &keyStoreDir);

} // namespaces
