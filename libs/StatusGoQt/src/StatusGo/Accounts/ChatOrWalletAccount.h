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
    EOAddress address;
    bool isChat = false;
    int clock = -1;
    QColor color;
    std::optional<EOAddress> derivedFrom;
    QString emoji;
    bool isHidden = false;
    QString mixedcaseAddress;
    QString name;
    DerivationPath path;
    QString publicKey;
    bool isRemoved = false;
    bool isWallet = false;
};

using ChatOrWalletAccounts = std::vector<ChatOrWalletAccount>;

void to_json(json& j, const ChatOrWalletAccount& d);
void from_json(const json& j, ChatOrWalletAccount& d);

}
