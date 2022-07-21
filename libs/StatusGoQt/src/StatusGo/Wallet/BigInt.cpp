#include "BigInt.h"

#include <locale>
#include <iostream>

#include <Helpers/helpers.h>

namespace Status {
namespace StatusGo::Wallet {

std::string toHexData(const BigInt &num, bool uppercase)
{
    return num.str(0, std::ios_base::showbase | std::ios_base::hex | (uppercase ? std::ios_base::uppercase : 0));
}


using namespace QtLiterals;

bool has0xPrefix(const QByteArray &in) {
    return in.size() >= 2 && Helpers::iequals(in.first(2), "0x"_qba);
}

BigInt parseHex(const std::string &value)
{
    auto data = QByteArray::fromRawData(value.c_str(), value.size());
    if (!has0xPrefix(data))
        throw std::runtime_error("BigInt::parseHex missing 0x prefix");
    if (data.size() == 2)
        throw std::runtime_error("BigInt::parseHex empty number");
    if (data.size() > 3 && data[2] == '0')
        throw std::runtime_error("BigInt::parseHex leading zero");
    if (data.size() > 66)
        throw std::runtime_error("BigInt::parseHex more than 256 bits");
    return BigInt{data.data()};
}

} // namespace StatusGo::Wallet

QString toQString(const StatusGo::Wallet::BigInt &num)
{
    return QString::fromStdString(num.str(0, std::ios_base::dec));
}

} // namespace Status
