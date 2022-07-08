#pragma once

#include <QtCore/QJsonObject>

namespace Status
{

class Json
{
public:
    /// TODO: refactor to get std::optional<QJsonObject> or rename it to get*It
    static QJsonObject::const_iterator getProp(const QJsonObject& object, const QString& field)
    {
        const auto it = object.constFind(field);
        return it;
    }

    /// TODO: refactor to get QJsonObject
    static QJsonObject::const_iterator getMandatoryProp(const QJsonObject& object, const QString& field)
    {
        const auto it = getProp(object, field);

        if (it == object.constEnd())
        {
            throw std::logic_error(QString("No field `%1`").arg(field).toStdString());
        }

        return it;
    }
};

}
