#pragma once


#include "Accounts/MultiAccount.h"
#include "DerivedAddress.h"

#include <vector>

namespace Accounts = Status::StatusGo::Accounts;

namespace Status::StatusGo::Wallet
{
/// \brief Retrieve a list of derived account addresses
/// \see \c generateAccountWithDerivedPath
/// \throws \c CallPrivateRpcError
DerivedAddresses getDerivedAddressesForPath(const QString &password, const QString &derivedFrom, const QString &path, int pageSize, int pageNumber);

} // namespaces
