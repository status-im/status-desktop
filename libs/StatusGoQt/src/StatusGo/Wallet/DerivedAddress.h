#pragma once

#include "Accounts/accounts_types.h"

#include <Helpers/conversions.h>

#include <QColor>

#include <nlohmann/json.hpp>

#include <vector>

namespace Accounts = Status::StatusGo::Accounts;

using json = nlohmann::json;

namespace Status::StatusGo::Wallet {

/*!
 * \brief Define a derived address as returned by the corresponding API
 * \note equivalent of status-go's DerivedAddress@api.go
 * \see \c getDerivedAddressesForPath
 */
struct DerivedAddress
{
    Accounts::EOAddress  address;
    Accounts::DerivationPath path;
    bool hasActivity = false;
    bool alreadyCreated = false;
};

using DerivedAddresses = std::vector<DerivedAddress>;

NLOHMANN_DEFINE_TYPE_NON_INTRUSIVE(DerivedAddress, address, path, hasActivity, alreadyCreated);

}
