#pragma once

#include "Common/Constants.h"
#include "Common/SigningPhrases.h"
#include "Common/Json.h"

#include <QtCore>

// TODO: Move to StatusGo library
namespace Status::Onboarding
{

struct AccountDto
{
    QString name;
    long timestamp;
    QString identicon;
    QString keycardPairing;
    QString keyUid;

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
            result.identicon = Json::getMandatoryProp(jsonObj, "identicon")->toString();
            result.keycardPairing = Json::getMandatoryProp(jsonObj, "keycard-pairing")->toString();
            result.keyUid = Json::getMandatoryProp(jsonObj, "key-uid")->toString();

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
