#pragma once

#include <Accounts/accounts_types.h>

#include <Helpers/NamedType.h>
#include <Helpers/conversions.h>

#include <Wallet/BigInt.h>

#include <nlohmann/json.hpp>

namespace Status::StatusGo::Wallet::Transfer
{

/// \see status-go's EventType@events.go in services/wallet/transfer module
using EventType = Helpers::NamedType<QString, struct TransferEventTypeTag>;

struct Events
{
    static const EventType NewTransfers;
    static const EventType FetchingRecentHistory;
    static const EventType RecentHistoryReady;
    static const EventType FetchingHistoryError;
    static const EventType NonArchivalNodeDetected;

    static const EventType WalletTickReload;
    static const EventType EventBalanceHistoryUpdateStarted;
    static const EventType EventBalanceHistoryUpdateFinished;
};

/// \see status-go's Event@events.go in services/wallet/transfer module
struct Event
{
    EventType type;
    std::optional<StatusGo::Wallet::BigInt> blockNumber;
    /// Accounts are \c null in case of error. In the error case message contains the error message
    std::optional<std::vector<StatusGo::Accounts::EOAddress>> accounts;
    QString message;
};

NLOHMANN_DEFINE_TYPE_NON_INTRUSIVE(Event, type, blockNumber, accounts, message);

} // namespace Status
