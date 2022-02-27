#pragma once

#include <QtCore>

namespace Backend
{
    // Used in calls where we don't have version and id returned from `status-go`
    static QString DefaultVersion = "2.0";
    static constexpr int DefaultId = 0;

    struct RpcError
    {
        int code;
        QString message;
    };

    template <typename T>
    struct RpcResponse
    {
        T result;
        QString jsonRpcVersion;
        int id;
        RpcError error;

        RpcResponse(T result, QString version = DefaultVersion, int id = DefaultId,
                    RpcError error = RpcError{-1, QString()})
            : result(result)
            , jsonRpcVersion(version)
            , id(id)
            , error(error)
        { }

        bool containsError() const {
            return !error.message.isEmpty();
        }
    };
}
