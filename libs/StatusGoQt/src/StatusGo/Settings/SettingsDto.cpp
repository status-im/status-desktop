#include "SettingsDto.h"

#include <Helpers/JsonMacros.h>
#include <Helpers/conversions.h>

using namespace Status::StatusGo;

void Settings::to_json(json& j, const SettingsDto& d)
{
    j = {
        {"address", d.address},
        {"display-name", d.displayName},
        {"preferred-name", d.preferredName},
        {"key-uid", d.keyUid},
        {"public-key", d.publicKey},
    };
}

void Settings::from_json(const json& j, SettingsDto& d)
{
    STATUS_READ_NLOHMAN_JSON_PROPERTY(address)
    STATUS_READ_NLOHMAN_JSON_PROPERTY(displayName, "display-name")
    STATUS_READ_NLOHMAN_JSON_PROPERTY(preferredName, "preferred-name", false)
    STATUS_READ_NLOHMAN_JSON_PROPERTY(keyUid, "key-uid")
    STATUS_READ_NLOHMAN_JSON_PROPERTY(publicKey, "public-key")
}
