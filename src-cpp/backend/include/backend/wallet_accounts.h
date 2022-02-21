#ifndef WALLETACCOUNT_BACKEND_H
#define WALLETACCOUNT_BACKEND_H

#include <QJsonArray>

#include "backend/types.h"

namespace Backend::Wallet::Accounts
{
Backend::RpcResponse<QJsonArray> getAccounts();
} // namespace Backend::Wallet::Accounts

#endif // WALLETACCOUNT_BACKEND_H
