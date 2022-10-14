#include "Event.h"

namespace Status::StatusGo::Wallet::Transfer
{

const EventType Events::NewTransfers{"new-transfers"};
const EventType Events::FetchingRecentHistory{"recent-history-fetching"};
const EventType Events::RecentHistoryReady{"recent-history-ready"};
const EventType Events::FetchingHistoryError{"fetching-history-error"};
const EventType Events::NonArchivalNodeDetected{"non-archival-node-detected"};

} // namespace Status::StatusGo::Wallet
