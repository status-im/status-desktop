#include "Utils.h"

#include <libstatus.h>

#include <QtCore>

namespace Status::StatusGo::Utils
{

QJsonArray toJsonArray(const std::vector<Accounts::DerivationPath>& value)
{
    QJsonArray array;
    for(auto& v : value)
        array << v.get();
    return array;
}

const char* statusGoCallPrivateRPC(const char* inputJSON) {
    // Evil done here! status-go API doesn't follow the proper const conventions
    return CallPrivateRPC(const_cast<char*>(inputJSON));
}

HashedPassword hashPassword(const QString &str)
{
    return HashedPassword("0x" + QString::fromUtf8(QCryptographicHash::hash(str.toUtf8(),
                                                             QCryptographicHash::Keccak_256).toHex()));
}

std::optional<RpcError> getRPCErrorInJson(const QJsonObject& json)
{
    auto errVal = json[Param::Error];
    if (errVal.isNull() || errVal.isUndefined())
        return std::nullopt;
    if(errVal.isString() && errVal.toString().length() == 0)
        return std::nullopt;

    RpcError response;
    auto errObj = json[Param::Id].toObject();
    if (!errObj[Param::ErrorCode].isNull() && !errObj[Param::ErrorCode].isUndefined())
        response.code = errObj[Param::ErrorCode].toInt();
    if (!errObj[Param::ErrorMessage].isNull() && !errObj[Param::ErrorMessage].isUndefined())
        response.message = errObj[Param::ErrorMessage].toString();
    else
        response.message = errVal.toString();
    return response;
}

}
