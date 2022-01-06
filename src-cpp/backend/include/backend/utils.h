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
	static QString hashString(QString str);
	static QString jsonToStr(QJsonObject obj);
	static QString jsonToStr(QJsonArray arr);
	static QJsonArray toJsonArray(const QVector<QString>& value);
	static QVector<QString> toStringVector(const QJsonArray& arr);
	static void throwOnError(QJsonObject response);
};
} // namespace Backend
