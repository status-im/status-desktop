#pragma once

#include "Types.h"
#include "libstatus.h"

#include <QtCore>

namespace Backend
{
    namespace Param {
        const QString Id = "id";
        const QString JsonRpc = "jsonrpc";
        const QString Result = "result";
        const QString Error = "error";
        const QString ErrorMessage = "message";
        const QString ErrorCode = "code";
    }

    class Utils
    {
    public:
        template<class T> static QByteArray jsonToByteArray(const T& json){
            if constexpr (std::is_same_v<T, QJsonObject> ||
                    std::is_same_v<T, QJsonArray>)
            {
                return QJsonDocument(json).toJson(QJsonDocument::Compact);
            }

            return QByteArray();
        }

        static QJsonArray toJsonArray(const QVector<QString>& value){
            QJsonArray array;
            for(auto& v : value)
                array << v;
            return array;
        }

        template<class T> static bool checkReceivedResponse(const QString& response, T& json)
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

        template<class T> static RpcResponse<T> buildJsonRpcResponse(const T& json) {
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

        template<class T> static RpcResponse<T> callPrivateRpc(const QByteArray& payload)
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

        static QString hashString(QString str) {
            return "0x" + QString::fromUtf8(QCryptographicHash::hash(str.toUtf8(),
                                                                     QCryptographicHash::Keccak_256).toHex());
        }
    };
}
