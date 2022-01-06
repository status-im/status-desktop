#pragma once

#include <QString>

namespace Constants
{
namespace Fleet
{
const QString Prod = "eth.prod";
const QString Staging = "eth.staging";
const QString Test = "eth.test";
const QString WakuV2Prod = "wakuv2.prod";
const QString WakuV2Test = "wakuv2.test";
const QString GoWakuTest = "go-waku.test";
}; // namespace Fleet

namespace FleetNodes
{
const QString Bootnodes = "boot";
const QString Mailservers = "mail";
const QString Rendezvous = "rendezvous";
const QString Whisper = "whisper";
const QString Waku = "waku";
const QString LibP2P = "libp2p";
const QString Websocket = "websocket";
} // namespace FleetNodes

const QString DefaultNetworkName = "mainnet_rpc";
//const DEFAULT_NETWORKS_IDS* = @["mainnet_rpc", "testnet_rpc", "rinkeby_rpc", "goerli_rpc", "xdai_rpc", "poa_rpc" ]


const QString DataDir = "/data";
const QString Keystore = "/data/keystore";

QString applicationPath(QString path = "");
QString tmpPath(QString path = "");
QString cachePath(QString path = "");


} // namespace Constants
