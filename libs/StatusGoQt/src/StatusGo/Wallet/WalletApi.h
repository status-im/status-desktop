#pragma once

#include "Accounts/ChatOrWalletAccount.h"
#include "Accounts/accounts_types.h"
#include "DerivedAddress.h"
#include "Types.h"

#include <vector>

namespace Accounts = Status::StatusGo::Accounts;

namespace Status::StatusGo::Wallet
{
/// \brief Retrieve a list of derived account addresses
/// \see \c generateAccountWithDerivedPath
/// \throws \c CallPrivateRpcError
DerivedAddresses getDerivedAddressesForPath(const HashedPassword &password, const Accounts::EOAddress &derivedFrom, const Accounts::DerivationPath &path, int pageSize, int pageNumber);

} // namespaces
