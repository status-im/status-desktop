#pragma once

#include <QString>
#include <iostream>
using namespace std;

namespace Backend
{

const QString GENERATED = "generated";
const QString SEED = "seed";
const QString KEY = "key";
const QString WATCH = "watch";

struct RpcException : public std::exception
{
private:
    std::string m_message;

public:
    explicit RpcException(const std::string& message);
    const char* what() const throw();
};

class RpcError
{
public:
    int m_code;
    QString m_message;

    friend ostream& operator<<(ostream& os, Backend::RpcError& r);
};

template <typename T>

class RpcResponse
{
public:
    QString m_jsonrpc;
    T m_result;
    int m_id;
    RpcError m_error;

public:
    RpcResponse(QString jsonrpc, T result)
        : m_jsonrpc(jsonrpc)
        , m_result(result)
    { }
};

} // namespace Backend
