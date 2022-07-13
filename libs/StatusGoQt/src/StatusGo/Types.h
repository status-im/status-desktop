#pragma once

#include <Helpers/NamedType.h>

#include <QString>

namespace Status::StatusGo
{

using HashedPassword = Helpers::NamedType<QString, struct HashedPasswordTag>;

// Used in calls where we don't have version and id returned from `status-go`

struct RpcError
{
    // TODO: enum instead for known errors?
    static constexpr int NoError = -1;
    int code = NoError;
    QString message;

    static constexpr auto UnknownVersion{""};
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
        : result(std::move(result))
        , jsonRpcVersion(std::move(version))
        , id(id)
        , error(std::move(error))
    { }

    bool containsError() const {
        return !error.message.isEmpty() || error.code != RpcError::NoError;
    }
};

}
