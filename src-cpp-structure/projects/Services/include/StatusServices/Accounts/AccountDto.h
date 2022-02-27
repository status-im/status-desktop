#pragma once

#include <StatusServices/CommonService>

#include <QtCore>

namespace Status::Accounts
{
    struct Image
    {
        QString keyUid;
        QString imgType;
        QString uri;
        int width;
        int height;
        int fileSize;
        int resizeTarget;

        static Image toImage(const QJsonObject& jsonObj)
        {
            auto result = Image();

            try
            {
                result.keyUid = Json::getProp(jsonObj, "keyUid")->toString();
                result.imgType = Json::getProp(jsonObj, "type")->toString();
                result.uri = Json::getProp(jsonObj, "uri")->toString();
                result.width = Json::getProp(jsonObj, "width")->toInt();
                result.height = Json::getProp(jsonObj, "height")->toInt();
                result.fileSize = Json::getProp(jsonObj, "fileSize")->toInt();
                result.resizeTarget = Json::getProp(jsonObj, "resizeTarget")->toInt();
            }
            catch (std::exception e)
            {
                qWarning() << QObject::tr("Mapping Image failed: %1").arg(e.what());
            }

            return result;
        }
    };

    struct AccountDto
    {
        QString name;
        long timestamp;
        QString identicon;
        QString keycardPairing;
        QString keyUid;
        QVector<Image> images;

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
                bool ok;
                result.timestamp = Json::getMandatoryProp(jsonObj, "timestamp")->toString().toLong(&ok);
                result.identicon = Json::getMandatoryProp(jsonObj, "identicon")->toString();
                result.keycardPairing = Json::getMandatoryProp(jsonObj, "keycard-pairing")->toString();
                result.keyUid = Json::getMandatoryProp(jsonObj, "key-uid")->toString();

                foreach(const auto& value, jsonObj["images"].toArray())
                {
                    result.images << Image::toImage(value.toObject());
                }
            }
            catch (std::exception e)
            {
                qWarning() << QObject::tr("Mapping AccountDto failed: %1").arg(e.what());
            }

            return result;
        }
    };




}
