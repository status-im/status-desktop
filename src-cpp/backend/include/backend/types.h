#pragma once

#include <QString>
#include <iostream>

namespace Backend
{
struct RpcException : public std::exception
{
private:
    std::string m_message;

public:
    explicit RpcException(const std::string& message);
    const char* what() const noexcept override;
};

class RpcError
{
public:
    double m_code{};
    QString m_message;

    RpcError() = default;
    RpcError(double code, const QString& message)
        : m_code(code)
        , m_message(message)
    { }

    friend std::ostream& operator<<(std::ostream& os, Backend::RpcError& r);
};

template <typename T>

class RpcResponse
{
public:
    QString m_jsonrpc;
    T m_result;
    int m_id{};
    RpcError m_error;

    RpcResponse(const QString& jsonrpc, T result)
        : m_jsonrpc(jsonrpc)
        , m_result(result)
    { }

    RpcResponse(const QString& jsonrpc, T result, const RpcError& error)
        : m_jsonrpc(jsonrpc)
        , m_result(result)
        , m_error(error)
    { }
};
} // namespace Backend
