#include "backend/types.h"
#include <QString>

using namespace std;

ostream& operator<<(ostream& os, const Backend::RpcError& r)
{
    return (os << "RpcError(\n code: " << r.m_code << "\n message: " << r.m_message.toStdString() << "\n)"
               << std::endl);
}

Backend::RpcException::RpcException(const std::string& message)
    : m_message(message)
{ }

const char* Backend::RpcException::what() const throw()
{
    return m_message.c_str();
}
