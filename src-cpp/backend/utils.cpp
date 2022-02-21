#include "backend/utils.h"
#include "backend/types.h"
#include <QCryptographicHash>
#include <QDebug>
#include <QJsonArray>
#include <QJsonDocument>
#include <QJsonObject>
#include <QString>
#include <QVector>

QJsonArray Backend::Utils::toJsonArray(const QVector<QString>& value)
{
    QJsonArray array;
    for(auto& v : value)
        array << v;
    return array;
}

QString Backend::Utils::jsonToStr(QJsonObject obj)
{
    QJsonDocument doc(obj);
    return QString::fromUtf8(doc.toJson());
}

QString Backend::Utils::jsonToStr(QJsonArray arr)
{
    QJsonDocument doc(arr);
    return QString::fromUtf8(doc.toJson());
}

QVector<QString> Backend::Utils::toStringVector(const QJsonArray& arr)
{
    QVector<QString> result;
    foreach(const QJsonValue& value, arr)
    {
        result << value.toString();
    }
    return result;
}

QString Backend::Utils::hashString(QString str)
{
    return "0x" + QString::fromUtf8(QCryptographicHash::hash(str.toUtf8(), QCryptographicHash::Keccak_256).toHex());
}

void Backend::Utils::throwOnError(QJsonObject response)
{
    if(!response["error"].isUndefined() && !response["error"].toString().isEmpty())
    {
        qWarning() << "RpcException: " << response["error"].toString();
        throw Backend::RpcException(response["error"].toString().toStdString());
    }
}
