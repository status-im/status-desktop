#pragma once

#include "Common/Constants.h"
#include "Common/SigningPhrases.h"
#include "Common/Json.h"

#include <StatusGo/Accounts/accounts_types.h>

#include <QtCore>

namespace Accounts = Status::StatusGo::Accounts;

// TODO: Move to StatusGo library
namespace Status::Onboarding
{

/// \note equivalent of status-go's multiaccounts.Account@multiaccounts/database.go
struct MultiAccount
{
    QString name;
    long timestamp;
    QString keycardPairing;
    QString keyUid;
    // TODO images
    // TODO colorHash
    // TODO colorId
    Accounts::EOAddress address;

    bool isValid() const
    {
        return !(name.isEmpty() || keyUid.isEmpty());
    }

    static MultiAccount toMultiAccount(const QJsonObject& jsonObj)
    {
        auto result = MultiAccount();

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
            result.address = Accounts::EOAddress(Json::getProp(jsonObj, "address")->toString());

            /// TODO: investigate unhandled `photo-path` value
        }
        catch (std::exception e)
        {
            qWarning() << QString("Mapping MultiAccount failed: %1").arg(e.what());
        }

        return result;
    }
};

}
