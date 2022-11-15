#include "Event.h"

namespace Status::StatusGo::Wallet::Transfer
{

const EventType Events::NewTransfers{"new-transfers"};
const EventType Events::FetchingRecentHistory{"recent-history-fetching"};
const EventType Events::RecentHistoryReady{"recent-history-ready"};
const EventType Events::FetchingHistoryError{"fetching-history-error"};
const EventType Events::NonArchivalNodeDetected{"non-archival-node-detected"};

const EventType Events::WalletTickReload{"wallet-tick-reload"};
const EventType Events::EventBalanceHistoryUpdateStarted{"wallet-balance-history-update-started"};
const EventType Events::EventBalanceHistoryUpdateFinished{"wallet-balance-history-update-finished"};
const EventType Events::EventBalanceHistoryUpdateFinishedWithError{"wallet-balance-history-update-finished-with-error"};

} // namespace Status::StatusGo::Wallet::Transfer
