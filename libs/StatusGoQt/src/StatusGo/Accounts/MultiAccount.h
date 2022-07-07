#pragma once

#include <Helpers/conversions.h>

#include <QColor>

#include <nlohmann/json.hpp>

#include <vector>

using json = nlohmann::json;

namespace Status::StatusGo::Accounts {

// TODO: rename to MixedAccount
// TODO: create custom types or just named types for all. Also fix APIs after this

/*! \brief Unique wallet account entity
 */
struct MultiAccount
{
    QString address;
    bool isChat = false;
    int clock = -1;
    QColor color;
    std::optional<QString> derivedFrom;
    QString emoji;
    bool isHidden = false;
    QString mixedcaseAddress;
    QString name;
    QString path;
    QString publicKey;
    bool isRemoved = false;
    bool isWallet = false;
};

using MultiAccounts = std::vector<MultiAccount>;

void to_json(json& j, const MultiAccount& d);
void from_json(const json& j, MultiAccount& d);

}
