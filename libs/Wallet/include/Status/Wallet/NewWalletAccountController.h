#pragma once

#include "Status/Wallet/WalletAccount.h"
#include "Status/Wallet/DerivedWalletAddress.h"

#include <Helpers/QObjectVectorModel.h>

#include <QtQmlIntegration>

namespace Status::Wallet {

/// \note the following values are kept in sync \c selectedDerivedAddress, \c derivedAddressIndex and \c derivationPath
///       and \c customDerivationPath; \see connascence.io/value
class NewWalletAccountController: public QObject
{
    Q_OBJECT
    QML_ELEMENT
    QML_UNCREATABLE("C++ only")

    Q_PROPERTY(QAbstractListModel* mainAccountsModel READ mainAccountsModel CONSTANT)

    Q_PROPERTY(QAbstractItemModel* currentDerivedAddressModel READ currentDerivedAddressModel CONSTANT)
    Q_PROPERTY(DerivedWalletAddress* selectedDerivedAddress READ selectedDerivedAddress WRITE setSelectedDerivedAddress NOTIFY selectedDerivedAddressChanged)
    Q_PROPERTY(int derivedAddressIndex MEMBER m_derivedAddressIndex NOTIFY selectedDerivedAddressChanged)

    Q_PROPERTY(QString derivationPath READ derivationPath WRITE setDerivationPath NOTIFY derivationPathChanged)
    Q_PROPERTY(bool customDerivationPath MEMBER m_customDerivationPath NOTIFY customDerivationPathChanged)

public:
    using AccountsModel = Helpers::QObjectVectorModel<WalletAccount>;

    /// \note On account creation \c accounts are updated with the newly created wallet account
    NewWalletAccountController(std::shared_ptr<AccountsModel> accounts);

    QAbstractListModel *mainAccountsModel();
    QAbstractItemModel *currentDerivedAddressModel();

    QString derivationPath() const;
    void setDerivationPath(const QString &newDerivationPath);

    /// \see \c accountCreatedStatus for async result
    Q_INVOKABLE void createAccountAsync(const QString &password, const QString &name,
                                        const QColor &color, const QString &path,
                                        const Status::Wallet::WalletAccount *derivedFrom);

    /// \see \c accountCreatedStatus for async result
    Q_INVOKABLE void addWatchOnlyAccountAsync(const QString &address, const QString &name,
                                              const QColor &color);


    /// \returns \c false if fails (due to incomplete user input)
    Q_INVOKABLE bool retrieveAndUpdateDerivedAddresses(const QString &password,
                                                       const Status::Wallet::WalletAccount *derivedFrom);
    Q_INVOKABLE void clearDerivedAddresses();

    DerivedWalletAddress *selectedDerivedAddress() const;
    void setSelectedDerivedAddress(DerivedWalletAddress *newSelectedDerivedAddress);

signals:
    void accountCreatedStatus(bool createdSuccessfully);

    void selectedDerivedAddressChanged();

    void derivationPathChanged();

    void customDerivationPathChanged();

private:
    void updateSelectedDerivedAddress(int index, std::shared_ptr<DerivedWalletAddress> newEntry);

    std::tuple<DerivedWalletAddressPtr, int> searchDerivationPath(const GoAccounts::DerivationPath &derivationPath);

    WalletAccountPtr findMissingAccount();

    AccountsModel::ObjectContainer filterMainAccounts(const AccountsModel &accounts);
    /// Logs a debug message if it fails
    void addNewlyCreatedAccount(WalletAccountPtr newAccount);

    std::shared_ptr<AccountsModel> m_accounts;
    /// \todo make it a proxy filter on top of \c m_accounts
    AccountsModel m_mainAccounts;

    Helpers::QObjectVectorModel<DerivedWalletAddress> m_derivedAddress;
    int m_derivedAddressIndex{0};
    DerivedWalletAddressPtr m_selectedDerivedAddress;
    GoAccounts::DerivationPath m_derivationPath;
    bool m_customDerivationPath{false};

    static constexpr int m_derivedAddressesPageSize{15};
    static constexpr int m_maxDerivedAddresses{5 * m_derivedAddressesPageSize};
};

} // namespace Status::Wallet
