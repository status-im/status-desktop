#include <QDebug>
#include <QJsonDocument>
#include <QJsonObject>

#include "backend/types.h"
#include "backend/utils.h"
#include "backend/wallet_accounts.h"
#include "libstatus.h"

namespace Backend::Wallet::Accounts
{
RpcResponse<QJsonArray> getAccounts()
{
    QJsonObject inputJSON{{"jsonrpc", "2.0"}, {"method", "accounts_getAccounts"}, {"params", QJsonValue()}};
    auto result = CallPrivateRPC(Utils::jsonToStr(inputJSON).toUtf8().data());
    return RpcResponse<QJsonArray>(result, QJsonDocument::fromJson(result)["result"].toArray());
}

} // namespace Backend::Wallet::Accounts
