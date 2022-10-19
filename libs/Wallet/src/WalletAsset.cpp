#include "WalletAsset.h"

#include <boost/multiprecision/number.hpp>

namespace Status::Wallet
{

WalletAsset::WalletAsset(const WalletGo::TokenPtr token, StatusGo::Wallet::BigInt balance, QObject* parent)
    : QObject{parent}
    , m_token(token)
    , m_balance(std::move(balance))
{ }

const QString WalletAsset::name() const
{
    return m_token ? m_token->name : u""_qs;
}

const QString WalletAsset::symbol() const
{
    return m_token ? m_token->symbol : u""_qs;
}

const QColor WalletAsset::color() const
{
    return m_token ? m_token->color : QColor();
}

quint64 WalletAsset::count() const
{
    return (m_token)
               ? static_cast<quint64>(m_balance / boost::multiprecision::pow(WalletGo::BigInt(10), m_token->decimals))
               : 0;
}

float WalletAsset::value() const
{
    if(m_token)
    {
        const int mantissaDigits = m_token->decimals > 3 ? 3 : 0;
        const auto scale = 10 * mantissaDigits;
        return static_cast<float>((m_balance * scale) /
                                  boost::multiprecision::pow(WalletGo::BigInt(10), m_token->decimals)) /
               scale;
    }
    else
        return 0;
}

} // namespace Status::Wallet
