#pragma once

#include "Status/Wallet/WalletAccount.h"
#include "Status/Wallet/WalletAsset.h"

#include <Helpers/QObjectVectorModel.h>

#include <QtQmlIntegration>

namespace Status::Wallet {

/// Controlls asset for an account using hardcoded network and token lists
///
/// \todo add static configuration component to provide networks, tokens and currency list
/// \todo impliement \c AccountsBalanceService to fetch and cache realtime balance (or better implement this in status-go)
/// \todo implement native token fetching
/// \todo double responsibility, split functionality in asset management and balance
class AccountAssetsController: public QObject
{
    Q_OBJECT
    QML_ELEMENT
    QML_UNCREATABLE("C++ only")

    Q_PROPERTY(QAbstractItemModel* assetModel READ assetsModel CONSTANT)
    Q_PROPERTY(float totalValue READ totalValue NOTIFY totalValueChanged)
    Q_PROPERTY(bool assetsReady READ assetsReady NOTIFY assetsReadyChanged)

public:
    AccountAssetsController(WalletAccount* address, QObject* parent = nullptr);

    QAbstractItemModel* assetsModel() const;

    float totalValue() const;

    bool assetsReady() const;

signals:
    void totalValueChanged();
    void assetsReadyChanged();

private:
    void updateBalances();
    bool isTokenEnabled(const StatusGo::Wallet::Token& token) const;

    WalletAccount* m_address;
    const std::vector<QString> m_enabledTokens;

    using AssetModel = Helpers::QObjectVectorModel<WalletAsset>;
    std::shared_ptr<AssetModel> m_assets;
    float m_totalValue{};
    bool m_assetsReady{};
};

} // namespace Status::Wallet
