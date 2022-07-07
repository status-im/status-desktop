#pragma once

#include "Common/Constants.h"
#include "Common/SigningPhrases.h"
#include "Common/Json.h"

#include <QtCore>

// TODO: Move to StatusGo library
namespace Status::Onboarding
{

// TODO: refactor it to MultiAccount
struct AccountDto
{
    QString name;
    long timestamp;
    QString keycardPairing;
    QString keyUid;
    // TODO images
    // TODO colorHash
    // TODO colorId
    QString address;

    bool isValid() const
    {
        return !(name.isEmpty() || keyUid.isEmpty());
    }

    static AccountDto toAccountDto(const QJsonObject& jsonObj)
    {
        auto result = AccountDto();

        try
        {
            result.name = Json::getMandatoryProp(jsonObj, "name")->toString();
            auto timestampIt = Json::getProp(jsonObj, "timestamp");
            if(timestampIt != jsonObj.constEnd()) {
                bool ok = false;
                auto t = timestampIt->toString().toLong(&ok);
                if(ok)
                    result.timestamp = t;
            }
            result.keycardPairing = Json::getMandatoryProp(jsonObj, "keycard-pairing")->toString();
            result.keyUid = Json::getMandatoryProp(jsonObj, "key-uid")->toString();
            result.address = Json::getProp(jsonObj, "address")->toString();

            /// TODO: investigate unhandled `photo-path` value
        }
        catch (std::exception e)
        {
            qWarning() << QObject::tr("Mapping AccountDto failed: %1").arg(e.what());
        }

        return result;
    }
};

}
