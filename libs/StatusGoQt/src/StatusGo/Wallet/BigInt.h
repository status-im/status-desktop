#pragma once

#include <Helpers/conversions.h>

#include <QByteArray>
#include <QString>

#include <nlohmann/json.hpp>

using json = nlohmann::json;

namespace Status::StatusGo::Wallet {

/// Quick dirty and unsafe alternative to missing BigInt library used to display balances
/// \warning doesn't work and it will fail for values higher than 2^64
/// \todo replace it with a proper hex and 256 bit integer implementation
/// \todo test me
class BigInt {
public:
    /// \throws std::runtime_error if value is not a valid hex string or value is higher than 2^64
    explicit BigInt(const QByteArray& value);
    BigInt() = default;

    /// Converts into the 0x prefixed hexadecimal display required by status-go
    QByteArray toHexData() const;

    /// Human readable form
    QString toString() const;

private:
    /// \throws std::runtime_error if value is not a valid status-go hex string or value is higher than 2^64
    /// \see toHexData
    quint64 parseHex(const QByteArray &value) const;

    quint64 m_value;
};

}

namespace nlohmann {

template<>
struct adl_serializer<Status::StatusGo::Wallet::BigInt> {
    static void to_json(json& j, const Status::StatusGo::Wallet::BigInt& num) {
        j = num.toHexData();
    }

    static void from_json(const json& j, Status::StatusGo::Wallet::BigInt& num) {
        auto str = j.get<std::string>();
        num = Status::StatusGo::Wallet::BigInt(QByteArray::fromRawData(str.c_str(), str.size()));
    }
};

}
