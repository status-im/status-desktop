#include "BigInt.h"

#include <cstring>

namespace Status::StatusGo::Wallet {

BigInt::BigInt(const QByteArray &value)
    : m_value(parseHex(value))
{
}

QByteArray BigInt::toHexData() const
{
    return "0x"_qba + QByteArray::fromRawData(reinterpret_cast<const char*>(&m_value), sizeof(m_value)).toHex().toUpper();
}

QString BigInt::toString() const
{
    return QString::number(m_value);
}

using namespace QtLiterals;

bool has0xPrefix(const QByteArray &in) {
    return in.size() >= 2 && in.first(2).compare("0x"_qba, Qt::CaseInsensitive) == 0;
}

quint64 BigInt::parseHex(const QByteArray &data) const
{
    if (!has0xPrefix(data))
        throw std::runtime_error("BigInt::parseHex missing 0x prefix");
    if (data.size() == 2)
        throw std::runtime_error("BigInt::parseHex empty number");
    if (data.size() > 3 && data[2] == '0')
        throw std::runtime_error("BigInt::parseHex leading zero");
    if (data.size() > 66)
        throw std::runtime_error("BigInt::parseHex more than 256 bits");
    quint64 result{};
    // Supporting only 64 bit values for now
    if (data.size() > (sizeof(result)/4 + 2))
        throw std::runtime_error("BigInt::parseHex for now only 64 bit values supported");
    auto onlyData = QByteArray::fromHex(data.last(data.size() - 2));
    std::memcpy(&result, onlyData.data(), onlyData.size());
    return result;
}

}
