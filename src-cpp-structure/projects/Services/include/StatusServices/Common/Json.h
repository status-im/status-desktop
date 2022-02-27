#pragma once

#include <QtCore/QJsonObject>

namespace Status
{

    class Json
    {
    public:
        static QJsonObject::const_iterator getProp(const QJsonObject& object, const QString& field)
        {
            const auto it = object.constFind(field);
            return it;
        }

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
