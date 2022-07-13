#pragma once

#include "Types.h"
#include "Accounts/accounts_types.h"

#include <QJsonDocument>
#include <QJsonObject>
#include <QJsonArray>

namespace Status::StatusGo::Utils
{

namespace Param {
    static constexpr auto Id{"id"};
    static constexpr auto JsonRpc{"jsonrpc"};
    static constexpr auto Result{"result"};
    static constexpr auto Error{"error"};
    static constexpr auto ErrorMessage{"message"};
    static constexpr auto ErrorCode{"code"};
}

template<class T>
QByteArray jsonToByteArray(const T& json)
{
    static_assert(std::is_same_v<T, QJsonObject> ||
            std::is_same_v<T, QJsonArray>, "Wrong Json type. Supported: Object, Array");
    return QJsonDocument(json).toJson(QJsonDocument::Compact);
}

QJsonArray toJsonArray(const std::vector<Accounts::DerivationPath>& value);

/// Check if json contains a standard status-go error and
std::optional<RpcError> getRPCErrorInJson(const QJsonObject& json);

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

// TODO: Clarify scope. The assumption done here are valid only for status-go::CallPrivateRPC API.
template<class T>
RpcResponse<T> buildPrivateRPCResponse(const T& json)
{
    auto response = RpcResponse<T>(T());

    if constexpr (std::is_same_v<T, QJsonObject>)
    {
    if (!json[Param::Id].isNull() && !json[Param::Id].isUndefined())
        response.id = json[Param::Id].toInt();

    if (!json[Param::JsonRpc].isNull() && !json[Param::JsonRpc].isUndefined())
        response.jsonRpcVersion = json[Param::JsonRpc].toString();

    response.error = getRPCErrorInJson(json).value_or(RpcError());

    if (!json[Param::Result].isNull() && !json[Param::Result].isUndefined())
        response.result = json[Param::Result].toObject();
    }
    else if constexpr (std::is_same_v<T, QJsonArray>)
    {
        response.result = json;
    }

    return response;
}

const char* statusGoCallPrivateRPC(const char* inputJSON);

template<class T>
RpcResponse<T> callPrivateRpc(const QByteArray& payload)
{
    try
    {
        auto result = statusGoCallPrivateRPC(payload.data());
        T jsonResult;
        if(!Utils::checkReceivedResponse(result, jsonResult))
        {
            auto msg = QObject::tr("parsing response failed");
            throw std::domain_error(msg.toStdString());
        }

        return Utils::buildPrivateRPCResponse(jsonResult);
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

HashedPassword hashPassword(const QString &str);

}
