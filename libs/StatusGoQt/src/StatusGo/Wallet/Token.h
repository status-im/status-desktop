#pragma once

#include "wallet_types.h"

#include "Accounts/accounts_types.h"

#include <QColor>

#include <nlohmann/json.hpp>

#include <vector>

namespace Accounts = Status::StatusGo::Accounts;

using json = nlohmann::json;

namespace Status::StatusGo::Wallet {

/// \note equivalent of status-go's Token@token.go
/// \see \c getDerivedAddressesForPath
struct Token
{
    Accounts::EOAddress address;
	QString name;
	QString symbol;
	QColor color;
	unsigned int decimals;
	ChainID  chainId;
};

using Tokens = std::vector<Token>;

NLOHMANN_DEFINE_TYPE_NON_INTRUSIVE(Token, address, name,symbol,
	                               color, decimals, chainId);

}