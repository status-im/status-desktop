#include "Utils.h"

#include "libstatus.h"

#include <QtCore>

namespace Status::StatusGo::Utils
{

QJsonArray toJsonArray(const QVector<QString>& value)
{
    QJsonArray array;
    for(auto& v : value)
        array << v;
    return array;
}

QString hashString(QString str)
{
    return "0x" + QString::fromUtf8(QCryptographicHash::hash(str.toUtf8(),
                                                                QCryptographicHash::Keccak_256).toHex());
}

}
