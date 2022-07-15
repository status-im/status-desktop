#pragma once

#include "accounts_types.h"

#include <Helpers/conversions.h>

#include <QColor>

#include <nlohmann/json.hpp>

#include <vector>

using json = nlohmann::json;

namespace Status::StatusGo::Accounts {


/// \brief Unique wallet account entity
/// \note equivalent of status-go's accounts.Account@multiaccounts/accounts/database.go
struct ChatOrWalletAccount
{
    QString name;
    EOAddress address;
    bool isChat{false};
    bool isWallet{false};
    QColor color;
    QString emoji;
    std::optional<EOAddress> derivedFrom;
    DerivationPath path;
    int clock{-1};
    bool isHidden{false};
    bool isRemoved{false};
    QString publicKey;
    QString mixedcaseAddress;
};

using ChatOrWalletAccounts = std::vector<ChatOrWalletAccount>;

void to_json(json& j, const ChatOrWalletAccount& d);
void from_json(const json& j, ChatOrWalletAccount& d);

}
