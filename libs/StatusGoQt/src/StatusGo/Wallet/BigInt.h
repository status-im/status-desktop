#pragma once

#include <Helpers/conversions.h>

#include <QByteArray>
#include <QString>

#include <nlohmann/json.hpp>

#include <boost/multiprecision/cpp_int.hpp>

using json = nlohmann::json;

namespace Status
{
namespace StatusGo::Wallet
{

using BigInt = boost::multiprecision::uint256_t;

/// Converts into the 0x prefixed hexadecimal display required by status-go (also uppercase)
std::string toHexData(const BigInt& num, bool uppercase = false);

/// \throws std::runtime_error if value is not a valid status-go hex string
///         or value is higher than 2^64 (numbers larger than 256 bits are not accepted)
/// \see toHexData
BigInt parseHex(const std::string& value);

} // namespace StatusGo::Wallet

/// Human readable form
QString toQString(const StatusGo::Wallet::BigInt& num);

} // namespace Status

namespace nlohmann
{

namespace GoWallet = Status::StatusGo::Wallet;

template <>
struct adl_serializer<GoWallet::BigInt>
{
    static void to_json(json& j, const GoWallet::BigInt& num)
    {
        j = GoWallet::toHexData(num);
    }

    static void from_json(const json& j, GoWallet::BigInt& num)
    {
        if(j.is_number())
            num = GoWallet::BigInt(j.get<long long>());
        else
            num = GoWallet::BigInt(j.get<std::string>());
    }
};

} // namespace nlohmann
