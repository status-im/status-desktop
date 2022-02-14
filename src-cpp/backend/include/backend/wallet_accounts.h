#ifndef WALLETACCOUNT_BACKEND_H
#define WALLETACCOUNT_BACKEND_H

#include <QJsonArray>

#include "backend/types.h"

namespace Backend
{
namespace Wallet
{
namespace  Accounts
{
Backend::RpcResponse<QJsonArray> getAccounts();
} // namespace Accounts
} // namespace Wallet
} // namespace Backend

#endif // WALLETACCOUNT_BACKEND_H
