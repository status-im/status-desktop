#pragma once

#include <QLatin1StringView>

namespace Status::StatusGo
{

// Used in calls where we don't have version and id returned from `status-go`

struct RpcError
{
    // TODO: enum instead for known errors?
    static constexpr int NoError = -1;
    int code = NoError;
    QString message;

    static constexpr QLatin1StringView UnknownVersion{""};
    static constexpr int UnknownId = 0;
};

template <typename T>
struct RpcResponse
{
    T result;
    QString jsonRpcVersion;
    int id;
    RpcError error;

    explicit
    RpcResponse(T result, QString version = RpcError::UnknownVersion, int id = RpcError::UnknownId,
                RpcError error = RpcError())
        : result(result)
        , jsonRpcVersion(version)
        , id(id)
        , error(error)
    { }

    bool containsError() const {
        return !error.message.isEmpty() || error.code != RpcError::NoError;
    }
};

}
