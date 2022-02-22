#pragma once

#include <QJsonArray>
#include <QJsonObject>
#include <QString>
#include <QVector>

namespace Backend
{
class Utils
{
public:
    static QString hashString(const QString& str);
    static QString jsonToStr(const QJsonObject& obj);
    static QString jsonToStr(const QJsonArray& arr);
    static QJsonArray toJsonArray(const QVector<QString>& value);
    static QVector<QString> toStringVector(const QJsonArray& arr);
    static void throwOnError(const QJsonObject& response);
};
} // namespace Backend
