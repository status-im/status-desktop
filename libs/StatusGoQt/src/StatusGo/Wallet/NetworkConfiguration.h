#pragma once

#include "wallet_types.h"

#include <nlohmann/json.hpp>

#include <QString>
#include <QUrl>

#include <vector>

using json = nlohmann::json;

/// \note not sure if this is the best namespace, ok for now
namespace Status::StatusGo::Wallet
{

/// \note equivalent of status-go's Network@config.go (params package)
struct NetworkConfiguration
{
    ChainID chainId;
    QString chainName;
    QUrl rpcUrl;
    std::optional<QUrl> blockExplorerUrl;
    std::optional<QUrl> iconUrl;
    std::optional<QString> nativeCurrencyName;
    std::optional<QString> nativeCurrencySymbol;
    unsigned int nativeCurrencyDecimals{0};
    bool isTest{false};
    unsigned int layer{0};
    bool enabled{false};
    QColor chainColor;
    QString shortName;
};

using NetworkConfigurations = std::vector<NetworkConfiguration>;

NLOHMANN_DEFINE_TYPE_NON_INTRUSIVE(NetworkConfiguration,
                                   chainId,
                                   chainName,
                                   rpcUrl,
                                   blockExplorerUrl,
                                   iconUrl,
                                   nativeCurrencyName,
                                   nativeCurrencySymbol,
                                   nativeCurrencyDecimals,
                                   isTest,
                                   layer,
                                   enabled,
                                   chainColor,
                                   shortName);

} // namespace Status::StatusGo::Wallet
