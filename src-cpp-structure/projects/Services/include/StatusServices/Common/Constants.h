#pragma once

#include <QtCore>

namespace Status::Constants
{
    namespace Fleet
    {
        const QString Prod = "eth.prod";
        const QString Staging = "eth.staging";
        const QString Test = "eth.test";
        const QString WakuV2Prod = "wakuv2.prod";
        const QString WakuV2Test = "wakuv2.test";
        const QString GoWakuTest = "go-waku.test";
    }

    namespace FleetNodes
    {
        const QString Bootnodes = "boot";
        const QString Mailservers = "mail";
        const QString Rendezvous = "rendezvous";
        const QString Whisper = "whisper";
        const QString Waku = "waku";
        const QString LibP2P = "libp2p";
        const QString Websocket = "websocket";
    }

    namespace General
    {
        const QString DefaultNetworkName = "mainnet_rpc";
        //const DEFAULT_NETWORKS_IDS* = @["mainnet_rpc", "testnet_rpc", "rinkeby_rpc", "goerli_rpc", "xdai_rpc", "poa_rpc" ]

        const QString ZeroAddress = "0x0000000000000000000000000000000000000000";

        const QString PathWalletRoot = "m/44'/60'/0'/0";
        // EIP1581 Root Key, the extended key from which any whisper key/encryption key can be derived
        const QString PathEIP1581 = "m/43'/60'/1581'";
        // BIP44-0 Wallet key, the default wallet key
        const QString PathDefaultWallet = PathWalletRoot + "/0";
        // EIP1581 Chat Key 0, the default whisper key
        const QString PathWhisper = PathEIP1581 + "/0'/0";

        const QVector<QString> AccountDefaultPaths {PathWalletRoot, PathEIP1581, PathWhisper, PathDefaultWallet};
    }
}
