#include "Status/Wallet/NewWalletAccountController.h"

#include <StatusGo/Wallet/WalletApi.h>

#include <StatusGo/Accounts/AccountsAPI.h>
#include <StatusGo/Accounts/Accounts.h>
#include <StatusGo/Accounts/accounts_types.h>
#include <StatusGo/Metadata/api_response.h>
#include <StatusGo/Utils.h>
#include <StatusGo/Types.h>

#include <Onboarding/Common/Constants.h>

#include <QQmlEngine>
#include <QJSEngine>

#include <ranges>

namespace GoAccounts = Status::StatusGo::Accounts;
namespace GoWallet = Status::StatusGo::Wallet;
namespace UtilsSG = Status::StatusGo::Utils;
namespace StatusGo = Status::StatusGo;

namespace Status::Wallet {

NewWalletAccountController::NewWalletAccountController(std::shared_ptr<Helpers::QObjectVectorModel<WalletAccount>> accounts)
    : m_accounts(accounts)
    , m_mainAccounts(std::move(filterMainAccounts(*accounts)), "account")
    , m_derivedAddress("derivedAddress")
    , m_derivationPath(Status::Constants::General::PathWalletRoot)
{
}


QAbstractListModel* NewWalletAccountController::mainAccountsModel()
{
    return &m_mainAccounts;
}

QAbstractItemModel *NewWalletAccountController::currentDerivedAddressModel()
{
    return &m_derivedAddress;
}

QString NewWalletAccountController::derivationPath() const
{
    return m_derivationPath.get();
}

void NewWalletAccountController::setDerivationPath(const QString &newDerivationPath)
{
    if (m_derivationPath.get() == newDerivationPath)
        return;
    m_derivationPath = GoAccounts::DerivationPath(newDerivationPath);
    emit derivationPathChanged();

    auto oldCustom = m_customDerivationPath;
    const auto &[derivedPath, index]= searchDerivationPath(m_derivationPath);
    m_customDerivationPath = derivedPath == nullptr;
    if(!m_customDerivationPath && !derivedPath.get()->alreadyCreated())
        updateSelectedDerivedAddress(index, derivedPath);

    if(m_customDerivationPath != oldCustom)
        emit customDerivationPathChanged();
}

void NewWalletAccountController::createAccountAsync(const QString &password, const QString &name,
                                          const QColor &color, const QString &path,
                                          const WalletAccount *derivedFrom)
{
    try {
        GoAccounts::generateAccountWithDerivedPath(StatusGo::HashedPassword(UtilsSG::hashPassword(password)),
                                                   name, color, "", GoAccounts::DerivationPath(path),
                                                   derivedFrom->data().derivedFrom.value());

        addNewlyCreatedAccount(findMissingAccount());
    }
    catch(const StatusGo::CallPrivateRpcError& e) {
        qWarning() << "StatusGoQt.generateAccountWithDerivedPath error: " << e.errorResponse().error.message.c_str();

        emit accountCreatedStatus(false);
    }
}

void NewWalletAccountController::addWatchOnlyAccountAsync(const QString &address, const QString &name, const QColor &color)
{
    try {
        GoAccounts::addAccountWatch(Accounts::EOAddress(address), name, color, u""_qs);

        addNewlyCreatedAccount(findMissingAccount());
    }
    catch(const StatusGo::CallPrivateRpcError& e) {
        qWarning() << "StatusGoQt.generateAccountWithDerivedPath error: " << e.errorResponse().error.message.c_str();

        emit accountCreatedStatus(false);
    }
}

bool NewWalletAccountController::retrieveAndUpdateDerivedAddresses(const QString &password,
                                                                   const WalletAccount *derivedFrom)
{
    assert(derivedFrom->data().derivedFrom.has_value());
    try {
        int currentPage = 1;
        int foundIndex = -1;
        int currentIndex = 0;
        auto maxPageCount = static_cast<int>(std::ceil(static_cast<double>(m_maxDerivedAddresses)/static_cast<double>(m_derivedAddressesPageSize)));
        std::shared_ptr<DerivedWalletAddress> foundEntry;
        while(currentPage <= maxPageCount && foundIndex < 0) {
            auto all = GoWallet::getDerivedAddressesForPath(StatusGo::HashedPassword(UtilsSG::hashPassword(password)),
                                                            derivedFrom->data().derivedFrom.value(),
                                                            Status::Constants::General::PathWalletRoot,
                                                            m_derivedAddressesPageSize, currentPage);
            if((currentIndex + all.size()) > m_derivedAddress.size())
                m_derivedAddress.resize(currentIndex + all.size());

            for(auto newDerived : all) {
                auto newEntry = std::make_shared<DerivedWalletAddress>(std::move(newDerived));
                m_derivedAddress.set(currentIndex, newEntry);
                if(foundIndex < 0 && !newEntry->data().alreadyCreated) {
                    foundIndex = currentIndex;
                    foundEntry = newEntry;
                }
                currentIndex++;
            }
            currentPage++;
        }
        if(foundIndex > 0)
            updateSelectedDerivedAddress(foundIndex, foundEntry);

        return true;
    } catch(const StatusGo::CallPrivateRpcError &e) {
        return false;
    }
}

void NewWalletAccountController::clearDerivedAddresses()
{
    m_derivedAddress.clear();
}

WalletAccountPtr NewWalletAccountController::findMissingAccount()
{
    auto accounts = GoAccounts::getAccounts();
    // TODO: consider using a QObjectSetModel and a proxy sort model on top instead
    auto it = std::find_if(accounts.begin(), accounts.end(), [this](const auto &a) {
        return std::none_of(m_accounts->objects().begin(), m_accounts->objects().end(),
                            [&a](const auto &eA) { return a.address == eA->data().address; });
    });
    return it != accounts.end() ? std:: make_shared<WalletAccount>(*it) : nullptr;
}

NewWalletAccountController::AccountsModel::ObjectContainer
NewWalletAccountController::filterMainAccounts(const AccountsModel &accounts)
{
    AccountsModel::ObjectContainer out;
    const auto &c = accounts.objects();
    std::copy_if(c.begin(), c.end(), std::back_inserter(out), [](const auto &a){ return a->data().isWallet; });
    return out;
}

void NewWalletAccountController::addNewlyCreatedAccount(WalletAccountPtr newAccount)
{
    if(newAccount)
        m_accounts->push_back(newAccount);
    else
        qWarning() << "No new account to add. Creation failed";

    emit accountCreatedStatus(newAccount != nullptr);
}

DerivedWalletAddress *NewWalletAccountController::selectedDerivedAddress() const
{
    return m_selectedDerivedAddress.get();
}

void NewWalletAccountController::setSelectedDerivedAddress(DerivedWalletAddress *newSelectedDerivedAddress)
{
    if (m_selectedDerivedAddress.get() == newSelectedDerivedAddress)
        return;
    auto &objs = m_derivedAddress.objects();
    auto foundIt = std::find_if(objs.begin(), objs.end(), [newSelectedDerivedAddress](const auto &a) { return a.get() == newSelectedDerivedAddress; });
    updateSelectedDerivedAddress(std::distance(objs.begin(), foundIt), *foundIt);
}

void NewWalletAccountController::updateSelectedDerivedAddress(int index, std::shared_ptr<DerivedWalletAddress> newEntry) {
    m_derivedAddressIndex = index;
    m_selectedDerivedAddress = newEntry;
    emit selectedDerivedAddressChanged();
    if(m_derivationPath != newEntry->data().path) {
        m_derivationPath = newEntry->data().path;
        emit derivationPathChanged();
    }
}

std::tuple<DerivedWalletAddressPtr, int> NewWalletAccountController::searchDerivationPath(const GoAccounts::DerivationPath &derivationPath) {
    const auto &c = m_derivedAddress.objects();
    auto foundIt = find_if(c.begin(), c.end(), [&derivationPath](const auto &a) { return a->data().path == derivationPath; });
    if(foundIt != c.end())
        return {*foundIt, std::distance(c.begin(), foundIt)};
    return {nullptr, -1};
}

}
