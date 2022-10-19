#pragma once

#include <nlohmann/json.hpp>

#include <vector>

#include <QColor>

using json = nlohmann::json;

namespace Status::StatusGo::Settings
{

struct SettingsDto
{
    QString address;
    QString displayName;
    QString preferredName;
    QString keyUid;
    QString publicKey;
};

void to_json(json& j, const SettingsDto& d);
void from_json(const json& j, SettingsDto& d);
} // namespace Status::StatusGo::Settings
