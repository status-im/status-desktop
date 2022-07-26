#include "Status/Wallet/AccountAssetsController.h"

#include <StatusGo/Wallet/WalletApi.h>
#include <StatusGo/Wallet/BigInt.h>
#include <StatusGo/Metadata/api_response.h>

#include <Helpers/helpers.h>

#include <QtConcurrent>

namespace WalletGo = Status::StatusGo::Wallet;

namespace Status::Wallet {

AccountAssetsController::AccountAssetsController(WalletAccount* address, QObject* parent)
    : QObject(parent)
    , m_address(address)
    , m_enabledTokens({u"SNT"_qs, u"ETH"_qs, u"STT"_qs, u"DAI"_qs})
    , m_assets(Helpers::makeSharedQObject<AssetModel>("asset"))
{
    QtConcurrent::run([this, address]{ updateBalances(); })
        .then([this] {
            m_assetsReady = true;
            emit assetsReadyChanged();

            m_totalValue = 0;
            for(const auto& asset : m_assets->objects())
                m_totalValue += asset->value();
            emit totalValueChanged();
        })
        .onFailed([this] {
            emit assetsReadyChanged();
            qWarning() << "Unexpected failure while executing updateBalances for account" << m_address->data().address.get();
        });
}

void AccountAssetsController::updateBalances()
{
    const StatusGo::Accounts::EOAddress& address = m_address->data().address;
    if(m_assets->size() > 0)
        m_assets->clear();
    // TODO: this should be moved to status-go and exposed as "get balances for account and tokens with currency"
    std::map<Accounts::EOAddress, StatusGo::Wallet::Token> tokens;
    std::vector<WalletGo::ChainID> chainIds;
    auto allNets = WalletGo::getEthereumChains(false);
    for(const auto &net : allNets) {
        if(net.enabled && !net.isTest) {
            try {
                const auto allTokens = WalletGo::getTokens(net.chainId);
                for(const auto& tokenToMove : allTokens) {
                    if(isTokenEnabled(tokenToMove)) {
                        auto address = tokenToMove.address;
                        tokens.emplace(std::move(address), std::move(tokenToMove));
                    }
                }
                chainIds.push_back(net.chainId);
            }
            catch (const StatusGo::CallPrivateRpcError& e) {
                // Most probably "no tokens for this network"
                if(e.errorResponse().error.message.compare("no tokens for this network") != 0)
                    qWarning() << "Failed retrieving tokens for network" << net.chainId.get() << "; error" << e.errorResponse().error.message.c_str();
                continue;
            }
        }
    }

    auto accountBalances = WalletGo::getTokensBalancesForChainIDs(chainIds, { address }, std::move(Helpers::getKeys(tokens)));
    if(accountBalances.size() == 1) {
        for(const auto& accountAndBalance : accountBalances.begin()->second) {
            auto asset = Helpers::makeSharedQObject<WalletAsset>(std::make_shared<WalletGo::Token>(tokens.at(accountAndBalance.first)), accountAndBalance.second);
            m_assets->push_back(asset);
        }
    }
    else
        qWarning() << "Failed fetching balances for account" << address.get() << "; balances count" << accountBalances.size();
}

bool AccountAssetsController::isTokenEnabled(const StatusGo::Wallet::Token& token) const
{
    return find_if(m_enabledTokens.begin(), m_enabledTokens.end(), [&token](const auto& symbol) {
        return token.symbol == symbol;
    }) != m_enabledTokens.end();
}

QAbstractItemModel* AccountAssetsController::assetsModel() const
{
    return m_assets.get();
}

float AccountAssetsController::totalValue() const
{
    return m_totalValue;
}

bool AccountAssetsController::assetsReady() const
{
    return m_assetsReady;
}

}
