#pragma once

#include "wallet_types.h"
#include "Accounts/accounts_types.h"

#include <Helpers/conversions.h>

#include <nlohmann/json.hpp>

#include <vector>

namespace Accounts = Status::StatusGo::Accounts;

namespace Status::StatusGo::Wallet {

/// \brief Define a saved wallet address as returned by the corresponding API
/// \note equivalent of status-go's SavedAddress@api.go
/// \see \c getSavedAddresses
struct SavedAddress
{
    Accounts::EOAddress address;
    QString name;
    bool favourite;
    ChainID chainId;
};

using SavedAddresses = std::vector<SavedAddress>;

NLOHMANN_DEFINE_TYPE_NON_INTRUSIVE(SavedAddress, address, name, favourite, chainId);

}
