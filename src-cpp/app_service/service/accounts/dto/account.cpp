#include "accounts/account.h"
#include "backend/accounts.h"
#include <QJsonArray>
#include <QJsonObject>
#include <QJsonValue>
#include <QStringList>

bool Accounts::AccountDto::isValid() const
{
    return name.length() > 0 && keyUid.length() > 0;
}

Accounts::Image Accounts::toImage(const QJsonValue& jsonObj)
{
    auto result = Accounts::Image();

    result.keyUid = jsonObj["keyUid"].toString();
    result.imgType = jsonObj["type"].toString();
    result.uri = jsonObj["uri"].toString();
    result.width = jsonObj["width"].toInt();
    result.height = jsonObj["height"].toInt();
    result.fileSize = jsonObj["fileSize"].toInt();
    result.resizeTarget = jsonObj["resizeTarget"].toInt();

    return result;
}

Accounts::AccountDto Accounts::toAccountDto(const QJsonValue& jsonObj)
{
    auto result = Accounts::AccountDto();

    result.name = jsonObj["name"].toString();
    result.timestamp = jsonObj["timestamp"].toInt();
    result.identicon = jsonObj["identicon"].toString();
    result.keycardPairing = jsonObj["keycard-pairing"].toString();
    result.keyUid = jsonObj["key-uid"].toString();

    foreach(const QJsonValue& value, jsonObj["images"].toArray())
    {
        result.images << Accounts::toImage(value);
    }

    return result;
}
