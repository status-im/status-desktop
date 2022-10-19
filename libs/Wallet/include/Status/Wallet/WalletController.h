#pragma once

#include "Status/Wallet/WalletAccount.h"

#include <Helpers/QObjectVectorModel.h>

#include <QtQmlIntegration>

#include <memory>

class QQmlEngine;
class QJSEngine;

namespace Status::Wallet
{

class NewWalletAccountController;
class AccountAssetsController;
class SavedAddressesController;

/// \todo move account creation to its own controller
class WalletController : public QObject
{
    Q_OBJECT
    QML_ELEMENT
    QML_SINGLETON

    Q_PROPERTY(QAbstractListModel* accountsModel READ accountsModel CONSTANT)
    Q_PROPERTY(WalletAccount* currentAccount READ currentAccount NOTIFY currentAccountChanged)

public:
    WalletController();

    /// Called by QML engine to register the instance. QML takes ownership of the instance
    [[nodiscard]] static WalletController* create(QQmlEngine* qmlEngine, QJSEngine* jsEngine);

    /// To be used in the new wallet account workflow
    /// \note caller (QML) takes ownership of the returned object
    /// \todo consider if complex approach of keeping ownership here and enforcing a unique instance
    ///       or not reusing the account list and make it singleton are better options
    Q_INVOKABLE [[nodiscard]] Status::Wallet::NewWalletAccountController* createNewWalletAccountController() const;
    /// Separated controler for working with wallet saved addresses
    /// \note caller (QML) takes ownership of the returned object
    /// \todo consider if complex approach of keeping ownership here and enforcing a unique instance
    ///       or not reusing the saved addresses list and make it singleton are better options
    Q_INVOKABLE [[nodiscard]] Status::Wallet::SavedAddressesController* createSavedAddressesController() const;

    QAbstractListModel* accountsModel() const;

    WalletAccount* currentAccount() const;
    Q_INVOKABLE void setCurrentAccountIndex(int index);

    /// \note caller (QML) takes ownership of the returned instance
    Q_INVOKABLE Status::Wallet::AccountAssetsController*
    createAccountAssetsController(Status::Wallet::WalletAccount* account);

signals:
    void currentAccountChanged();

private:
    std::vector<WalletAccountPtr> getWalletAccounts(bool rootWalletAccountsOnly = false) const;

    using AccountsModel = Helpers::QObjectVectorModel<WalletAccount>;
    std::shared_ptr<AccountsModel> m_accounts;
    WalletAccountPtr m_currentAccount;
};

} // namespace Status::Wallet
