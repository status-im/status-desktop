#pragma once

#include <Helpers/conversions.h>

#include <QColor>

#include <nlohmann/json.hpp>

#include <vector>

using json = nlohmann::json;

namespace Status::StatusGo::Wallet {

/*!
 * \brief Define a derived address as returned by the corresponding API
 * \note equivalent of status-go's DerivedAddress@api.go
 * \see \c getDerivedAddressesForPath
 */
struct DerivedAddress
{
    // TODO create and Address type represents the 20 byte address of an Ethereum account. See https://pkg.go.dev/github.com/ethereum/go-ethereum/common?utm_source=gopls#Address
    QString        address;
    // TODO: create an Path named type
    QString        path;
    bool           hasActivity = false;
    bool           alreadyCreated = false;
};

using DerivedAddresses = std::vector<DerivedAddress>;

NLOHMANN_DEFINE_TYPE_NON_INTRUSIVE(DerivedAddress, address, path, hasActivity, alreadyCreated);

}
