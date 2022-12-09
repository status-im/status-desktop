#pragma once

#include <StatusGo/Accounts/accounts_types.h>

#include <QStringLiteral>
#include <QtCore>

namespace GoAccounts = Status::StatusGo::Accounts;

namespace Status::Constants
{

namespace Fleet
{
inline const auto Prod = u"eth.prod"_qs;
inline const auto Staging = u"eth.staging"_qs;
inline const auto WakuV2Prod = u"wakuv2.prod"_qs;
inline const auto WakuV2Test = u"wakuv2.test"_qs;
inline const auto GoWakuTest = u"go-waku.test"_qs;
} // namespace Fleet

namespace FleetNodes
{
inline const auto Bootnodes = u"boot"_qs;
inline const auto Mailservers = u"mail"_qs;
inline const auto Rendezvous = u"rendezvous"_qs;
inline const auto Whisper = u"whisper"_qs;
inline const auto Waku = u"tcp/p2p/waku"_qs;
inline const auto Websocket = u"wss/p2p/waku"_qs;
} // namespace FleetNodes

namespace General
{
inline const auto DefaultNetworkName = u"mainnet_rpc"_qs;
//const DEFAULT_NETWORKS_IDS* = @["mainnet_rpc", "testnet_rpc", "rinkeby_rpc", "goerli_rpc", "xdai_rpc", "poa_rpc" ]

inline const auto ZeroAddress = u"0x0000000000000000000000000000000000000000"_qs;

inline const GoAccounts::DerivationPath PathWalletRoot{u"m/44'/60'/0'/0"_qs};
// EIP1581 Root Key, the extended key from which any whisper key/encryption key can be derived
inline const GoAccounts::DerivationPath PathEIP1581{u"m/43'/60'/1581'"_qs};
// BIP44-0 Wallet key, the default wallet key
inline const GoAccounts::DerivationPath PathDefaultWallet{PathWalletRoot.get() + u"/0"_qs};
// EIP1581 Chat Key 0, the default whisper key
inline const GoAccounts::DerivationPath PathWhisper{PathEIP1581.get() + u"/0'/0"_qs};

inline const std::vector<GoAccounts::DerivationPath> AccountDefaultPaths{
    PathWalletRoot, PathEIP1581, PathWhisper, PathDefaultWallet};
} // namespace General

} // namespace Status::Constants
