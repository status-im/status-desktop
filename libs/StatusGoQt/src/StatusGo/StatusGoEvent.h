#pragma once

#include <Accounts/accounts_types.h>

#include <Helpers/NamedType.h>
#include <Helpers/conversions.h>

#include <Wallet/BigInt.h>

#include <nlohmann/json.hpp>

using json = nlohmann::json;

namespace Status::StatusGo
{

/// \see status-go's EventType@events.go in services/wallet/transfer module
using StatusGoEventType = Helpers::NamedType<QString, struct StatusGoEventTypeTag>;

/// \see status-go's Event@events.go in services/wallet/transfer module
struct StatusGoEvent
{
    std::string type;
    json event;
    std::optional<QString> error;
};

void to_json(json& j, const StatusGoEvent& d);
void from_json(const json& j, StatusGoEvent& d);

} // namespace Status::StatusGo
