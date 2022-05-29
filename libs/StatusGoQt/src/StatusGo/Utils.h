#pragma once

#include "Types.h"
#include "libstatus.h"

#include <QtCore>
#include <QLatin1StringView>

namespace Status::StatusGo::Utils
{

namespace Param {
    static constexpr QLatin1StringView Id{"id"};
    static constexpr QLatin1StringView JsonRpc{"jsonrpc"};
    static constexpr QLatin1StringView Result{"result"};
    static constexpr QLatin1StringView Error{"error"};
    static constexpr QLatin1StringView ErrorMessage{"message"};
    static constexpr QLatin1StringView ErrorCode{"code"};
}

template<class T>
QByteArray jsonToByteArray(const T& json)
{
    if constexpr (std::is_same_v<T, QJsonObject> ||
            std::is_same_v<T, QJsonArray>)
    {
        return QJsonDocument(json).toJson(QJsonDocument::Compact);
    }

    return QByteArray();
}

QJsonArray toJsonArray(const QVector<QString>& value);

template<class T>
bool checkReceivedResponse(const QString& response, T& json)
{
    QJsonParseError error;
    auto jsonDocument = QJsonDocument::fromJson(response.toUtf8(), &error);

    if (error.error != QJsonParseError::NoError)
        return false;

    if constexpr (std::is_same_v<T, QJsonObject>)
    {
        json = jsonDocument.object();
        return true;
    }
    else if constexpr (std::is_same_v<T, QJsonArray>)
    {
        json = jsonDocument.array();
        return true;
    }

    return false;
}

template<class T>
RpcResponse<T> buildJsonRpcResponse(const T& json)
{
    auto response = RpcResponse<T>(T());

    if constexpr (std::is_same_v<T, QJsonObject>)
    {
    if (!json[Param::Id].isNull() && !json[Param::Id].isUndefined())
        response.id = json[Param::Id].toInt();

    if (!json[Param::JsonRpc].isNull() && !json[Param::JsonRpc].isUndefined())
        response.jsonRpcVersion = json[Param::JsonRpc].toString();

    if (!json[Param::Error].isNull() && !json[Param::Error].isUndefined())
    {
        auto errObj = json[Param::Id].toObject();
        if (!errObj[Param::ErrorCode].isNull() && !errObj[Param::ErrorCode].isUndefined())
            response.error.code = errObj[Param::ErrorCode].toInt();
        if (!errObj[Param::ErrorMessage].isNull() && !errObj[Param::ErrorMessage].isUndefined())
            response.error.message = errObj[Param::ErrorMessage].toString();
    }

    if (!json[Param::Result].isNull() && !json[Param::Result].isUndefined())
        response.result = json[Param::Result].toObject();
    }
    else if constexpr (std::is_same_v<T, QJsonArray>)
    {
        response.result = json;
    }

    return response;
}

template<class T>
RpcResponse<T> callPrivateRpc(const QByteArray& payload)
{
    try
    {
        auto result = CallPrivateRPC(const_cast<QByteArray&>(payload).data());
        T jsonResult;
        if(!Utils::checkReceivedResponse(result, jsonResult))
        {
            auto msg = QObject::tr("parsing response failed");
            throw std::domain_error(msg.toStdString());
        }

        return Utils::buildJsonRpcResponse(jsonResult);
    }
    catch (std::exception& e)
    {
        auto response = RpcResponse<T>(T());
        response.error.message = QObject::tr("an error executing rpc call occurred, msg: %1").arg(e.what());
        return response;
    }
    catch (...)
    {
        auto response = RpcResponse<T>(T());
        response.error.message = QObject::tr("an error executing rpc call");
        return response;
    }
}

QString hashString(QString str);

}
